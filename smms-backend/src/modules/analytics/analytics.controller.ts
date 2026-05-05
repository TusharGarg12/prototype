import { Request, Response, NextFunction } from 'express';
import { prisma } from '../../config/prisma';
import { ok } from '../../utils/apiResponse';
import { getCurrentMealSlot, todayDate } from '../../utils/mealWindow';
import { forecastHeadcount } from '../../utils/mlBackend';
import scenarios from '../../data/attendance_scenarios.json';
import calendar from '../../data/calendar_2025.json';

type MealSlot = 'BREAKFAST' | 'LUNCH' | 'SNACKS' | 'DINNER';
type ScenarioKey = keyof typeof scenarios;

export const getCrowdHeatmap = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const mealSlot = req.query.mealSlot as string || getCurrentMealSlot() || 'LUNCH'; // fallback if outside window
    const mealDate = req.query.date ? new Date(req.query.date as string) : todayDate();

    // Fetch all logs for the given meal slot
    const logs = await prisma.attendanceLog.findMany({
      where: {
        mealSlot,
        mealDate,
      },
      select: { scannedAt: true }
    });

    // Group by 10-minute intervals
    const heatmap: Record<string, number> = {};
    for (const log of logs) {
      const min = log.scannedAt.getMinutes();
      const hr = log.scannedAt.getHours();
      
      // Compute 10-minute bucket. e.g., 18:34 -> 18:30
      const bucketMin = Math.floor(min / 10) * 10;
      const bucketStr = `${String(hr).padStart(2, '0')}:${String(bucketMin).padStart(2, '0')}`;
      
      if (!heatmap[bucketStr]) heatmap[bucketStr] = 0;
      heatmap[bucketStr]++;
    }

    // Convert to sorted array
    const sortedHeatmap = Object.entries(heatmap)
      .map(([time, count]) => ({ time, count }))
      .sort((a, b) => a.time.localeCompare(b.time));

    const dateStr = formatDate(mealDate);
    const scenario = scenarioForDate(dateStr, {});
    const prediction = predictedCountFor(scenario, mealSlot as MealSlot);

    return ok(res, {
        mealSlot,
        mealDate,
        heatmap: sortedHeatmap,
        prediction
    }, 'Live Heatmap Analytics');
  } catch (error) {
    next(error);
  }
};

const formatDate = (date: Date) => {
  const y = date.getFullYear().toString().padStart(4, '0');
  const m = (date.getMonth() + 1).toString().padStart(2, '0');
  const d = date.getDate().toString().padStart(2, '0');
  return `${y}-${m}-${d}`;
};

const parseDate = (input: string) => {
  const [y, m, d] = input.split('-').map(Number);
  return new Date(y, m - 1, d);
};

const isWithinRange = (dateStr: string, range: { start: string; end: string }) => {
  const date = parseDate(dateStr).getTime();
  const start = parseDate(range.start).getTime();
  const end = parseDate(range.end).getTime();
  return date >= start && date <= end;
};

const isHoliday = (dateStr: string) => calendar.holidays.includes(dateStr);

const isFestDay = (dateStr: string) => calendar.festDays.includes(dateStr);

const isExamWeek = (dateStr: string) =>
  calendar.examWeeks.some((range) => isWithinRange(dateStr, range));

const scenarioForDate = (dateStr: string, flags: { weather?: string; exam?: boolean; fest?: boolean }) => {
  const date = parseDate(dateStr);
  const weekday = date.getDay();
  const weather = flags.weather ?? 'clear';
  const isExam = flags.exam ?? isExamWeek(dateStr);
  const isFest = flags.fest ?? isFestDay(dateStr);
  const nextDate = formatDate(new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1));
  const prevDate = formatDate(new Date(date.getFullYear(), date.getMonth(), date.getDate() - 1));
  const holidayTomorrow = isHoliday(nextDate);

  if (weather === 'rain' && isExam) return 'Rain + Exam' as ScenarioKey;
  if (weather === 'rain' && isFest) return 'Rain + Fest' as ScenarioKey;

  if (holidayTomorrow) return 'Flight Risk (Day Before Holiday)' as ScenarioKey;
  if (isHoliday(prevDate)) return 'Return Lag (Day After Holiday)' as ScenarioKey;

  if (isFest) return 'Fest Days (Effervescence)' as ScenarioKey;
  if (isExam) return 'Exam Week (Normal Weather)' as ScenarioKey;
  if (weather === 'rain' && weekday === 6) return 'Rain + Weekend' as ScenarioKey;
  if (weather === 'rain') return 'Heavy Rain (Normal Day)' as ScenarioKey;
  if (weekday === 0) return 'Best Menu (Sunday)' as ScenarioKey;
  if (weekday === 2) return 'Worst Menu (Tuesday)' as ScenarioKey;
  if (weekday === 6) return 'Normal Weekend (Saturday)' as ScenarioKey;
  return 'Baseline (Normal Wednesday)' as ScenarioKey;
};

