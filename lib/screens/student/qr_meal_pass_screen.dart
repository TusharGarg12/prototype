import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';

class QRMealPassScreen extends StatefulWidget {
  const QRMealPassScreen({super.key});

  @override
  State<QRMealPassScreen> createState() => _QRMealPassScreenState();
}

class _QRMealPassScreenState extends State<QRMealPassScreen> {
  int _timeLeft = 3840;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _timeLeft ~/ 60;
    final seconds = _timeLeft % 60;

    return GlobalGlassScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(bottom: 24),
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
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          child: const Text('AM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Aryan Mehta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                            Text('Roll: 21BCE0234', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // QR Card
                    Center(
                      child: SizedBox(
                        width: 280,
                        child: GlassCard(
                          level: GlassLevel.level4,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const StatusPill(text: 'ACTIVE', variant: StatusVariant.success, showDot: true),
                              const SizedBox(height: 16),
                              
                              // QR Code Placeholder
                              Container(
                                width: 176,
                                height: 176,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8)),
                                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const Icon(LucideIcons.qrCode, size: 140, color: Colors.black),
                              ),
                              const SizedBox(height: 16),
                              
                              Text(
                                '$minutes:${seconds.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF059669)),
                              ),
                              const SizedBox(height: 4),
                              const Text('Auto-refresh in progress', style: TextStyle(fontSize: 10, color: Color(0xFF475569))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Lunch', style: TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    const Text('Valid until 2:30 PM', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
