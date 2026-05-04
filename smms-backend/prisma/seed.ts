import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { Role, MealSlot } from '../src/config/enums';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding SMMS database...\n');

  // ── Admin user ──────────────────────────────────────────────────────────────
  const admin = await prisma.user.upsert({
    where: { email: 'admin@smms.edu' },
    update: {},
    create: {
      email: 'admin@smms.edu',
      name: 'Mess Admin',
      role: Role.ADMIN,
    },
  });
  console.log(`✅ Admin user: ${admin.email}`);

  // ── Kitchen Staff ───────────────────────────────────────────────────────────
  const kitchen = await prisma.user.upsert({
    where: { email: 'kitchen@smms.edu' },
    update: {},
    create: {
      email: 'kitchen@smms.edu',
      name: 'Kitchen Staff',
      role: Role.KITCHEN_STAFF,
    },
  });
  console.log(`✅ Kitchen staff: ${kitchen.email}`);

  // ── Sample students ─────────────────────────────────────────────────────────
  const students = [
    { email: 'student1@smms.edu', name: 'Tushar Garg',    rollNumber: 'IEC2023059' },
    { email: 'student2@smms.edu', name: 'Rahul Sharma',   rollNumber: 'IEC2023060' },
    { email: 'student3@smms.edu', name: 'Priya Mehta',    rollNumber: 'IEC2023061' },
  ];

  for (const s of students) {
    const u = await prisma.user.upsert({
      where: { email: s.email },
      update: {},
      create: { ...s, role: Role.STUDENT },
    });
    console.log(`✅ Student: ${u.email} (${u.rollNumber})`);
  }

  // ── Sample dishes ───────────────────────────────────────────────────────────
  const dishData = [
    { name: 'Idli Sambar',    category: 'Main',    isVeg: true  },
    { name: 'Poha',           category: 'Main',    isVeg: true  },
    { name: 'Masala Chai',    category: 'Drink',   isVeg: true  },
    { name: 'Dal Tadka',      category: 'Main',    isVeg: true  },
    { name: 'Jeera Rice',     category: 'Main',    isVeg: true  },
    { name: 'Roti',           category: 'Side',    isVeg: true  },
    { name: 'Paneer Butter Masala', category: 'Main', isVeg: true },
    { name: 'Samosa',         category: 'Starter', isVeg: true  },
    { name: 'Chicken Curry',  category: 'Main',    isVeg: false },
    { name: 'Khichdi',        category: 'Main',    isVeg: true  },
    { name: 'Raita',          category: 'Side',    isVeg: true  },
    { name: 'Gulab Jamun',    category: 'Dessert', isVeg: true  },
  ];

  const dishes: Record<string, string> = {};
  for (const d of dishData) {
    const dish = await prisma.dish.create({ data: d });
    dishes[d.name] = dish.id;
    console.log(`✅ Dish: ${dish.name}`);
  }

  // ── Today's menu ────────────────────────────────────────────────────────────
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);

  const menus = [
    {
      mealSlot: MealSlot.BREAKFAST,
      dishNames: ['Idli Sambar', 'Poha', 'Masala Chai'],
    },
    {
      mealSlot: MealSlot.LUNCH,
      dishNames: ['Dal Tadka', 'Jeera Rice', 'Roti', 'Paneer Butter Masala', 'Raita'],
    },
    {
      mealSlot: MealSlot.SNACKS,
      dishNames: ['Samosa', 'Masala Chai'],
    },
    {
      mealSlot: MealSlot.DINNER,
      dishNames: ['Chicken Curry', 'Khichdi', 'Roti', 'Gulab Jamun'],
    },
  ];

  for (const m of menus) {
    await prisma.menu.upsert({
      where: { mealSlot_menuDate: { mealSlot: m.mealSlot, menuDate: today } },
      update: {},
      create: {
        mealSlot: m.mealSlot,
        menuDate: today,
        isPublished: true,
        createdById: admin.id,
        menuItems: {
          create: m.dishNames.map(name => ({ dishId: dishes[name] })),
        },
      },
    });
    console.log(`✅ Menu: ${m.mealSlot} for ${today.toDateString()}`);
  }

  // ── Sample inventory with meal mappings ─────────────────────────────────────
  const inventoryItems = [
    {
      name: 'Rice',
      unit: 'kg',
      currentStock: 50,
      lowStockLevel: 10,
      mealMappings: [
        { mealSlot: MealSlot.LUNCH,  portionQty: 0.15 },
        { mealSlot: MealSlot.DINNER, portionQty: 0.15 },
      ],
    },
    {
      name: 'Dal (Lentils)',
      unit: 'kg',
      currentStock: 20,
      lowStockLevel: 5,
      mealMappings: [
        { mealSlot: MealSlot.LUNCH,  portionQty: 0.1 },
        { mealSlot: MealSlot.DINNER, portionQty: 0.1 },
      ],
    },
    {
      name: 'Milk',
      unit: 'litres',
      currentStock: 30,
      lowStockLevel: 5,
      mealMappings: [
        { mealSlot: MealSlot.BREAKFAST, portionQty: 0.2 },
      ],
    },
  ];

  for (const item of inventoryItems) {
    const created = await prisma.inventoryItem.create({
      data: {
        name: item.name,
        unit: item.unit,
        currentStock: item.currentStock,
        lowStockLevel: item.lowStockLevel,
        lastEditedById: admin.id,
        mealMappings: { create: item.mealMappings },
      },
    });
    console.log(`✅ Inventory: ${created.name} (${created.currentStock} ${created.unit})`);
  }

  console.log('\n✨ Seeding complete!');
  console.log('\n📋 Test credentials (use OTP console output to login):');
  console.log('   Admin:   admin@smms.edu');
  console.log('   Student: student1@smms.edu');
  console.log('   Kitchen: kitchen@smms.edu\n');
}

main()
  .catch(e => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
