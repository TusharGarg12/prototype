import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = true;
  Map<String, dynamic>? _scanResult;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSimulateScan(String type) {
    setState(() {
      _isScanning = false;
      _scanResult = {
        'type': type,
        'student': {
          'name': 'Aryan Mehta',
          'roll': '21BCE0234',
          'avatar': 'AM',
        },
        'time': type == 'already_used' ? '1:14 PM' : null,
        'counter': type == 'already_used' ? 3 : null,
      };
    });
  }

  void _handleReset() {
    setState(() {
      _scanResult = null;
      _isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient matching web
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(15, 23, 42, 0.7),
                  Color.fromRGBO(30, 41, 59, 0.7),
                  Color.fromRGBO(15, 23, 42, 0.7),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      const Text('QR Scanner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                
                if (_isScanning) ...[
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 256,
                          height: 256,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              _buildCorner(Alignment.topLeft, const BorderRadius.only(topLeft: Radius.circular(24))),
                              _buildCorner(Alignment.topRight, const BorderRadius.only(topRight: Radius.circular(24))),
                              _buildCorner(Alignment.bottomLeft, const BorderRadius.only(bottomLeft: Radius.circular(24))),
                              _buildCorner(Alignment.bottomRight, const BorderRadius.only(bottomRight: Radius.circular(24))),
                              Center(child: Icon(LucideIcons.camera, size: 64, color: Colors.white.withOpacity(0.4))),
                              
                              // Animated scan line
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Positioned(
                                    top: _animationController.value * 256,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.blue[400]!,
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      children: [
                        Text('Position QR code within frame', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
                        const SizedBox(height: 24),
                        _buildSimulateButton('Simulate: Verified', 'verified', const Color(0xFF6EE7B7), const Color(0xFF047857)),
                        const SizedBox(height: 8),
                        _buildSimulateButton('Simulate: Already Used', 'already_used', const Color(0xFFFDA4AF), const Color(0xFFBE123C)),
                        const SizedBox(height: 8),
                        _buildSimulateButton('Simulate: On Leave', 'on_leave', const Color(0xFFFCD34D), const Color(0xFFB45309)),
                      ],
                    ),
                  ),
                ] else if (_scanResult != null) ...[
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: GlassCard(
                          level: GlassLevel.level4,
                          tint: _scanResult!['type'] == 'verified' ? GlassTint.success : _scanResult!['type'] == 'already_used' ? GlassTint.danger : GlassTint.warning,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _scanResult!['type'] == 'verified' ? const Color(0xFFD1FAE5).withOpacity(0.70) : _scanResult!['type'] == 'already_used' ? const Color(0xFFFFE4E6).withOpacity(0.70) : const Color(0xFFFEF3C7).withOpacity(0.70),
                                  border: Border.all(
                                    color: _scanResult!['type'] == 'verified' ? const Color(0xFFA7F3D0) : _scanResult!['type'] == 'already_used' ? const Color(0xFFFECDD3) : const Color(0xFFFDE68A),
                                    width: 0.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _scanResult!['type'] == 'verified' ? const Color(0xFF34D399).withOpacity(0.2) : _scanResult!['type'] == 'already_used' ? const Color(0xFFFB7185).withOpacity(0.2) : const Color(0xFFFBBF24).withOpacity(0.2),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  _scanResult!['type'] == 'verified' ? LucideIcons.checkCircle : _scanResult!['type'] == 'already_used' ? LucideIcons.xCircle : LucideIcons.alertCircle,
                                  size: 40,
                                  color: _scanResult!['type'] == 'verified' ? const Color(0xFF059669) : _scanResult!['type'] == 'already_used' ? const Color(0xFFE11D48) : const Color(0xFFD97706),
                                ),
                              ),
                              
                              Text(
                                _scanResult!['type'] == 'verified' ? 'VERIFIED' : _scanResult!['type'] == 'already_used' ? 'ALREADY USED' : 'ON LEAVE',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                              ),
                              
                              if (_scanResult!['type'] == 'already_used')
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Scanned at Counter ${_scanResult!['counter']} • ${_scanResult!['time']}', style: const TextStyle(fontSize: 14, color: Color(0xFF9F1239))),
                                ),
                                
                              const SizedBox(height: 24),
                              
                              GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.70),
                                        border: Border.all(color: Colors.white.withOpacity(0.80), width: 0.5),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(_scanResult!['student']['avatar'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_scanResult!['student']['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                        Text('Roll: ${_scanResult!['student']['roll']}', style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              if (_scanResult!['type'] == 'verified')
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionButton('Approve', _handleReset, const Color(0xFF6EE7B7), const Color(0xFF047857), true),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildActionButton('Reject', _handleReset, Colors.white.withOpacity(0.7), const Color(0xFF334155), false),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionButton('Override', _handleReset, const Color(0xFF93C5FD), const Color(0xFF1D4ED8), true),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildActionButton('Dismiss', _handleReset, Colors.white.withOpacity(0.7), const Color(0xFF334155), false),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, BorderRadius borderRadius) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          ),
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildSimulateButton(String text, String type, Color borderColor, Color textColor) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _handleSimulateScan(type),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.70),
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, Color borderColor, Color textColor, bool isPrimary) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white.withOpacity(0.70) : Colors.white.withOpacity(0.60),
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
