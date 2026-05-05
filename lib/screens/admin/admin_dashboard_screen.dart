import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/services/optimization_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _showMobileMenu = false;
  bool _showLogoutConfirm = false;
  bool _isLoadingSurgeInsight = true;
  Map<String, dynamic>? _surgeInsight;

  final List<Map<String, dynamic>> _kpis = [
    { 'label': 'Active Students', 'value': '1,248', 'delta': '+12%', 'trend': 'up' },
    { 'label': 'Meals Served', 'value': '3,742', 'delta': '+8%', 'trend': 'up' },
    { 'label': 'Occupancy Rate', 'value': '68%', 'delta': '-5%', 'trend': 'down' },
    { 'label': 'Avg Wait Time', 'value': '4.2m', 'delta': '-15%', 'trend': 'up' },
  ];

  final List<Map<String, dynamic>> _zones = [
    { 'name': 'Entry Zone', 'count': 45, 'capacity': 60, 'status': 'moderate' },
    { 'name': 'Counter 1-3', 'count': 78, 'capacity': 90, 'status': 'high' },
    { 'name': 'Counter 4-6', 'count': 52, 'capacity': 90, 'status': 'moderate' },
    { 'name': 'Dining Area A', 'count': 124, 'capacity': 200, 'status': 'moderate' },
    { 'name': 'Dining Area B', 'count': 89, 'capacity': 150, 'status': 'moderate' },
    { 'name': 'Exit Zone', 'count': 23, 'capacity': 50, 'status': 'low' },
  ];

  final List<Map<String, dynamic>> _footfall = [
    { 'time': '11:00', 'count': 45, 'peak': false },
    { 'time': '11:30', 'count': 89, 'peak': false },
    { 'time': '12:00', 'count': 156, 'peak': true },
    { 'time': '12:30', 'count': 198, 'peak': true },
    { 'time': '13:00', 'count': 142, 'peak': false },
    { 'time': '13:30', 'count': 78, 'peak': false },
    { 'time': '14:00', 'count': 34, 'peak': false },
  ];

  @override
  void initState() {
    super.initState();
    _loadSurgeInsight();
  }

  Future<void> _loadSurgeInsight() async {
    try {
      final plan = await optimizationService.getSurgeRecommendation(
        date: _formatDate(DateTime.now()),
        mealSlot: _currentMealSlot(),
        totalStudents: 600,
        totalCapacity: 600,
      );
      if (!mounted) return;
      setState(() {
        _surgeInsight = plan;
        _isLoadingSurgeInsight = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSurgeInsight = false);
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

  @override
  Widget build(BuildContext context) {
    int maxFootfall = _footfall.map((f) => f['count'] as int).reduce((a, b) => a > b ? a : b);
    final forecast = (_surgeInsight?['forecast'] as Map<String, dynamic>?) ?? const {};
    final recommendation = (_surgeInsight?['recommendation'] as Map<String, dynamic>?) ?? const {};
    final occupancyPercent = (recommendation['occupancyPercent'] as num?)?.toDouble() ??
      ((forecast['expectedHeadcount'] as num?)?.toDouble() ?? 0) / 600.0 * 100;
    final peakWindow = occupancyPercent >= 75 ? '12:00 - 12:30 PM' : occupancyPercent >= 45 ? '12:30 - 1:00 PM' : 'Off-peak window';
    final surgeBody = (recommendation['analysis'] as String?) ??
      'Predicted crowd pressure will be shown here once the ML backend responds.';

    return GlobalGlassScaffold(
      child: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          const Text('Admin Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
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
                            onTap: () => setState(() => _showMobileMenu = !_showMobileMenu),
                            child: const Icon(LucideIcons.menu, size: 20, color: Color(0xFF334155)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: _kpis.length,
                    itemBuilder: (context, index) {
                      final kpi = _kpis[index];
                      final isUp = kpi['trend'] == 'up';
                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kpi['label'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF475569), letterSpacing: 1)),
                            const Spacer(),
                            Text(kpi['value'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                            Text(kpi['delta'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isUp ? const Color(0xFF059669) : const Color(0xFFE11D48))),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Live Crowd Heatmap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                                  StatusPill(text: 'Real-time', variant: StatusVariant.success, showDot: true),
                                ],
                              ),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 2.2,
                                ),
                                itemCount: _zones.length,
                                itemBuilder: (context, index) {
                                  final zone = _zones[index];
                                  final percentage = (zone['count'] / zone['capacity']);
                                  final statusColor = zone['status'] == 'high' ? const Color(0xFFF43F5E) : zone['status'] == 'moderate' ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
                                  final tint = zone['status'] == 'high' ? GlassTint.danger : zone['status'] == 'moderate' ? GlassTint.warning : GlassTint.success;
                                  
                                  return GlassCard(
                                    tint: tint,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(zone['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const Spacer(),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text('${zone['count']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Color(0xFF0F172A))),
                                            const SizedBox(width: 4),
                                            Text('/ ${zone['capacity']}', style: const TextStyle(fontSize: 10, color: Color(0xFF334155))),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE2E8F0).withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: percentage,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: statusColor,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
                              const Text('Footfall Forecast', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 128,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: _footfall.map((item) {
                                    final heightFactor = item['count'] / maxFootfall;
                                    final isPeak = item['peak'] as bool;
                                    return Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: FractionallySizedBox(
                                                heightFactor: heightFactor,
                                                child: Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                                  decoration: BoxDecoration(
                                                    color: isPeak ? const Color(0xFF34D399) : Colors.white.withOpacity(0.50),
                                                    border: isPeak ? null : Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
                                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                                    boxShadow: isPeak ? [BoxShadow(color: const Color(0xFF34D399).withOpacity(0.30), blurRadius: 12)] : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(item['time'], style: const TextStyle(fontSize: 9, color: Color(0xFF475569))),
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
                          tint: GlassTint.warning,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Surge Alert', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF78350F))),
                                      SizedBox(height: 4),
                                      Text('Expected peak: $peakWindow', style: const TextStyle(fontSize: 12, color: Color(0xFFB45309))),
                                    ],
                                  ),
                                  StatusPill(text: _isLoadingSurgeInsight ? 'Loading' : peakWindow, variant: StatusVariant.warning),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _isLoadingSurgeInsight ? 'Loading live surge recommendation from the ML backend...' : surgeBody,
                                style: const TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 36,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withOpacity(0.70),
                                          foregroundColor: const Color(0xFFB45309),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: const BorderSide(color: Color(0xFFFCD34D), width: 0.5),
                                          ),
                                        ),
                                        child: const Text('Create Incentive', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 36,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withOpacity(0.50),
                                          foregroundColor: const Color(0xFF334155),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: Colors.white.withOpacity(0.60), width: 0.5),
                                          ),
                                        ),
                                        child: const Text('Dismiss', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
          
          if (_showMobileMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showMobileMenu = false),
                child: Container(
                  color: const Color(0xFF0F172A).withOpacity(0.2),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 16,
                        top: 16,
                        width: 256,
                        child: GestureDetector(
                          onTap: () {},
                          child: GlassCard(
                            level: GlassLevel.level4,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Menu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.50),
                                        border: Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () => setState(() => _showMobileMenu = false),
                                          child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF334155)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildMenuBtn('QR Scanner', () { setState(() => _showMobileMenu = false); context.go('/admin/qr-scanner'); }),
                                _buildMenuBtn('Menu Management', () { setState(() => _showMobileMenu = false); context.go('/admin/menu-management'); }),
                                _buildMenuBtn('Leave Approvals', () { setState(() => _showMobileMenu = false); context.go('/admin/leave-approvals'); }),
                                _buildMenuBtn('Analytics', () { setState(() => _showMobileMenu = false); context.go('/admin/analytics'); }),
                                _buildMenuBtn('Kitchen Display', () { setState(() => _showMobileMenu = false); context.push('/kitchen?role=admin'); }),
                                _buildMenuBtn('Digital Twin', () { setState(() => _showMobileMenu = false); context.go('/admin/simulation'); }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Container(height: 1, color: Colors.white.withOpacity(0.20)),
                                ),
                                _buildMenuBtn('Profile & Settings', () { setState(() => _showMobileMenu = false); context.push('/profile'); }),
                                InkWell(
                                  onTap: () {
                                    setState(() => _showMobileMenu = false);
                                    setState(() => _showLogoutConfirm = true);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: const [
                                        Icon(LucideIcons.logOut, size: 16, color: Color(0xFFBE123C)),
                                        SizedBox(width: 8),
                                        Text('Sign Out', style: TextStyle(fontSize: 14, color: Color(0xFFBE123C))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                            'Are you sure you want to sign out of your admin account?',
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

  Widget _buildMenuBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
      ),
    );
  }
}
