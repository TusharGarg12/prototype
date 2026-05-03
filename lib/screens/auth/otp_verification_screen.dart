import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../components/global_glass_scaffold.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String role;
  
  const OTPVerificationScreen({super.key, required this.role});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  int _countdown = 120;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _countdown = 120;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _countdown = 0;
            _canResend = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _countdown--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    }
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          if (widget.role == 'student') {
            context.go('/dashboard');
          } else if (widget.role == 'admin') {
            context.go('/admin');
          } else if (widget.role == 'kitchen') {
            context.go('/kitchen');
          }
        }
      });
    }
  }

  void _handleResend() {
    if (!_canResend) return;
    for (var c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_countdown / 60).floor();
    final seconds = (_countdown % 60).toString().padLeft(2, '0');

    return GlobalGlassScaffold(
      child: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text('← Back', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2563EB))),
                ),
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Check your inbox', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text('We\'ve sent a 6-digit code to your email', style: TextStyle(fontSize: 14, color: Color(0xFF334155)), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      children: [
                        const TextSpan(text: 'Logging in as '),
                        TextSpan(
                          text: widget.role[0].toUpperCase() + widget.role.substring(1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 48,
                        height: 56,
                        margin: EdgeInsets.only(right: index < 5 ? 12 : 0),
                        decoration: BoxDecoration(
                          color: _controllers[index].text.isNotEmpty ? Colors.white.withOpacity(0.70) : Colors.white.withOpacity(0.60),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _controllers[index].text.isNotEmpty ? const Color(0xFF60A5FA) : Colors.white.withOpacity(0.70),
                            width: 0.5,
                          ),
                          boxShadow: [
                            if (_controllers[index].text.isNotEmpty)
                              BoxShadow(color: const Color(0xFF93C5FD).withOpacity(0.30), blurRadius: 24, offset: const Offset(0, 8)),
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Color(0xFF0F172A)),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          onChanged: (value) {
                            setState(() {}); // Trigger rebuild for styling
                            _onChanged(value, index);
                          },
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    _countdown > 0 ? '$minutes:$seconds' : 'Code expired',
                    style: const TextStyle(fontSize: 14, fontFamily: 'monospace', color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 16),
                  
                  GestureDetector(
                    onTap: _handleResend,
                    child: Text(
                      'Resend code',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _canResend ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
