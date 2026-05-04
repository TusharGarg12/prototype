import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/models/menu_model.dart';
import '../../core/services/dish_service.dart';
import '../../core/services/menu_service.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final List<String> _mealSlots = ['BREAKFAST', 'LUNCH', 'SNACKS', 'DINNER'];
  final List<DateTime> _days = [];
  DateTime? _selectedDay;
  bool _isLoading = true;
  bool _isSaving = false;
  List<DishModel> _dishes = [];
  final Map<String, Map<String, MenuModel>> _menusByDate = {};

  @override
  void initState() {
    super.initState();
    _days.addAll(_buildWeek());
    _selectedDay = _days.isNotEmpty ? _days.first : null;
    _loadData();
  }

  List<DateTime> _buildWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List<DateTime>.generate(7, (i) => today.add(Duration(days: i)));
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _weekdayLabel(DateTime date) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[date.weekday - 1];
  }

  String _mealLabel(String slot) {
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
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _dishes = await dishService.listDishes();
      await Future.wait(_days.map(_fetchMenusForDate));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load menus: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMenusForDate(DateTime date) async {
    final menus = await menuService.queryMenus(date: _dateKey(date));
    final map = <String, MenuModel>{};
    for (final menu in menus) {
      map[menu.mealSlot] = menu;
    }
    _menusByDate[_dateKey(date)] = map;
  }

  MenuModel? _menuFor(DateTime date, String mealSlot) {
    return _menusByDate[_dateKey(date)]?[mealSlot];
  }

  int _countDishesForDay(DateTime date) {
    final dayMenus = _menusByDate[_dateKey(date)]?.values ?? const Iterable<MenuModel>.empty();
    return dayMenus.fold<int>(0, (sum, menu) => sum + menu.dishes.length);
  }

  Future<void> _openMealEditor(DateTime date, String mealSlot) async {
    if (_isSaving) return;
    final menu = _menuFor(date, mealSlot);
    final selected = menu?.dishes.map((d) => d.id).toSet() ?? <String>{};

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_weekdayLabel(date)} • ${_mealLabel(mealSlot)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${selected.length} selected', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _dishes.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        itemBuilder: (context, index) {
                          final dish = _dishes[index];
                          final isSelected = selected.contains(dish.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setSheetState(() {
                                if (value == true) {
                                  selected.add(dish.id);
                                } else {
                                  selected.remove(dish.id);
                                }
                              });
                            },
                            title: Text(dish.name, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                            subtitle: Text(dish.category, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            secondary: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dish.isVeg ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(selected),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Menu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    if (result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one dish.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final MenuModel updated = menu == null
          ? await menuService.createMenu(
              menuDate: date,
              mealSlot: mealSlot,
              dishIds: result.toList(),
              isPublished: false,
            )
          : await menuService.updateMenu(
              id: menu.id,
              dishIds: result.toList(),
            );

      final key = _dateKey(date);
      _menusByDate.putIfAbsent(key, () => <String, MenuModel>{});
      _menusByDate[key]![mealSlot] = updated;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save menu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _publishMenus() async {
    if (_isSaving) return;

    final targets = _selectedDay != null ? [_selectedDay!] : _days;
    final List<MenuModel> toPublish = [];
    for (final date in targets) {
      final menus = _menusByDate[_dateKey(date)]?.values ?? const Iterable<MenuModel>.empty();
      for (final menu in menus) {
        if (!menu.isPublished) toPublish.add(menu);
      }
    }

    if (toPublish.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unpublished menus found.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      for (final menu in toPublish) {
        final updated = await menuService.updateMenu(id: menu.id, isPublished: true);
        final key = _dateKey(menu.menuDate);
        _menusByDate.putIfAbsent(key, () => <String, MenuModel>{});
        _menusByDate[key]![menu.mealSlot] = updated;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menus published successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish menus: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _days.length,
                  itemBuilder: (context, index) {
                    final day = _days[index];
                    final label = _weekdayLabel(day);
                    final isSelected = _selectedDay != null && _dateKey(_selectedDay!) == _dateKey(day);
                    final itemCount = _countDishesForDay(day);

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
                                          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
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
                                  children: _mealSlots.map((slot) {
                                    final menu = _menuFor(day, slot);
                                    final dishes = menu?.dishes ?? const <DishModel>[];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(slot.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
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
                                                    onTap: _isSaving ? null : () => _openMealEditor(day, slot),
                                                    child: const Icon(LucideIcons.plus, size: 14, color: Color(0xFF334155)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (dishes.isEmpty)
                                            const Text('No dishes set yet', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))
                                          else
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
                                                  child: Text(dish.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
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
                  onPressed: _isSaving ? null : _publishMenus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.70),
                    foregroundColor: const Color(0xFF1D4ED8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF93C5FD), width: 0.5),
                    ),
                  ),
                  child: Text(
                    _isSaving ? 'Publishing...' : 'Publish Menu',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
