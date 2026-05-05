import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/services/optimization_service.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  int _selectedScenario = 1;
  bool _isRunning = false;

  Map<int, Map<String, int>> _results = {
    1: {'peakReduction': 0, 'satisfaction': 0, 'wasteReduction': 0, 'revenue': 0},
    2: {'peakReduction': 15, 'satisfaction': 8, 'wasteReduction': 5, 'revenue': 12},
    3: {'peakReduction': 22, 'satisfaction': 12, 'wasteReduction': -3, 'revenue': 8},
    4: {'peakReduction': -5, 'satisfaction': 18, 'wasteReduction': 2, 'revenue': 15},
  };

  final List<Map<String, dynamic>> _scenarios = [
    {'id': 1, 'name': 'Current Plan', 'type': 'baseline'},
    {'id': 2, 'name': 'Add Happy Hour (2-3 PM)', 'type': 'incentive'},
    {'id': 3, 'name': 'Extend Lunch Hours', 'type': 'timing'},
    {'id': 4, 'name': 'Special Menu Day', 'type': 'menu'},
  ];

  Future<void> _handleRunSimulation() async {
    setState(() {
      _isRunning = true;
    });

    try {
      final date = _formatDate(DateTime.now());
      final mealSlot = _currentMealSlot();

      final surgePlan = await optimizationService.getSurgeRecommendation(
        date: date,
        mealSlot: mealSlot,
        totalStudents: 600,
        totalCapacity: 600,
      );
      final forecast = (surgePlan['forecast'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final recommendation = (surgePlan['recommendation'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final occupancyPercent = (recommendation['occupancyPercent'] as num?)?.toDouble() ??
          ((forecast['expectedHeadcount'] as num?)?.toDouble() ?? 0) / 600.0 * 100;

      final wastePlan = await optimizationService.getWasteRecommendation(
        date: date,
        mealSlot: mealSlot,
        menuItems: _scenarioMenuItems(_selectedScenario),
        totalStudents: 600,
        totalCapacity: 600,
      );
      final wasteRecommendation = (wastePlan['recommendation'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final wasteScore = (wasteRecommendation['wasteScore'] as num?)?.toInt() ?? 0;

      final basePeakReduction = occupancyPercent >= 75 ? 24 : occupancyPercent >= 55 ? 18 : 12;
      final satisfactionBoost = (basePeakReduction / 2).round();
      final wasteReduction = (wasteScore / 10).round();
      final revenueImpact = basePeakReduction + (_selectedScenario == 4 ? 3 : 0);

      final updatedResults = <int, Map<String, int>>{
        1: {'peakReduction': 0, 'satisfaction': 0, 'wasteReduction': 0, 'revenue': 0},
        2: {
          'peakReduction': basePeakReduction,
          'satisfaction': satisfactionBoost,
          'wasteReduction': wasteReduction,
          'revenue': revenueImpact,
        },
        3: {
          'peakReduction': basePeakReduction + 7,
          'satisfaction': satisfactionBoost + 4,
          'wasteReduction': wasteReduction - 3,
          'revenue': revenueImpact - 2,
        },
        4: {
          'peakReduction': basePeakReduction - 5,
          'satisfaction': satisfactionBoost + 8,
          'wasteReduction': wasteReduction + 2,
          'revenue': revenueImpact + 4,
        },
      };

      if (!mounted) return;
      setState(() {
        _results = updatedResults;
        _isRunning = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = {
          1: {'peakReduction': 0, 'satisfaction': 0, 'wasteReduction': 0, 'revenue': 0},
          2: {'peakReduction': 15, 'satisfaction': 8, 'wasteReduction': 5, 'revenue': 12},
          3: {'peakReduction': 22, 'satisfaction': 12, 'wasteReduction': -3, 'revenue': 8},
          4: {'peakReduction': -5, 'satisfaction': 18, 'wasteReduction': 2, 'revenue': 15},
        };
        _isRunning = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _currentMealSlot() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'BREAKFAST';
    if (hour < 16) return 'LUNCH';
    if (hour < 18) return 'SNACKS';
    return 'DINNER';
  }

  List<String> _scenarioMenuItems(int scenarioId) {
    switch (scenarioId) {
      case 2:
        return ['Jeera Rice', 'Paneer Curry', 'Curd'];
      case 3:
        return ['Roti', 'Dal Makhani', 'Salad'];
      case 4:
        return ['Special Thali', 'Fruit Bowl', 'Sweet'];
      default:
        return ['Rice', 'Dal', 'Veg Curry'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentResults = _results[_selectedScenario] ?? _results[1]!;

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
                      const Text('Digital Twin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GlassCard(
                    tint: GlassTint.purple,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🔮', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('AI-Powered Simulation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF581C87))),
                              SizedBox(height: 4),
                              Text('Test different scenarios to optimize mess operations before implementation.', style: TextStyle(fontSize: 12, color: Color(0xFF6B21A8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('SELECT SCENARIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    Column(
                      children: _scenarios.map((scenario) {
                        final isSelected = _selectedScenario == scenario['id'];
                        final type = scenario['type'] as String;
                        final variant = type == 'baseline'
                            ? StatusVariant.info
                            : type == 'incentive'
                                ? StatusVariant.warning
                                : type == 'timing'
                                    ? StatusVariant.purple
                                    : StatusVariant.success;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedScenario = scenario['id'] as int),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected ? Border.all(color: const Color(0xFF60A5FA), width: 2) : null,
                              ),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                backgroundColor: isSelected ? Colors.white.withOpacity(0.70) : null,
                                borderColor: isSelected ? Colors.white.withOpacity(0.80) : null,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(scenario['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 4),
                                        StatusPill(text: type, variant: variant),
                                      ],
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF3B82F6),
                                        ),
                                        child: const Icon(Icons.check, size: 16, color: Colors.white),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _handleRunSimulation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.70),
                          foregroundColor: const Color(0xFF1D4ED8),
                          disabledBackgroundColor: Colors.white.withOpacity(0.40),
                          disabledForegroundColor: const Color(0xFF1D4ED8).withOpacity(0.50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFF93C5FD), width: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isRunning) ...[
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D4ED8)),
                              ),
                              const SizedBox(width: 8),
                              const Text('Running Simulation...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ] else ...[
                              const Icon(LucideIcons.play, size: 20),
                              const SizedBox(width: 8),
                              const Text('Run Simulation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Text('PREDICTED IMPACT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildImpactRow('Peak Hour Reduction', currentResults['peakReduction']!),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Colors.black12)),
                          _buildImpactRow('Student Satisfaction', currentResults['satisfaction']!),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Colors.black12)),
                          _buildImpactRow('Food Waste Reduction', currentResults['wasteReduction']!),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Colors.black12)),
                          _buildImpactRow('Revenue Impact', currentResults['revenue']!),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_selectedScenario != 1)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.70),
                            foregroundColor: const Color(0xFF047857),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Color(0xFF6EE7B7), width: 0.5),
                            ),
                          ),
                          child: const Text('Apply to Plan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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

  Widget _buildImpactRow(String label, int value) {
    bool isGood = false;
    bool isDownIcon = false;

    if (label == 'Peak Hour Reduction' || label == 'Food Waste Reduction') {
      isGood = value > 0;
      isDownIcon = value > 0;
    } else {
      isGood = value > 0;
      isDownIcon = value < 0;
    }

    final color = value == 0 ? const Color(0xFF334155) : isGood ? const Color(0xFF059669) : const Color(0xFFE11D48);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
        Row(
          children: [
            if (value != 0)
              Icon(isDownIcon ? LucideIcons.trendingDown : LucideIcons.trendingUp, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              '${value > 0 && (label == 'Peak Hour Reduction' || label == 'Food Waste Reduction') ? '-' : value < 0 && (label == 'Peak Hour Reduction' || label == 'Food Waste Reduction') ? '+' : value > 0 ? '+' : ''}${value.abs()}%',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ],
    );
  }
}