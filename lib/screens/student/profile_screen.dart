import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  final String userRole;
  
  const ProfileScreen({super.key, this.userRole = 'student'});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showLogoutConfirm = false;
  bool _darkMode = false;

  late final Map<String, dynamic> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = {
      'student': {
        'initials': 'AM',
        'name': 'Aryan Mehta',
        'subtitle': 'Roll: 21BCE0234',
        'role': 'Student',
        'variant': StatusVariant.info,
      },
      'admin': {
        'initials': 'AK',
        'name': 'Admin Kumar',
        'subtitle': 'Admin ID: ADM001',
        'role': 'Admin',
        'variant': StatusVariant.purple,
      },
      'kitchen': {
        'initials': 'KS',
        'name': 'Kitchen Staff',
        'subtitle': 'Staff ID: KCH001',
        'role': 'Kitchen',
        'variant': StatusVariant.warning,
      },
    };
  }

  void _handleLogout() {
    setState(() {
      _showLogoutConfirm = false;
    });
    // Add real logout logic here, then navigate
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileData[widget.userRole] ?? _profileData['student'];

    return GlobalGlassScaffold(
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Row(
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
                      const Text('Profile & Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.70),
                                  border: Border.all(color: Colors.white.withOpacity(0.80), width: 0.5),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(profile['initials'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(profile['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                    const SizedBox(height: 4),
                                    Text(profile['subtitle'], style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                                    const SizedBox(height: 8),
                                    StatusPill(text: profile['role'], variant: profile['variant']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (widget.userRole == 'student') ...[
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(child: _buildStatItem('1,240', 'POINTS')),
                                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.30)),
                                Expanded(child: _buildStatItem('12', 'STREAK')),
                                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.30)),
                                Expanded(child: _buildStatItem('4.3', 'RATING')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        const Text('ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        GlassCard(
                          child: Column(
                            children: [
                              _buildSettingRow(icon: LucideIcons.user, label: 'Personal Information', hasBorder: true),
                              _buildSettingRow(icon: LucideIcons.shield, label: 'Privacy & Security'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        const Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        GlassCard(
                          child: Column(
                            children: [
                              _buildSettingRow(icon: LucideIcons.bell, label: 'Notifications', hasBorder: true, trailing: const StatusPill(text: 'On', variant: StatusVariant.success)),
                              _buildSettingRow(icon: LucideIcons.moon, label: 'Dark Mode', hasBorder: true, trailing: _buildSwitch(_darkMode, (val) => setState(() => _darkMode = val))),
                              _buildSettingRow(icon: LucideIcons.globe, label: 'Language', trailing: const Text('English', style: TextStyle(fontSize: 14, color: Color(0xFF334155)))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        const Text('SUPPORT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        GlassCard(
                          child: Column(
                            children: [
                              _buildSettingRow(icon: LucideIcons.helpCircle, label: 'Help & FAQ', hasBorder: true),
                              _buildSettingRow(icon: LucideIcons.info, label: 'About SMMS', trailing: const Text('v1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _showLogoutConfirm = true),
                            icon: const Icon(LucideIcons.logOut, size: 20),
                            label: const Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.70),
                              foregroundColor: const Color(0xFFE11D48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: Color(0xFFFDA4AF), width: 0.5),
                              ),
                            ),
                          ),
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'SMMS v1.0.0 • Made with ❤️ for students',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
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
                    onTap: () {}, // Consume tap to prevent closing
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
                          Text(
                            'Are you sure you want to sign out of your ${widget.userRole} account?',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
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
                                    onPressed: _handleLogout,
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
      ],
    );
  }

  Widget _buildSettingRow({required IconData icon, required String label, bool hasBorder = false, Widget? trailing}) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: hasBorder ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.20))) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF334155)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)))),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 8),
            ],
            const Icon(LucideIcons.chevronRight, size: 20, color: Color(0xFF475569)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? const Color(0xFF34D399) : const Color(0xFFCBD5E1),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 4,
              left: value ? 24 : 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
