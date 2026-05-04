import { MealSlot } from '../config/enums';

export interface MealWindow {
  slot: MealSlot;
  label: string;
  startHour: number; // 24h
  endHour: number;   // 24h (exclusive)
}

export const MEAL_WINDOWS: MealWindow[] = [
  { slot: MealSlot.BREAKFAST, label: 'Breakfast', startHour: 7,  endHour: 10 },
  { slot: MealSlot.LUNCH,     label: 'Lunch',     startHour: 12, endHour: 15 },
  { slot: MealSlot.SNACKS,    label: 'Snacks',    startHour: 16, endHour: 18 },
  { slot: MealSlot.DINNER,    label: 'Dinner',    startHour: 19, endHour: 22 },
];

/** Returns the current meal slot based on server time, or null if outside all windows. */
export const getCurrentMealSlot = (): MealSlot | null => {
  const hour = new Date().getHours();
  const window = MEAL_WINDOWS.find(w => hour >= w.startHour && hour < w.endHour);
  return window ? window.slot : null;
};

/** Returns today's date at midnight UTC for date-only DB comparisons. */
export const todayDate = (): Date => {
  const d = new Date();
  d.setUTCHours(0, 0, 0, 0);
  return d;
};

/** QR pass expiry = now + QR_WINDOW_MINUTES (default 30). */
export const qrExpiresAt = (windowMinutes = 30): Date =>
  new Date(Date.now() + windowMinutes * 60 * 1000);
