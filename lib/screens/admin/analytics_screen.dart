import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/menu_service.dart';
import '../../core/services/optimization_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  bool _isLoadingHeatmap = true;
  final AnalyticsService _analyticsService = analyticsService;
  final MenuService _menuService = menuService;
  final OptimizationService _optimizationService = optimizationService;
  List<Map<String, dynamic>> _heatmapData = [];
  List<Map<String, dynamic>> _weeklyData = [];
  List<Map<String, dynamic>> _ratingSummary = [];
  List<Map<String, dynamic>> _predictions = [];
  Map<String, dynamic>? _wasteRecommendation;
  Map<String, dynamic>? _menuGuidance;
  int _totalMeals = 0;
  double? _avgRating;
  final List<DateTime> _days = [];

  @override
  void initState() {
    super.initState();
    _days.addAll(_buildWeek());
    _loadAnalytics();
  }

  List<DateTime> _buildWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List<DateTime>.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _dayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatCompactNumber(int value) {
    if (value >= 1000) {
      final compact = (value / 1000).toStringAsFixed(1);
      return '${compact}K';
    }
    return value.toString();
  }

  String _formatMealSlot(String slot) {
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

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _isLoadingHeatmap = true;
    });

    final todayKey = _dateKey(DateTime.now());

    try {
      final heatmap = await _analyticsService.getHeatmap(date: todayKey);
      if (mounted) {
        setState(() {
          _heatmapData = heatmap;
          _isLoadingHeatmap = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingHeatmap = false);
      }
    }

    try {
      final weeklyData = <Map<String, dynamic>>[];
      int totalMeals = 0;

      for (final date in _days) {
        final summary = await _analyticsService.getFootfallSummary(date: _dateKey(date));
        final counts = {
          'BREAKFAST': 0,
          'LUNCH': 0,
          'DINNER': 0,
          'SNACKS': 0,
        };
        for (final item in summary) {
          final slot = item['mealSlot'] as String?;
          final count = (item['count'] as num?)?.toInt() ?? 0;
          if (slot != null) counts[slot] = count;
        }

        totalMeals += counts.values.fold<int>(0, (sum, value) => sum + value);

        weeklyData.add({
          'day': _dayLabel(date),
          'breakfast': counts['BREAKFAST'] ?? 0,
          'lunch': counts['LUNCH'] ?? 0,
          'dinner': counts['DINNER'] ?? 0,
        });
      }

      final ratings = await _analyticsService.getRatingSummary(date: todayKey);
      final predictions = await _analyticsService.getPredictions(days: 7, start: todayKey);
      double totalRating = 0;
      int ratingCount = 0;
      for (final item in ratings) {
        final avg = (item['avgRating'] as num?)?.toDouble();
        final count = (item['count'] as num?)?.toInt() ?? 0;
        if (avg != null && count > 0) {
          totalRating += avg * count;
          ratingCount += count;
        }
      }

      final todayMenus = await _menuService.getTodayMenu();
      final menuItems = todayMenus.expand((menu) => menu.dishes).map((dish) => dish.name).toList();
      final wastePlan = await _optimizationService.getWasteRecommendation(
        date: todayKey,
        mealSlot: 'LUNCH',
        menuItems: menuItems.isEmpty ? ['Rice', 'Dal', 'Vegetables'] : menuItems,
        totalStudents: _totalMeals > 0 ? _totalMeals : 600,
        totalCapacity: 600,
      );
      final guidancePlan = await _optimizationService.getMenuGuidance(
        date: todayKey,
        mealSlot: 'LUNCH',
        menuItems: menuItems.isEmpty ? ['Rice', 'Dal', 'Vegetables'] : menuItems,
        branchName: 'Main Mess',
      );

      if (mounted) {
        setState(() {
          _weeklyData = weeklyData;
          _totalMeals = totalMeals;
          _ratingSummary = ratings;
          _predictions = predictions;
          _avgRating = ratingCount > 0 ? totalRating / ratingCount : null;
          _wasteRecommendation = (wastePlan['recommendation'] as Map<String, dynamic>?) ?? wastePlan;
          _menuGuidance = (guidancePlan['guidance'] as Map<String, dynamic>?) ?? guidancePlan;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final maxValue = _weeklyData.isEmpty
      ? 1
      : _weeklyData
          .expand((d) => [d['breakfast'] as int, d['lunch'] as int, d['dinner'] as int])
          .reduce((a, b) => a > b ? a : b);
    final menuGuidance = (_menuGuidance ?? const <String, dynamic>{});
    final sustainability = menuGuidance['sustainability'] as Map<String, dynamic>?;
    final wasteRecommendation = _wasteRecommendation ?? const <String, dynamic>{};
    final estimatedWasteKg = (sustainability?['estimatedWasteKg'] as num?)?.toDouble() ?? (wasteRecommendation['estimatedWasteKg'] as num?)?.toDouble() ?? 0;
    final foodSavedKg = (sustainability?['foodSavedKg'] as num?)?.toDouble() ?? (_totalMeals / 100.0);
    final carbonSavedKg = (sustainability?['carbonSavedKg'] as num?)?.toDouble() ?? estimatedWasteKg * 2.2;
    final leftoverRouting = (menuGuidance['leftoverRouting'] as List<dynamic>?) ?? const [];
    final ingredientFatigue = (menuGuidance['ingredientFatigue'] as List<dynamic>?) ?? const [];
    final healthTips = (menuGuidance['healthTips'] as List<dynamic>?) ?? const [];
    final recommendedMenuItems = (menuGuidance['recommendedMenuItems'] as List<dynamic>?) ?? const [];
    final guidanceHeadline = menuGuidance['headline'] as String?;
    final guidanceReason = menuGuidance['reason'] as String?;

    return GlobalGlassScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          const Text('Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                        ],
                      ),
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
                            onTap: () {},
                            child: const Icon(LucideIcons.download, size: 20, color: Color(0xFF334155)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL MEALS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(_formatCompactNumber(_totalMeals), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(LucideIcons.calendar, size: 12, color: Color(0xFF64748B)),
                                  SizedBox(width: 4),
                                  Text('Last 7 days', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AVG RATING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(
                                _avgRating == null ? 'N/A' : _avgRating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(LucideIcons.messageSquare, size: 12, color: Color(0xFF64748B)),
                                  SizedBox(width: 4),
                                  Text('Today', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('WASTE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 1)),
                              const SizedBox(height: 4),
                              const Text('N/A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(LucideIcons.info, size: 12, color: Color(0xFF94A3B8)),
                                  SizedBox(width: 4),
                                  Text('Not tracked', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Weekly Footfall', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                              Row(
                                children: [
                                  _buildLegendItem(const Color(0xFF60A5FA), 'Breakfast'),
                                  const SizedBox(width: 8),
                                  _buildLegendItem(const Color(0xFF34D399), 'Lunch'),
                                  const SizedBox(width: 8),
                                  _buildLegendItem(const Color(0xFFFBBF24), 'Dinner'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_isLoading)
                            const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
                          else if (_weeklyData.isEmpty)
                            const SizedBox(height: 160, child: Center(child: Text('No attendance data', style: TextStyle(color: Color(0xFF64748B)))))
                          else
                            SizedBox(
                              height: 160,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: _weeklyData.map((data) {
                                  return Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 32,
                                          child: Text(data['day'], style: const TextStyle(fontSize: 9, color: Color(0xFF334155))),
                                        ),
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: FractionallySizedBox(
                                                  heightFactor: (data['breakfast'] / maxValue).clamp(0.05, 1.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF60A5FA).withOpacity(0.30),
                                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 1),
                                              Expanded(
                                                child: FractionallySizedBox(
                                                  heightFactor: (data['lunch'] / maxValue).clamp(0.05, 1.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF34D399).withOpacity(0.30),
                                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 1),
                                              Expanded(
                                                child: FractionallySizedBox(
                                                  heightFactor: (data['dinner'] / maxValue).clamp(0.05, 1.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFBBF24).withOpacity(0.30),
                                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildLiveHeatmapCard(),
                    const SizedBox(height: 16),

                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ratings Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          const SizedBox(height: 16),
                          if (_ratingSummary.isEmpty)
                            const Text('No ratings yet', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))
                          else
                            Column(
                              children: _ratingSummary.map((summary) {
                                final mealSlot = _formatMealSlot(summary['mealSlot'] as String);
                                final avg = (summary['avgRating'] as num?)?.toDouble();
                                final count = (summary['count'] as num?)?.toInt() ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(mealSlot, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                            const SizedBox(height: 4),
                                            Text('$count ratings', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        avg == null ? 'N/A' : avg.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Forecast (Next 7 Days)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          const SizedBox(height: 12),
                          if (_predictions.isEmpty)
                            const Text('No predictions available', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))
                          else
                            Column(
                              children: _groupPredictions(_predictions).entries.map((entry) {
                                final date = entry.key;
                                final rows = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 8),
                                        Column(
                                          children: rows.map((row) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 6),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(_formatMealSlot(row['mealSlot'] as String), style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                                  Text('${row['predictedCount']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          rows.first['scenario'] as String,
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    GlassCard(
                      tint: GlassTint.success,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sustainability Metrics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF064E3B))),
                              StatusPill(text: _menuGuidance == null ? 'Loading' : 'Live', variant: StatusVariant.success),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Food Saved', style: TextStyle(fontSize: 12, color: Color(0xFF065F46))),
                                    SizedBox(height: 4),
                                    Text('${foodSavedKg.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF064E3B))),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('CO2 Avoided', style: TextStyle(fontSize: 12, color: Color(0xFF065F46))),
                                    SizedBox(height: 4),
                                    Text('${carbonSavedKg.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF064E3B))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _menuGuidance == null
                                ? 'Loading waste and sustainability insights...'
                                : 'Estimated waste: ${estimatedWasteKg.toStringAsFixed(1)} kg',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF065F46)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Planning Insights', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          const SizedBox(height: 12),
                          Text(
                            guidanceHeadline ?? 'Live menu guidance will appear here once loaded.',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                          if (guidanceReason != null) ...[
                            const SizedBox(height: 6),
                            Text(guidanceReason, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                          if (recommendedMenuItems.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: recommendedMenuItems.take(4).map((item) {
                                return StatusPill(text: item as String, variant: StatusVariant.info);
                              }).toList(),
                            ),
                          ],
                          if (leftoverRouting.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text('Leftover routing: ${leftoverRouting.first as String}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          ],
                          if (ingredientFatigue.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text('Ingredient fatigue: ${ingredientFatigue.join(' · ')}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          ],
                          if (healthTips.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text('Health tip: ${healthTips.first as String}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Peak Hours Analysis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          const SizedBox(height: 16),
                          _buildPeakHourRow('Breakfast Peak', '8:30 - 9:00 AM'),
                          const SizedBox(height: 8),
                          _buildPeakHourRow('Lunch Peak', '12:30 - 1:00 PM'),
                          const SizedBox(height: 8),
                          _buildPeakHourRow('Dinner Peak', '7:00 - 7:30 PM'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveHeatmapCard() {
    if (_isLoadingHeatmap) {
      return const GlassCard(
        padding: EdgeInsets.all(16),
        child: SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
      );
    }
    if (_heatmapData.isEmpty) {
      return const GlassCard(
        padding: EdgeInsets.all(16),
        child: SizedBox(height: 160, child: Center(child: Text('No Live Crowd Data', style: TextStyle(color: Color(0xFF64748B))))),
      );
    }

    int maxScans = 1;
    for (var bucket in _heatmapData) {
      final c = (bucket['count'] as num?)?.toInt() ?? 0;
      if (c > maxScans) maxScans = c;
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Live Crowd Heatmap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              Row(
                children: [
                  const Icon(LucideIcons.radioReceiver, size: 12, color: Color(0xFFEF4444)),
                  const SizedBox(width: 4),
                  const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _heatmapData.map((data) {
                final heightFactor = (((data['count'] as num?)?.toDouble() ?? 0) / maxScans).clamp(0.05, 1.0);
                Color barColor = const Color(0xFF34D399); // Safe
                if (heightFactor > 0.75) {
                  barColor = const Color(0xFFEF4444); // Surge/Crowded
                } else if (heightFactor > 0.4) {
                  barColor = const Color(0xFFFBBF24); // Medium
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: heightFactor,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: barColor.withOpacity(0.8),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (data['time'] as String?)?.substring(0, 5) ?? '', // e.g. "12:30"
                          style: const TextStyle(fontSize: 8, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF334155))),
      ],
    );
  }

  Widget _buildPeakHourRow(String label, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
        Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupPredictions(List<Map<String, dynamic>> items) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in items) {
      final date = item['date'] as String? ?? 'Unknown';
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(item);
    }
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => _mealOrder(a['mealSlot'] as String).compareTo(_mealOrder(b['mealSlot'] as String)));
    }
    return grouped;
  }

  int _mealOrder(String slot) {
    switch (slot) {
      case 'BREAKFAST':
        return 0;
      case 'LUNCH':
        return 1;
      case 'SNACKS':
        return 2;
      case 'DINNER':
        return 3;
      default:
        return 4;
    }
  }
}
