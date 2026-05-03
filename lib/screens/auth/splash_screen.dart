import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: FadeTransition(
        opacity: _fadeController,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF93C5FD).withOpacity(0.20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF93C5FD).withOpacity(0.20), blurRadius: 180),
                        ],
                      ),
                    ),
                    GlassCard(
                      level: GlassLevel.level3,
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.80),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: Colors.white.withOpacity(0.85), width: 0.5),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 32, offset: const Offset(0, 12)),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text('SM', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300, color: Color(0xFF1E293B))),
                          ),
                          const Text('SMMS', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                          const SizedBox(height: 8),
                          const Text('Smart Mess Management', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                const Text('Powered by AI · Made for Students', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(0),
                        const SizedBox(width: 8),
                        _buildDot(0.2),
                        const SizedBox(width: 8),
                        _buildDot(0.4),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(double delay) {
    final value = (_pulseController.value - delay).clamp(0.0, 1.0);
    final opacity = 0.4 + (0.6 * (1 - (value * 2 - 1).abs()));
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF60A5FA).withOpacity(opacity),
      ),
    );
  }
}
