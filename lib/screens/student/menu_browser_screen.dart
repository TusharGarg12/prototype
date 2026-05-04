import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/models/menu_model.dart';
import '../../core/services/menu_service.dart';

class MenuBrowserScreen extends StatefulWidget {
  const MenuBrowserScreen({super.key});
  @override
  State<MenuBrowserScreen> createState() => _MenuBrowserScreenState();
}

class _MenuBrowserScreenState extends State<MenuBrowserScreen> {
  List<MenuModel> _weeklyMenus = [];
  bool _loading = true;
  int _selectedDayOffset = 0; // days from today
  String _selectedSlot = 'LUNCH';

  final List<String> _slots = ['BREAKFAST', 'LUNCH', 'SNACKS', 'DINNER'];
  final List<String> _slotLabels = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    try {
      final menus = await menuService.getWeeklyMenu();
      if (mounted) setState(() { _weeklyMenus = menus; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<DishModel> _currentDishes() {
    final targetDate = DateTime.now().add(Duration(days: _selectedDayOffset));
    final targetDay = DateTime(targetDate.year, targetDate.month, targetDate.day);

    final menu = _weeklyMenus.where((m) {
      final d = DateTime(m.menuDate.year, m.menuDate.month, m.menuDate.day);
      return d == targetDay && m.mealSlot == _selectedSlot;
    }).firstOrNull;

    return menu?.dishes ?? [];
  }

  String _dayLabel(int offset) {
    if (offset == 0) return 'Today';
    if (offset == 1) return 'Tomorrow';
    final d = DateTime.now().add(Duration(days: offset));
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  static const List<Color> _dishColors = [
    Color(0xFFFBBF24), Color(0xFFF97316), Color(0xFF84CC16),
    Color(0xFF22C55E), Color(0xFF60A5FA), Color(0xFFA78BFA),
    Color(0xFFF472B6), Color(0xFFEAB308),
  ];

  @override
  Widget build(BuildContext context) {
    final dishes = _currentDishes();

    return GlobalGlassScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.60),
                      border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
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
                  const Text('Weekly Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                ],
              ),
            ),

            // Day selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(7, (i) {
                  final isSelected = _selectedDayOffset == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDayOffset = i),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.70) : Colors.white.withOpacity(0.60),
                          border: Border.all(color: isSelected ? Colors.white.withOpacity(0.80) : Colors.white.withOpacity(0.70), width: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04), blurRadius: isSelected ? 16 : 8, offset: Offset(0, isSelected ? 4 : 2))],
                        ),
                        child: Text(_dayLabel(i), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569))),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Meal slot selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_slots.length, (i) {
                  final isSelected = _selectedSlot == _slots[i];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == _slots.length - 1 ? 0 : 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedSlot = _slots[i]),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.70) : Colors.white.withOpacity(0.60),
                            border: Border.all(color: isSelected ? Colors.white.withOpacity(0.80) : Colors.white.withOpacity(0.70), width: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04), blurRadius: isSelected ? 16 : 8, offset: Offset(0, isSelected ? 4 : 2))],
                          ),
                          child: Text(_slotLabels[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569))),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Dishes
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : dishes.isEmpty
                  ? const Center(child: Text('No menu published for this slot', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
                      ),
                      itemCount: dishes.length,
                      itemBuilder: (context, index) {
                        final dish = dishes[index];
                        final color = _dishColors[index % _dishColors.length];
                        return GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  dish.name.split(' ').first,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(dish.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(dish.category, style: const TextStyle(fontSize: 9, color: Color(0xFF475569))),
                              const Spacer(),
                              Row(
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(
                                      color: dish.isVeg ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(dish.isVeg ? 'Veg' : 'Non-veg', style: const TextStyle(fontSize: 9, color: Color(0xFF334155))),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