const predictedCountFor = (scenario: ScenarioKey, mealSlot: MealSlot) => {
  const values = scenarios[scenario];
  if (mealSlot === 'BREAKFAST') return values.BREAKFAST;
  if (mealSlot === 'LUNCH') return values.LUNCH;
  if (mealSlot === 'DINNER') return values.DINNER;

  // Snacks are not in the dataset; approximate using lunch baseline.
  return Math.max(0, Math.round(values.LUNCH * 0.35));
};

export const getPredictions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const days = Math.max(1, Math.min(30, Number(req.query.days ?? 7)));
    const start = (req.query.start as string) ?? formatDate(new Date());
    const weather = (req.query.weather as string | undefined) ?? undefined;
    const exam = req.query.exam === 'true' ? true : undefined;
    const fest = req.query.fest === 'true' ? true : undefined;
    const totalStudents = Math.max(1, Number(req.query.totalStudents ?? 600));
    const academicEvent = (req.query.academicEvent as string | undefined) ?? (req.query.event as string | undefined);

    const meals: MealSlot[] = ['BREAKFAST', 'LUNCH', 'DINNER'];

    try {
      const predictions: Array<{ date: string; mealSlot: MealSlot; predictedCount: number; scenario: string; confidence?: number }> = [];

      for (let i = 0; i < days; i += 1) {
        const date = new Date(parseDate(start).getTime() + i * 24 * 60 * 60 * 1000);
        const dateStr = formatDate(date);

        for (const mealSlot of meals) {
          const forecast = await forecastHeadcount({
            date: dateStr,
            meal_slot: mealSlot,
            total_students: totalStudents,
            academic_event: academicEvent,
            is_raining: weather === 'rain',
            exam,
            fest,
          });

          const expected = Number(
            forecast.expected_headcount ??
            forecast.predicted_headcount ??
            forecast.headcount ??
            forecast.predictedCount ??
            totalStudents,
          );
          const factors = Array.isArray(forecast.determining_factors)
            ? forecast.determining_factors
            : Array.isArray(forecast.factors)
              ? forecast.factors
              : [];
          const scenario = factors.length > 0
            ? factors.map((item) => String(item)).join(', ')
            : 'ML forecast';
          const confidence = Number(
            forecast.confidence_level ??
            forecast.confidence ??
            forecast.confidenceScore ??
            0,
          );

          predictions.push({
            date: dateStr,
            mealSlot,
            predictedCount: Number.isFinite(expected) ? Math.max(0, Math.round(expected)) : 0,
            scenario,
            confidence: Number.isFinite(confidence) ? confidence : undefined,
          });
        }
      }

      ok(res, { predictions, start, days }, 'Attendance predictions');
      return;
    } catch (_) {
      // Fall back to the local heuristic model when the ML service is offline.
    }

    const predictions: Array<{ date: string; mealSlot: MealSlot; predictedCount: number; scenario: string }> = [];

    for (let i = 0; i < days; i += 1) {
      const date = new Date(parseDate(start).getTime() + i * 24 * 60 * 60 * 1000);
      const dateStr = formatDate(date);
      const scenario = scenarioForDate(dateStr, { weather, exam, fest });
      predictions.push({ date: dateStr, mealSlot: 'BREAKFAST', predictedCount: predictedCountFor(scenario, 'BREAKFAST'), scenario });
      predictions.push({ date: dateStr, mealSlot: 'LUNCH', predictedCount: predictedCountFor(scenario, 'LUNCH'), scenario });
      predictions.push({ date: dateStr, mealSlot: 'DINNER', predictedCount: predictedCountFor(scenario, 'DINNER'), scenario });
    }

    ok(res, { predictions, start, days }, 'Attendance predictions');
  } catch (error) {
    next(error);
  }
};