import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { ok } from '../../utils/apiResponse';
import { getCurrentMealSlot, todayDate } from '../../utils/mealWindow';
import { forecastHeadcount, optimizeSurge, optimizeWaste } from '../../utils/mlBackend';
import calendar from '../../data/calendar_2025.json';

const RequestSchema = z.object({
  date: z.string().optional(),
  mealSlot: z.string().optional(),
  totalStudents: z.coerce.number().int().positive().default(600),
  totalCapacity: z.coerce.number().int().positive().default(600),
  academicEvent: z.string().optional(),
  isRaining: z.coerce.boolean().default(false),
  menuItems: z.union([z.array(z.string()), z.string()]).optional(),
});

const MenuGuidanceSchema = z.object({
  date: z.string().optional(),
  mealSlot: z.string().optional(),
  menuItems: z.array(z.string()).default([]),
  weather: z.string().optional(),
  temperatureC: z.coerce.number().optional(),
  academicEvent: z.string().optional(),
  branchName: z.string().optional(),
  totalStudents: z.coerce.number().int().positive().default(600),
});

const formatDate = (date: Date) => {
  const y = date.getFullYear().toString().padStart(4, '0');
  const m = (date.getMonth() + 1).toString().padStart(2, '0');
  const d = date.getDate().toString().padStart(2, '0');
  return `${y}-${m}-${d}`;
};

const normalizeMealSlot = (input?: string) => {
  const mealSlot = (input ?? getCurrentMealSlot() ?? 'LUNCH').toUpperCase();
  return mealSlot === 'BREAKFAST' || mealSlot === 'LUNCH' || mealSlot === 'SNACKS' || mealSlot === 'DINNER'
    ? mealSlot
    : 'LUNCH';
};

const normalizeDate = (input?: string) => input ?? formatDate(todayDate());

