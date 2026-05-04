import { prisma } from '../../config/prisma';
import { env } from '../../config/env';

const OLLAMA_BASE_URL = env.OLLAMA_BASE_URL;
const OLLAMA_MODEL = env.OLLAMA_MODEL;

const formatDate = (date: Date) => {
  const y = date.getFullYear().toString().padStart(4, '0');
  const m = (date.getMonth() + 1).toString().padStart(2, '0');
  const d = date.getDate().toString().padStart(2, '0');
  return `${y}-${m}-${d}`;
};

const formatMealSlot = (slot: string) => {
  switch (slot) {
    case 'BREAKFAST':
      return 'Breakfast';
    case 'LUNCH':
      return 'Lunch';
    case 'SNACKS':
      return 'Snacks';
    case 'DINNER':
      return 'Dinner';
    default:
      return slot;
  }
};

const getTodayMenuSummary = async () => {
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);

  const menus = await prisma.menu.findMany({
    where: { menuDate: today, isPublished: true },
    include: { menuItems: { include: { dish: true } } },
    orderBy: { mealSlot: 'asc' },
  });

  if (menus.length === 0) {
    return `No published menu for ${formatDate(today)}.`;
  }

  const lines = menus.map((menu) => {
    const dishes = menu.menuItems.map((item) => item.dish.name).join(', ');
    return `${formatMealSlot(menu.mealSlot)}: ${dishes}`;
  });

  return `Menu for ${formatDate(today)}:\n${lines.join('\n')}`;
};

export const answerQuestion = async (message: string) => {
  const menuSummary = await getTodayMenuSummary();
  const systemPrompt = [
    'You are a friendly mess management assistant for students.',
    'Answer concisely and only use the provided menu data.',
    'If the question is unrelated, say you can only answer menu questions.',
    `Context:\n${menuSummary}`,
  ].join('\n');

  const payload = {
    model: OLLAMA_MODEL,
    stream: false,
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: message },
    ],
  };

  const response = await fetch(`${OLLAMA_BASE_URL}/api/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    throw new Error(`Ollama request failed: ${response.status}`);
  }

  const data = await response.json();
  const text = data?.message?.content as string | undefined;
  if (!text) {
    throw new Error('Empty response from model');
  }

  return { reply: text, menuSummary };
};
