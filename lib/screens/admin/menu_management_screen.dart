import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _meals = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  final Map<String, Map<String, List<String>>> _menuData = {
    'Monday': {
      'Breakfast': ['Idli', 'Sambhar', 'Chutney'],
      'Lunch': ['Dal Makhani', 'Jeera Rice', 'Roti'],
      'Snacks': ['Tea', 'Samosa'],
      'Dinner': ['Paneer Tikka', 'Naan', 'Raita'],
    },
    'Tuesday': {
      'Breakfast': ['Poha', 'Jalebi', 'Tea'],
      'Lunch': ['Chole', 'Rice', 'Salad'],
      'Snacks': ['Coffee', 'Biscuits'],
      'Dinner': ['Veg Biryani', 'Raita', 'Papad'],
    },
    'Wednesday': {
      'Breakfast': ['Dosa', 'Sambhar', 'Chutney'],
      'Lunch': ['Rajma', 'Rice', 'Roti'],
      'Snacks': ['Tea', 'Pakora'],
      'Dinner': ['Palak Paneer', 'Roti', 'Dal'],
    },
    'Thursday': {
      'Breakfast': ['Upma', 'Chutney', 'Coffee'],
      'Lunch': ['Dal Tadka', 'Rice', 'Papad'],
      'Snacks': ['Tea', 'Bread Pakora'],
      'Dinner': ['Aloo Gobi', 'Roti', 'Rice'],
    },
    'Friday': {
      'Breakfast': ['Paratha', 'Curd', 'Pickle'],
      'Lunch': ['Chana Masala', 'Rice', 'Roti'],
      'Snacks': ['Coffee', 'Namkeen'],
      'Dinner': ['Veg Pulao', 'Raita', 'Papad'],
    },
    'Saturday': {
      'Breakfast': ['Puri', 'Bhaji', 'Halwa'],
      'Lunch': ['Special Thali', 'Sweet'],
      'Snacks': ['Tea', 'Cake'],
      'Dinner': ['Paneer Butter Masala', 'Naan'],
    },
    'Sunday': {
      'Breakfast': ['Bread', 'Omelette', 'Juice'],
      'Lunch': ['Chicken Curry', 'Rice', 'Salad'],
      'Snacks': ['Tea', 'Cookies'],
      'Dinner': ['Mix Veg', 'Roti', 'Dal'],
    },
  };

  String? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.60),
                          border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.pop(),
                            child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF334155)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Menu Planning', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  GlassCard(
                    tint: GlassTint.purple,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF3E8FF).withOpacity(0.70),
                            border: Border.all(color: const Color(0xFFE9D5FF), width: 0.5),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF9F7AEA).withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.sparkles, size: 20, color: Color(0xFF7E22CE)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AI Suggestion', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF581C87))),
                              const SizedBox(height: 4),
                              const Text('Weather forecast: 38°C. Consider lighter meals and cold beverages for Thursday.', style: TextStyle(fontSize: 12, color: Color(0xFF6B21A8))),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {},
                                child: const Text('Apply Suggestion →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF7E22CE))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('WEEKLY MENU GRID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final day = _days[index];
                  final isSelected = _selectedDay == day;
                  final itemCount = _menuData[day]!.values.fold<int>(0, (sum, items) => sum + items.length);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _selectedDay = isSelected ? null : day),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                        const SizedBox(width: 12),
                                        StatusPill(text: '$itemCount items', variant: StatusVariant.info),
                                      ],
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: isSelected ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(LucideIcons.chevronDown, size: 20, color: Color(0xFF334155)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.20))),
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children: _meals.map((meal) {
                                  final dishes = _menuData[day]![meal]!;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(meal.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.50),
                                                border: Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(12),
                                                  onTap: () {},
                                                  child: const Icon(LucideIcons.plus, size: 14, color: Color(0xFF334155)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: dishes.map((dish) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.50),
                                                border: Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
                                                ],
                                              ),
                                              child: Text(dish, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.70),
                    foregroundColor: const Color(0xFF1D4ED8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF93C5FD), width: 0.5),
                    ),
                  ),
                  child: const Text('Publish Menu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