const normalizeMenuItems = (input?: string | string[]) => {
  if (!input) return [];
  if (Array.isArray(input)) return input.filter((item) => item.trim().length > 0);
  return input.split(',').map((item) => item.trim()).filter(Boolean);
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

const isExamWeek = (dateStr: string) => calendar.examWeeks.some((range) => isWithinRange(dateStr, range));

const defaultWeatherForDate = (date: Date) => {
  const month = date.getMonth() + 1;
  if (month >= 3 && month <= 6) {
    return { kind: 'hot', temperatureC: 37 };
  }
  if (month >= 7 && month <= 9) {
    return { kind: 'rain', temperatureC: 29 };
  }
  return { kind: 'mild', temperatureC: 26 };
};

const normalizeWeather = (weather?: string, temperatureC?: number, date?: Date) => {
  if (weather === 'rain') return { kind: 'rain', temperatureC: temperatureC ?? 29 };
  if (weather === 'hot') return { kind: 'hot', temperatureC: temperatureC ?? 37 };
  if (weather === 'cold') return { kind: 'cold', temperatureC: temperatureC ?? 22 };
  const fallback = defaultWeatherForDate(date ?? new Date());
  return { kind: fallback.kind, temperatureC: temperatureC ?? fallback.temperatureC };
};

const detectIngredientFatigue = (menuItems: string[]) => {
  const keywordBuckets = [
    { key: 'rice', label: 'Rice-heavy menu' },
    { key: 'dal', label: 'Dal repetition' },
    { key: 'paneer', label: 'Paneer repetition' },
    { key: 'curd', label: 'Dairy repetition' },
    { key: 'salad', label: 'Salad repetition' },
    { key: 'fruit', label: 'Fruit repetition' },
    { key: 'potato', label: 'Potato repetition' },
  ];

  return keywordBuckets
    .map(({ key, label }) => ({
      label,
      count: menuItems.filter((item) => item.toLowerCase().includes(key)).length,
    }))
    .filter((entry) => entry.count > 1)
    .map((entry) => `${entry.label} detected ${entry.count} times`);
};

const toUnique = (items: string[]) => Array.from(new Set(items.map((item) => item.trim()).filter(Boolean)));

const buildForecastFallback = ({
  date,
  mealSlot,
  totalStudents,
  academicEvent,
  isRaining,
}: {
  date: string;
  mealSlot: string;
  totalStudents: number;
  academicEvent?: string;
  isRaining: boolean;
}) => {
  const multipliers: Record<string, number> = {
    BREAKFAST: 0.34,
    LUNCH: 0.62,
    SNACKS: 0.18,
    DINNER: 0.42,
  };
  let expectedHeadcount = Math.round(totalStudents * (multipliers[mealSlot] ?? 0.5));

  if (academicEvent) expectedHeadcount = Math.round(expectedHeadcount * 1.08);
  if (isRaining) expectedHeadcount = Math.round(expectedHeadcount * 1.05);

  return {
    date,
    meal_slot: mealSlot,
    expected_headcount: expectedHeadcount,
    confidence_level: 0.58,
    determining_factors: [
      academicEvent ? `Event: ${academicEvent}` : 'No special academic event',
      isRaining ? 'Rainy day pressure' : 'Normal weather',
      `Baseline for ${mealSlot.toLowerCase()}`,
    ],
  };
};

const normalizeForecast = (raw: Record<string, unknown>, fallback: ReturnType<typeof buildForecastFallback>) => {
  const expectedHeadcount = Number(
    raw.expected_headcount ?? raw.predicted_headcount ?? raw.headcount ?? fallback.expected_headcount,
  );
  const confidence = Number(raw.confidence_level ?? raw.confidence ?? fallback.confidence_level);
  const factors = Array.isArray(raw.determining_factors)
    ? raw.determining_factors.map((item) => String(item))
    : fallback.determining_factors;

  return {
    date: String(raw.date ?? fallback.date),
    mealSlot: String(raw.meal_slot ?? raw.mealSlot ?? fallback.meal_slot),
    expectedHeadcount: Number.isFinite(expectedHeadcount) ? Math.max(0, Math.round(expectedHeadcount)) : fallback.expected_headcount,
    confidence: Number.isFinite(confidence) ? confidence : fallback.confidence_level,
    determiningFactors: factors,
    source: String(raw.source ?? 'ml-backend'),
  };
};

const normalizeSurgeRecommendation = (raw: Record<string, unknown>, forecast: { expectedHeadcount: number; mealSlot: string }, totalCapacity: number) => {
  const rewardSlots = Array.isArray(raw.recommended_reward_slots)
    ? raw.recommended_reward_slots
    : Array.isArray(raw.reward_slots)
      ? raw.reward_slots
      : [];
  const occupancyPercent = Number(raw.occupancy_percent ?? raw.occupancy_rate ?? ((forecast.expectedHeadcount / totalCapacity) * 100));
  const analysis = String(raw.analysis ?? raw.recommendation ?? 'Activate surge incentive when crowd rises above threshold.');

  return {
    occupancyPercent: Number.isFinite(occupancyPercent) ? occupancyPercent : (forecast.expectedHeadcount / totalCapacity) * 100,
    expectedHeadcount: forecast.expectedHeadcount,
    totalCapacity,
    mealSlot: forecast.mealSlot,
    recommendedRewardSlots: rewardSlots,
    analysis,
    source: String(raw.source ?? 'ml-backend'),
  };
};

const normalizeWasteRecommendation = (raw: Record<string, unknown>, forecast: { expectedHeadcount: number; mealSlot: string }, menuItems: string[]) => {
  const suggestedActions = Array.isArray(raw.suggested_actions)
    ? raw.suggested_actions
    : Array.isArray(raw.actions)
      ? raw.actions
      : [];
  const estimatedWasteKg = Number(raw.estimated_waste_kg ?? raw.expected_waste_kg ?? 0);
  const wasteScore = Number(raw.waste_score ?? raw.optimization_score ?? 0);

  return {
    mealSlot: forecast.mealSlot,
    expectedHeadcount: forecast.expectedHeadcount,
    menuItems,
    estimatedWasteKg: Number.isFinite(estimatedWasteKg) ? estimatedWasteKg : 0,
    wasteScore: Number.isFinite(wasteScore) ? wasteScore : 0,
    suggestedActions,
    source: String(raw.source ?? 'ml-backend'),
  };
};

export const getSurgeRecommendation = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = RequestSchema.parse(req.body ?? {});
    const date = normalizeDate(parsed.date);
    const mealSlot = normalizeMealSlot(parsed.mealSlot);
    const fallbackForecast = buildForecastFallback({
      date,
      mealSlot,
      totalStudents: parsed.totalStudents,
      academicEvent: parsed.academicEvent,
      isRaining: parsed.isRaining,
    });

    try {
      const forecastRaw = await forecastHeadcount({
        date,
        meal_slot: mealSlot,
        total_students: parsed.totalStudents,
        academic_event: parsed.academicEvent,
        is_raining: parsed.isRaining,
      });
      const forecast = normalizeForecast(forecastRaw, fallbackForecast);

      const recommendationRaw = await optimizeSurge({
        expected_headcount: forecast.expectedHeadcount,
        total_capacity: parsed.totalCapacity,
        meal_slot: mealSlot,
        date,
      });

      ok(res, {
        forecast,
        recommendation: normalizeSurgeRecommendation(recommendationRaw, forecast, parsed.totalCapacity),
      }, 'Surge recommendation');
      return;
    } catch (_) {
      const forecast = normalizeForecast({}, fallbackForecast);
      const occupancyPercent = (forecast.expectedHeadcount / parsed.totalCapacity) * 100;
      ok(res, {
        forecast,
        recommendation: {
          occupancyPercent,
          expectedHeadcount: forecast.expectedHeadcount,
          totalCapacity: parsed.totalCapacity,
          mealSlot,
          recommendedRewardSlots: occupancyPercent >= 75
            ? [{ timeWindow: '12:00-12:30', bonusPoints: 30, reason: 'Crowd relief incentive' }]
            : [{ timeWindow: '12:30-13:00', bonusPoints: 15, reason: 'Gentle occupancy smoothing' }],
          analysis: occupancyPercent >= 75
            ? 'Deploy a high-visibility surge incentive to pull traffic into a quieter window.'
            : 'Current crowd pressure is moderate. A lighter incentive is enough.',
          source: 'fallback',
        },
      }, 'Surge recommendation');
    }
  } catch (error) {
    next(error);
  }
};

