import { Request, Response, NextFunction } from 'express';
import { prisma } from '../../config/prisma';
import { ok } from '../../utils/apiResponse';
import { getCurrentMealSlot, todayDate } from '../../utils/mealWindow';

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

    // Fetch predicted baseline for comparison
    const prediction = await prisma.predictionData.findUnique({
      where: {
        mealDate_mealSlot: { mealDate, mealSlot }
      }
    });

    return ok(res, {
        mealSlot,
        mealDate,
        heatmap: sortedHeatmap,
        prediction: prediction?.predictedCount || 0
    }, 'Live Heatmap Analytics');
  } catch (error) {
    next(error);
  }
};