import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/qr_pass_model.dart';
import '../../core/services/qr_service.dart';

class QRMealPassScreen extends StatefulWidget {
  const QRMealPassScreen({super.key});
  @override
  State<QRMealPassScreen> createState() => _QRMealPassScreenState();
}

class _QRMealPassScreenState extends State<QRMealPassScreen> {
  QrPassModel? _pass;
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _generatePass();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _generatePass() async {
    setState(() { _loading = true; _error = null; });
    try {
      final pass = await qrService.generatePass();
      if (!mounted) return;
      setState(() {
        _pass    = pass;
        _loading = false;
        _remaining = pass.timeRemaining;
      });
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error   = e.toString().contains('leave') ? 'You have an approved leave for today' : 'Could not generate QR pass. Try again.';
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = _pass!.expiresAt.difference(DateTime.now());
      if (remaining.isNegative) {
        _countdownTimer?.cancel();
        setState(() => _remaining = Duration.zero);
        // Auto-refresh when expired
        _generatePass();
      } else {
        setState(() => _remaining = remaining);
      }
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return GlobalGlassScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Container(
                width: 40, height: 40,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.60),
                  border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
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
                    // Profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.70),
                            border: Border.all(color: Colors.white.withOpacity(0.80), width: 0.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(user?.initials ?? 'S', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'Student', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                            if (user?.rollNumber != null)
                              Text('Roll: ${user!.rollNumber}', style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
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
                          child: _buildQRContent(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    if (_pass != null) ...[
                      Text(_pass!.slotLabel, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
                      const SizedBox(height: 4),
                      Text(
                        'Valid until ${_pass!.expiresAt.hour.toString().padLeft(2,'0')}:${_pass!.expiresAt.minute.toString().padLeft(2,'0')}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRContent() {
    if (_loading) {
      return const Column(
        children: [
          SizedBox(height: 16),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Generating your pass…', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
          SizedBox(height: 16),
        ],
      );
    }

    if (_error != null) {
      return Column(
        children: [
          const Icon(LucideIcons.alertCircle, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _generatePass, child: const Text('Retry')),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StatusPill(
          text: _remaining.isNegative ? 'EXPIRED' : 'ACTIVE',
          variant: _remaining.isNegative ? StatusVariant.danger : StatusVariant.success,
          showDot: true,
        ),
        const SizedBox(height: 16),

        // Real QR code rendered from the server token
        Container(
          width: 176, height: 176,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: QrImageView(
            data: _pass!.token,
            version: QrVersions.auto,
            size: 152,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          _formatDuration(_remaining),
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500,
            color: _remaining.inMinutes < 5 ? const Color(0xFFDC2626) : const Color(0xFF059669),
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        const Text('Auto-refreshes when expired', style: TextStyle(fontSize: 10, color: Color(0xFF475569))),
      ],
    );
  }
}