export const getWasteRecommendation = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = RequestSchema.parse(req.body ?? {});
    const date = normalizeDate(parsed.date);
    const mealSlot = normalizeMealSlot(parsed.mealSlot);
    const menuItems = normalizeMenuItems(parsed.menuItems);
    const fallbackForecast = buildForecastFallback({
      date,
      mealSlot,
      totalStudents: parsed.totalStudents,
      academicEvent: parsed.academicEvent,
      isRaining: parsed.isRaining,
    });

    try {
      const forecastRaw = await forecastHeadcount({
        date,
        meal_slot: mealSlot,
        total_students: parsed.totalStudents,
        academic_event: parsed.academicEvent,
        is_raining: parsed.isRaining,
      });
      const forecast = normalizeForecast(forecastRaw, fallbackForecast);

      const recommendationRaw = await optimizeWaste({
        expected_headcount: forecast.expectedHeadcount,
        menu_items: menuItems,
        meal_slot: mealSlot,
        date,
      });

      ok(res, {
        forecast,
        recommendation: normalizeWasteRecommendation(recommendationRaw, forecast, menuItems),
      }, 'Waste recommendation');
      return;
    } catch (_) {
      const forecast = normalizeForecast({}, fallbackForecast);
      const estimatedWasteKg = Math.max(0, Math.round((menuItems.length || 4) * (forecast.expectedHeadcount / parsed.totalCapacity) * 1.2));

      ok(res, {
        forecast,
        recommendation: {
          mealSlot,
          expectedHeadcount: forecast.expectedHeadcount,
          menuItems,
          estimatedWasteKg,
          wasteScore: Math.max(0, 100 - estimatedWasteKg * 8),
          suggestedActions: menuItems.length > 0
            ? [`Prioritize ${menuItems[0]}`, 'Reduce batch size by 10%', 'Repurpose leftovers into a next-slot side dish']
            : ['Reduce batch size by 10%', 'Track leftovers more closely'],
          source: 'fallback',
        },
      }, 'Waste recommendation');
    }
  } catch (error) {
    next(error);
  }
};

