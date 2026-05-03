import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';

class SurgeManagementScreen extends StatefulWidget {
  const SurgeManagementScreen({super.key});

  @override
  State<SurgeManagementScreen> createState() => _SurgeManagementScreenState();
}

class _SurgeManagementScreenState extends State<SurgeManagementScreen> {
  int _hours = 0;
  int _minutes = 23;
  int _seconds = 40;
  bool _isActive = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else if (_minutes > 0) {
          _minutes--;
          _seconds = 59;
        } else if (_hours > 0) {
          _hours--;
          _minutes = 59;
          _seconds = 59;
        } else {
          _isActive = false;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleAccept() {
    setState(() {
      _isActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: SafeArea(
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
                  const Text('Happy Hour', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isActive) ...[
                      GlassCard(
                        tint: GlassTint.warning,
                        padding: const EdgeInsets.all(24),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: -24,
                              right: -24,
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFBBF24).withOpacity(0.1),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFFEF3C7).withOpacity(0.70),
                                        border: Border.all(color: const Color(0xFFFDE68A), width: 0.5),
                                        boxShadow: [
                                          BoxShadow(color: const Color(0xFFFED7AA).withOpacity(0.20), blurRadius: 24, offset: const Offset(0, 8)),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(LucideIcons.gift, size: 28, color: Color(0xFFB45309)),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Happy Hour!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF78350F))),
                                        Text('Earn bonus points', style: TextStyle(fontSize: 14, color: Color(0xFF92400E))),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: const [
                                    Icon(LucideIcons.clock, size: 16, color: Color(0xFFB45309)),
                                    SizedBox(width: 8),
                                    Text('ENDS IN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E), letterSpacing: 0.5)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Color(0xFF78350F), letterSpacing: -1),
                                ),
                                const SizedBox(height: 24),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlassCard(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Bonus Points', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                                            const SizedBox(height: 8),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.baseline,
                                              textBaseline: TextBaseline.alphabetic,
                                              children: const [
                                                Text('+30', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300, color: Color(0xFFD97706))),
                                                SizedBox(width: 4),
                                                Text('pts', style: TextStyle(fontSize: 14, color: Color(0xFFB45309))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GlassCard(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Current Crowd', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                                            const SizedBox(height: 8),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.baseline,
                                              textBaseline: TextBaseline.alphabetic,
                                              children: const [
                                                Text('Low', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300, color: Color(0xFF059669))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _handleAccept,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.70),
                                      foregroundColor: const Color(0xFF78350F),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: const BorderSide(color: Color(0xFFFCD34D), width: 0.5),
                                      ),
                                    ),
                                    child: const Text('Accept Happy Hour Offer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('How it works', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            const SizedBox(height: 12),
                            _buildInstructionStep('1', 'Visit the mess during off-peak hours (now until ${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')})'),
                            const SizedBox(height: 12),
                            _buildInstructionStep('2', 'Scan your QR code at the counter'),
                            const SizedBox(height: 12),
                            _buildInstructionStep('3', 'Earn +30 bonus reward points automatically'),
                          ],
                        ),
                      ),
                    ] else ...[
                      GlassCard(
                        tint: GlassTint.success,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFD1FAE5).withOpacity(0.70),
                                border: Border.all(color: const Color(0xFFA7F3D0), width: 0.5),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF34D399).withOpacity(0.20), blurRadius: 24, offset: const Offset(0, 8)),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check, size: 40, color: Color(0xFF059669)),
                            ),
                            const Text('Offer Accepted!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF064E3B))),
                            const SizedBox(height: 8),
                            const Text(
                              'Visit the mess now and scan your QR to earn +30 bonus points.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Color(0xFF065F46)),
                            ),
                            const SizedBox(height: 24),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => context.pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.70),
                                  foregroundColor: const Color(0xFF047857),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(color: Color(0xFF6EE7B7), width: 0.5),
                                  ),
                                ),
                                child: const Text('Go to Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    const Text('PREVIOUS HAPPY HOURS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    
                    _buildHistoryCard('Today, 2:30 PM', 30, true),
                    const SizedBox(height: 8),
                    _buildHistoryCard('Yesterday, 3:00 PM', 30, true),
                    const SizedBox(height: 8),
                    _buildHistoryCard('Apr 18, 2:45 PM', 30, false),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFDBEAFE).withOpacity(0.70),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 0.5),
          ),
          alignment: Alignment.center,
          child: Text(step, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
      ],
    );
  }

  Widget _buildHistoryCard(String date, int points, bool accepted) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              Text('+$points bonus points', style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
            ],
          ),
          StatusPill(
            text: accepted ? 'Earned' : 'Missed',
            variant: accepted ? StatusVariant.success : StatusVariant.danger,
          ),
        ],
      ),
    );
  }
}
