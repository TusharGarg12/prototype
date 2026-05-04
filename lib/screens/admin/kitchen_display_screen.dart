import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/services/menu_service.dart';
import '../../core/services/analytics_service.dart';

class KitchenDisplayScreen extends StatefulWidget {
  final String userRole;
  
  const KitchenDisplayScreen({super.key, this.userRole = 'admin'});

  @override
  State<KitchenDisplayScreen> createState() => _KitchenDisplayScreenState();
}

class _KitchenDisplayScreenState extends State<KitchenDisplayScreen> {
  bool _showLogoutConfirm = false;
  bool _isLoading = true;
  Timer? _refreshTimer;
  DateTime? _lastUpdated;
  String _activeSlotLabel = 'Current meal';

  List<Map<String, dynamic>> _dishes = [];
  int currentOccupancy = 0;
  int peakOccupancy = 500;

  @override
  void initState() {
    super.initState();
    _fetchLiveKdsData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchLiveKdsData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLiveKdsData() async {
    try {
      final menus = await menuService.getTodayMenu();
      if (menus.isEmpty) {
        if (mounted) {
          setState(() {
            _dishes = [];
            _isLoading = false;
            _lastUpdated = DateTime.now();
          });
        }
        return;
      }
      final activeSlot = _currentMealSlot();
      final activeMenu = menus.firstWhere(
        (menu) => menu.mealSlot == activeSlot,
        orElse: () => menus.first,
      );

      int activeCount = 0;
      int maxCount = 0;
      try {
        final today = _formatDate(DateTime.now());
        final footfallSummary = await analyticsService.getFootfallSummary(date: today);
        activeCount = _countForSlot(footfallSummary, activeSlot);
        maxCount = _maxCount(footfallSummary);
      } catch (_) {
        activeCount = 0;
        maxCount = 0;
      }

      final dishCount = activeMenu.dishes.length;
      final perDishServed = dishCount == 0 ? 0 : (activeCount / dishCount).floor();
      final List<Map<String, dynamic>> newDishes = activeMenu.dishes.map((dish) {
        final quantity = 200;
        final served = perDishServed.clamp(0, quantity);
        final remainingRatio = (quantity - served) / quantity;
        final status = _statusFromRemaining(remainingRatio);
        return {
          'name': dish.name,
          'quantity': quantity,
          'served': served,
          'status': status,
        };
      }).toList();

      setState(() {
        _dishes = newDishes;
        currentOccupancy = activeCount;
        peakOccupancy = maxCount > 0 ? maxCount : activeCount;
        _activeSlotLabel = _mealSlotLabel(activeSlot);
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _currentMealSlot() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= 7 && hour < 10) return 'BREAKFAST';
    if (hour >= 12 && hour < 15) return 'LUNCH';
    if (hour >= 16 && hour < 18) return 'SNACKS';
    if (hour >= 19 && hour < 22) return 'DINNER';
    return 'LUNCH';
  }

  String _mealSlotLabel(String slot) {
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

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  int _countForSlot(List<Map<String, dynamic>> summary, String slot) {
    for (final item in summary) {
      if (item['mealSlot'] == slot) {
        return (item['count'] as num?)?.toInt() ?? 0;
      }
    }
    return 0;
  }

  int _maxCount(List<Map<String, dynamic>> summary) {
    int maxCount = 0;
    for (final item in summary) {
      final count = (item['count'] as num?)?.toInt() ?? 0;
      if (count > maxCount) maxCount = count;
    }
    return maxCount;
  }

  String _statusFromRemaining(double remainingRatio) {
    if (remainingRatio <= 0.05) return 'out';
    if (remainingRatio <= 0.2) return 'delayed';
    if (remainingRatio <= 0.45) return 'ready';
    return 'serving';
  }

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.userRole == 'admin')
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
                            )
                          else
                            const SizedBox(width: 40),
                            
                          const Text('Kitchen Display', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          
                          if (widget.userRole == 'kitchen')
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.60),
                                border: Border.all(color: const Color(0xFFFDA4AF), width: 0.5),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFFFDA4AF).withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => setState(() => _showLogoutConfirm = true),
                                  child: const Icon(LucideIcons.logOut, size: 20, color: Color(0xFFE11D48)),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      GlassCard(
                        level: GlassLevel.level3,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.70),
                                    border: Border.all(color: Colors.white.withOpacity(0.80), width: 0.5),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(LucideIcons.users, size: 24, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Current Crowd', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                    const SizedBox(height: 4),
                                    Text('$currentOccupancy', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                                    const SizedBox(height: 4),
                                    Text(_activeSlotLabel, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Peak Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                const SizedBox(height: 4),
                                Text('$peakOccupancy', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                                const SizedBox(height: 4),
                                Text(
                                  _lastUpdated == null ? 'Updating...' : 'Updated ${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (_dishes.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No menu published for this meal slot', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _dishes.length,
                      itemBuilder: (context, index) {
                        final dish = _dishes[index];
                        final percentage = (dish['served'] / dish['quantity']);
                        final status = dish['status'] as String;

                        GlassTint tint;
                        StatusVariant variant;
                        String label;
                        Color progressColor;
                        String subtitle;

                        switch (status) {
                          case 'serving':
                            tint = GlassTint.success;
                            variant = StatusVariant.success;
                            label = 'SERVING';
                            progressColor = const Color(0xFF10B981);
                            subtitle = '${((1 - percentage) * 100).toStringAsFixed(0)}% remaining';
                            break;
                          case 'ready':
                            tint = GlassTint.info;
                            variant = StatusVariant.info;
                            label = 'READY';
                            progressColor = const Color(0xFF3B82F6);
                            subtitle = '${((1 - percentage) * 100).toStringAsFixed(0)}% remaining';
                            break;
                          case 'delayed':
                            tint = GlassTint.warning;
                            variant = StatusVariant.warning;
                            label = 'DELAYED';
                            progressColor = const Color(0xFFF59E0B);
                            subtitle = 'Prep in progress';
                            break;
                          case 'out':
                          default:
                            tint = GlassTint.danger;
                            variant = StatusVariant.danger;
                            label = 'OUT';
                            progressColor = const Color(0xFFF43F5E);
                            subtitle = 'Refill needed';
                            break;
                        }

                        return GlassCard(
                          tint: tint,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatusPill(text: label, variant: variant),
                              const Spacer(),
                              Text(dish['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('${dish['served']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                                  const SizedBox(width: 4),
                                  Text('/ ${dish['quantity']}', style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: percentage.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: progressColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildLegendItem(const Color(0xFF10B981), 'Serving'),
                      const SizedBox(width: 12),
                      _buildLegendItem(const Color(0xFF3B82F6), 'Ready'),
                      const SizedBox(width: 12),
                      _buildLegendItem(const Color(0xFFF59E0B), 'Delayed'),
                      const SizedBox(width: 12),
                      _buildLegendItem(const Color(0xFFF43F5E), 'Out'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (_showLogoutConfirm)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showLogoutConfirm = false),
                child: Container(
                  color: const Color(0xFF0F172A).withOpacity(0.4),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () {},
                    child: GlassCard(
                      level: GlassLevel.level4,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFE4E6).withOpacity(0.70),
                              border: Border.all(color: const Color(0xFFFECDD3), width: 0.5),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFFDA4AF).withOpacity(0.20), blurRadius: 24, offset: const Offset(0, 8)),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(LucideIcons.logOut, size: 32, color: Color(0xFFE11D48)),
                          ),
                          const Text('Sign Out?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          const SizedBox(height: 8),
                          const Text(
                            'Are you sure you want to sign out of your kitchen account?',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Color(0xFF334155)),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () => setState(() => _showLogoutConfirm = false),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.60),
                                      foregroundColor: const Color(0xFF334155),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: BorderSide(color: Colors.white.withOpacity(0.70), width: 0.5),
                                      ),
                                    ),
                                    child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() => _showLogoutConfirm = false);
                                      context.go('/login');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.70),
                                      foregroundColor: const Color(0xFFE11D48),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: const BorderSide(color: Color(0xFFFDA4AF), width: 0.5),
                                      ),
                                    ),
                                    child: const Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
      ],
    );
  }
}