export const getMenuGuidance = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = MenuGuidanceSchema.parse(req.body ?? {});
    const date = normalizeDate(parsed.date);
    const mealSlot = normalizeMealSlot(parsed.mealSlot);
    const menuItems = toUnique(parsed.menuItems);
    const dateObj = parseDate(date);
    const weather = normalizeWeather(parsed.weather, parsed.temperatureC, dateObj);
    const calendarState = {
      holiday: isHoliday(date),
      fest: isFestDay(date),
      examWeek: isExamWeek(date),
      tomorrowHoliday: isHoliday(formatDate(new Date(dateObj.getFullYear(), dateObj.getMonth(), dateObj.getDate() + 1))),
    };

    const fallbackForecast = buildForecastFallback({
      date,
      mealSlot,
      totalStudents: parsed.totalStudents,
      academicEvent: parsed.academicEvent,
      isRaining: weather.kind === 'rain',
    });

    let forecast = normalizeForecast({}, fallbackForecast);
    try {
      const forecastRaw = await forecastHeadcount({
        date,
        meal_slot: mealSlot,
        total_students: parsed.totalStudents,
        academic_event: parsed.academicEvent,
        is_raining: weather.kind === 'rain',
      });
      forecast = normalizeForecast(forecastRaw, fallbackForecast);
    } catch (_) {
      // Keep fallback forecast.
    }

    const wasteHint = menuItems.length > 0
      ? Math.max(0, Math.round((menuItems.length * forecast.expectedHeadcount) / parsed.totalStudents / 10))
      : 0;
    const fatigueNotes = detectIngredientFatigue(menuItems);
    const lighterMeal = weather.kind === 'hot' || weather.temperatureC >= 34;
    const comfortMeal = weather.kind === 'rain' || weather.kind === 'cold' || calendarState.examWeek;

    const recommendedMenuItems = lighterMeal
      ? menuItems.filter((item) => /salad|curd|fruit|juice|water|cucumber|buttermilk|khichdi/i.test(item)).concat(menuItems.slice(0, 2))
      : comfortMeal
        ? menuItems.filter((item) => /dal|soup|khichdi|rice|roti|paneer|tea/i.test(item)).concat(menuItems.slice(0, 2))
        : menuItems.slice(0, 4);

    const avoidItems = lighterMeal
      ? ['Heavy fried items', 'Deep gravies', 'Spicy oil-heavy dishes']
      : comfortMeal
        ? ['Very cold desserts', 'Light-only menus']
        : ['Over-rotating the same starch'];

    const leftoverRouting = [
      'Shift safe leftovers into the next meal slot when policy allows.',
      'Use excess rice or dal for soup, khichdi, or wraps rather than discarding it.',
      'Track any non-reusable leftovers separately for disposal or donation approval.',
    ];

    const healthTips = lighterMeal
      ? ['Prioritize lighter sides and chilled drinks today.', 'Reduce fried items slightly to match the weather.']
      : ['Keep one balanced protein item and one fresh side visible.', 'Avoid overloading the plate with repeated starches.'];

    const headline = lighterMeal
      ? 'Lighten the menu for the warm weather.'
      : comfortMeal
        ? 'Lean into comforting, quick-serving dishes.'
        : 'Keep the current mix, but watch repetition. ';

    const reasonParts = [
      weather.kind === 'rain' ? 'Rain is likely to reduce movement and favor warm comfort food.' : `Weather is ${weather.kind} (${weather.temperatureC}°C).`,
      calendarState.examWeek ? 'Exam week suggests demand for faster, filling dishes.' : null,
      calendarState.fest ? 'Fest-day demand tends to spike and needs flexible portions.' : null,
      calendarState.tomorrowHoliday ? 'Tomorrow is a holiday, so today should avoid heavy leftovers.' : null,
      parsed.branchName ? `Branch: ${parsed.branchName}` : null,
    ].filter(Boolean);

    const estimatedWasteKg = Math.max(0, wasteHint + Math.round(menuItems.length * (forecast.expectedHeadcount / parsed.totalStudents) * 0.9));
    const carbonSavedKg = Number((estimatedWasteKg * 2.2).toFixed(1));
    const foodSavedKg = Number(Math.max(0, (menuItems.length * 3) - estimatedWasteKg).toFixed(1));

    ok(res, {
      guidance: {
        date,
        mealSlot,
        branchName: parsed.branchName ?? 'Main Mess',
        headline,
        reason: reasonParts.join(' '),
        weather,
        calendarState,
        forecast,
        recommendedMenuItems: toUnique(recommendedMenuItems).slice(0, 4),
        avoidItems,
        leftoverRouting,
        ingredientFatigue: fatigueNotes,
        healthTips,
        sustainability: {
          estimatedWasteKg,
          foodSavedKg,
          carbonSavedKg,
        },
      },
    }, 'Menu guidance');
  } catch (error) {
    next(error);
  }
};