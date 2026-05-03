import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final List<Map<String, dynamic>> _weeklyData = [
    { 'day': 'Mon', 'breakfast': 450, 'lunch': 780, 'dinner': 620 },
    { 'day': 'Tue', 'breakfast': 420, 'lunch': 820, 'dinner': 580 },
    { 'day': 'Wed', 'breakfast': 480, 'lunch': 760, 'dinner': 640 },
    { 'day': 'Thu', 'breakfast': 460, 'lunch': 800, 'dinner': 590 },
    { 'day': 'Fri', 'breakfast': 490, 'lunch': 850, 'dinner': 670 },
    { 'day': 'Sat', 'breakfast': 380, 'lunch': 720, 'dinner': 550 },
    { 'day': 'Sun', 'breakfast': 350, 'lunch': 680, 'dinner': 520 },
  ];

  final List<Map<String, dynamic>> _popularDishes = [
    { 'name': 'Paneer Butter Masala', 'count': 342, 'trend': 'up', 'percentage': 15 },
    { 'name': 'Dal Makhani', 'count': 298, 'trend': 'up', 'percentage': 8 },
    { 'name': 'Biryani', 'count': 276, 'trend': 'down', 'percentage': 5 },
    { 'name': 'Dosa', 'count': 245, 'trend': 'up', 'percentage': 12 },
    { 'name': 'Chole Bhature', 'count': 218, 'trend': 'down', 'percentage': 3 },
  ];

  @override
  Widget build(BuildContext context) {
    int maxValue = _weeklyData.expand((d) => [d['breakfast'] as int, d['lunch'] as int, d['dinner'] as int]).reduce((a, b) => a > b ? a : b);

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
                              const Text('12.4K', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(LucideIcons.trendingUp, size: 12, color: Color(0xFF059669)),
                                  SizedBox(width: 4),
                                  Text('+8%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
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
                              const Text('4.3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(LucideIcons.trendingUp, size: 12, color: Color(0xFF059669)),
                                  SizedBox(width: 4),
                                  Text('+0.2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
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
                              const Text('8.2%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(LucideIcons.trendingDown, size: 12, color: Color(0xFF059669)),
                                  SizedBox(width: 4),
                                  Text('-2%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
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
                    
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Popular Dishes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          const SizedBox(height: 16),
                          Column(
                            children: _popularDishes.asMap().entries.map((entry) {
                              int index = entry.key;
                              var dish = entry.value;
                              bool isUp = dish['trend'] == 'up';
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.70),
                                        border: Border.all(color: Colors.white.withOpacity(0.80), width: 0.5),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(dish['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                          const SizedBox(height: 4),
                                          Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE2E8F0).withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: dish['count'] / _popularDishes[0]['count'],
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFF60A5FA), Color(0xFF34D399)],
                                                  ),
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('${dish['count']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                        Row(
                                          children: [
                                            Icon(isUp ? LucideIcons.trendingUp : LucideIcons.trendingDown, size: 12, color: isUp ? const Color(0xFF059669) : const Color(0xFFE11D48)),
                                            const SizedBox(width: 2),
                                            Text('${dish['percentage']}%', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isUp ? const Color(0xFF059669) : const Color(0xFFE11D48))),
                                          ],
                                        ),
                                      ],
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
                      tint: GlassTint.success,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Sustainability Metrics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF064E3B))),
                              StatusPill(text: 'This Week', variant: StatusVariant.success),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Food Saved', style: TextStyle(fontSize: 12, color: Color(0xFF065F46))),
                                    SizedBox(height: 4),
                                    Text('12.4 kg', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF064E3B))),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('CO₂ Avoided', style: TextStyle(fontSize: 12, color: Color(0xFF065F46))),
                                    SizedBox(height: 4),
                                    Text('6.2 kg', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF064E3B))),
                                  ],
                                ),
                              ),
                            ],
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
}
