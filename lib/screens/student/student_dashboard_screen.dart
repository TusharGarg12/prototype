import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/quick_action_tile.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';
import '../../components/chatbot_overlay.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _showChatbot = false;

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: Stack(
        children: [
          // Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildLiveOccupancy(context),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 16),
                  _buildMenuCard(context),
                  const SizedBox(height: 16),
                  _buildRewardCard(context),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation
          Positioned(
            bottom: 8,
            left: 16,
            right: 16,
            child: _buildBottomNav(context),
          ),
          
          // Floating Action Button
          if (!_showChatbot)
            Positioned(
              bottom: 80,
              right: 16,
              child: GestureDetector(
                onTap: () => setState(() => _showChatbot = true),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDBEAFE).withOpacity(0.70),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 0.5),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.20), blurRadius: 16, offset: const Offset(0, 8)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('🤖', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
            
          // Chatbot Overlay
          if (_showChatbot)
            Positioned.fill(
              child: ChatbotOverlay(
                onClose: () => setState(() => _showChatbot = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.70),
                border: Border.all(color: Colors.white.withOpacity(0.80), width: 0.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'AM',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Good morning', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                Text('Aryan Mehta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 36,
              height: 36,
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
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.go('/dashboard/notifications'),
                  child: const Icon(LucideIcons.bell, size: 18, color: Color(0xFF334155)),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveOccupancy(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIVE OCCUPANCY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text('68', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Color(0xFF0F172A), letterSpacing: -0.5)),
              SizedBox(width: 4),
              Text('/ 100', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF334155))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 68,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399), // emerald-400
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF34D399).withOpacity(0.35), blurRadius: 12),
                      ],
                    ),
                  ),
                ),
                Expanded(flex: 32, child: const SizedBox()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              StatusPill(text: 'Moderate', variant: StatusVariant.success),
              Text('Best window: 1:30 – 2:00 PM', style: TextStyle(fontSize: 10, color: Color(0xFF475569))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: QuickActionTile(icon: const Icon(LucideIcons.qrCode), label: 'QR Code', color: TileColor.blue, onClick: () => context.go('/dashboard/qr'))),
        const SizedBox(width: 8),
        Expanded(child: QuickActionTile(icon: const Icon(LucideIcons.bookOpen), label: 'Menu', color: TileColor.green, onClick: () => context.go('/dashboard/menu'))),
        const SizedBox(width: 8),
        Expanded(child: QuickActionTile(icon: const Icon(LucideIcons.calendar), label: 'Leave', color: TileColor.amber, onClick: () => context.go('/dashboard/leave'))),
        const SizedBox(width: 8),
        Expanded(child: QuickActionTile(icon: const Icon(LucideIcons.messageCircle), label: 'Feedback', color: TileColor.purple, onClick: () => context.go('/dashboard/feedback'))),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    final dishes = ['Dal Makhani', 'Jeera Rice', 'Roti', 'Salad', 'Raita'];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.70),
                  border: Border.all(color: Colors.white.withOpacity(0.80), width: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Text('Lunch', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.50),
                  border: Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: const Text('Dinner', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Text(dish, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/dashboard/menu'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('View all →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6))),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context) {
    return GlassCard(
      tint: GlassTint.warning,
      padding: const EdgeInsets.all(16),
      onTap: () => context.go('/dashboard/surge'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Reward Points', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFB45309))),
                  SizedBox(height: 4),
                  Text('1,240', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF78350F), letterSpacing: -0.5)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Streak', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFB45309))),
                  SizedBox(height: 4),
                  Text('12 days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFD97706))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const StatusPill(text: 'Happy Hour: +30 pts', variant: StatusVariant.warning, showDot: true),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return GlassCard(
      level: GlassLevel.level4,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(icon: LucideIcons.home, label: 'Home', isActive: true, onTap: () {}),
          _buildNavItem(icon: LucideIcons.utensils, label: 'Vote', onTap: () => context.go('/dashboard/voting')),
          _buildNavItem(icon: LucideIcons.gift, label: 'Rewards', onTap: () => context.go('/dashboard/surge')),
          _buildNavItem(icon: LucideIcons.user, label: 'Profile', onTap: () => context.push('/profile')),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, bool isActive = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: isActive ? const Color(0xFF0F172A) : const Color(0xFF475569)),
          const SizedBox(height: 4),
          if (isActive)
            Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0F172A)))
          else
            const SizedBox(height: 4),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? const Color(0xFF0F172A) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
