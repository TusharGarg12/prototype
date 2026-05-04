import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/glass_card.dart';
import '../../core/services/qr_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = true;
  Map<String, dynamic>? _scanResult;
  bool _isLoading = false;
  late AnimationController _animationController;
  final MobileScannerController _cameraController = MobileScannerController();
  final List<String> _counters = const ['counter_1', 'counter_2', 'counter_3', 'counter_4'];
  String _selectedCounter = 'counter_1';
  bool _rememberCounter = true;

  static const String _counterPrefKey = 'admin_selected_counter';
  static const String _rememberPrefKey = 'admin_remember_counter';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadCounterPreference();
  }

  Future<void> _loadCounterPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberPrefKey) ?? true;
    final savedCounter = prefs.getString(_counterPrefKey);
    if (!mounted) return;
    setState(() {
      _rememberCounter = remember;
      if (remember && savedCounter != null && _counters.contains(savedCounter)) {
        _selectedCounter = savedCounter;
      }
    });
  }

  Future<void> _persistCounterPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberPrefKey, _rememberCounter);
    if (_rememberCounter) {
      await prefs.setString(_counterPrefKey, _selectedCounter);
    } else {
      await prefs.remove(_counterPrefKey);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (!_isScanning || _isLoading) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String rawValue = barcodes.first.rawValue!;
      await _validateTokenReal(rawValue);
    }
  }

  Future<void> _validateTokenReal(String token) async {
    setState(() {
      _isScanning = false;
      _isLoading = true;
    });

    await _cameraController.stop();

    try {
      final res = await qrService.validatePass(token, counterId: _selectedCounter);
      final log = (res['log'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final student = (res['student'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final String name = (student['name'] as String?)?.trim().isNotEmpty == true
          ? (student['name'] as String).trim()
          : 'Unknown Student';
      final String roll = (student['rollNumber'] as String?)?.trim().isNotEmpty == true
          ? (student['rollNumber'] as String)
          : (student['email'] as String?) ?? 'Unknown ID';
      final String avatar = _initialsFromName(name);

      setState(() {
        _isLoading = false;
        _scanResult = {
          'type': 'verified',
          'student': {
            'name': name,
            'roll': roll,
            'avatar': avatar,
          },
          'mealSlot': log['mealSlot'],
          'scannedAt': log['scannedAt'],
          'counter': log['counterId'] ?? _selectedCounter,
          'message': 'Attendance recorded successfully',
        };
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('already used') || errorString.contains('replay')) {
            _scanResult = {
              'type': 'already_used',
              'student': {
                'name': 'Duplicate Scan',
                'roll': 'Invalid',
                'avatar': 'DS',
              },
              'scannedAt': DateTime.now().toIso8601String(),
              'counter': _selectedCounter,
              'message': 'This pass was already used.',
            };
        } else if (errorString.contains('expired')) {
            _scanResult = {
              'type': 'expired',
              'student': {
                'name': 'Expired Pass',
                'roll': 'Invalid',
                'avatar': 'EX',
              },
              'message': 'Pass is expired. Ask student to regenerate.',
            };
        } else if (errorString.contains('blocked')) {
            _scanResult = {
              'type': 'blocked',
              'student': {
                'name': 'Blocked Pass',
                'roll': 'Invalid',
                'avatar': 'BL',
              },
              'message': 'Pass is blocked. Contact admin.',
            };
        } else if (errorString.contains('not found')) {
            _scanResult = {
              'type': 'invalid',
              'student': {
                'name': 'Invalid Pass',
                'roll': 'Not recognized',
                'avatar': 'NF',
              },
              'message': 'QR not recognized. Try again.',
            };
        } else {
             _scanResult = {
              'type': 'invalid',
              'student': {
                'name': 'Invalid Pass',
                'roll': 'Failed Validation',
                'avatar': 'ERR',
              },
              'message': 'Validation failed. Please retry.',
            };
        }
      });
    }
  }

  Future<void> _handleReset() async {
    await _cameraController.start();
    setState(() {
      _scanResult = null;
      _isScanning = true;
      _isLoading = false;
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
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCounter,
                          dropdownColor: const Color(0xFF0F172A),
                          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Colors.white),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedCounter = value);
                            _persistCounterPreference();
                          },
                          items: _counters
                              .map((counter) => DropdownMenuItem(
                                    value: counter,
                                    child: Text(counter.replaceAll('_', ' ')),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Remember counter', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                      Switch(
                        value: _rememberCounter,
                        onChanged: (value) {
                          setState(() => _rememberCounter = value);
                          _persistCounterPreference();
                        },
                        activeColor: const Color(0xFF60A5FA),
                      ),
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
                              
                              // Real camera scanner mapped beneath the animated line
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: MobileScanner(
                                  controller: _cameraController,
                                  onDetect: _handleBarcode,
                                ),
                              ),
                              
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
                        const SizedBox(height: 12),
                        Text('Scanning automatically once detected', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.55))),
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
                                _statusTitle(_scanResult!['type'] as String),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                              ),
                              if (_scanResult?['message'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _scanResult!['message'] as String,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ),
                              
                              if (_scanResult!['type'] == 'already_used')
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Scanned at ${_scanResult!['counter']} • ${_formatTime(_scanResult!['scannedAt'])}',
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF9F1239)),
                                  ),
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
                                        if (_scanResult!['mealSlot'] != null)
                                          Text('Meal: ${_formatMealSlot(_scanResult!['mealSlot'] as String)}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                                      child: _buildActionButton('Scan Next', _handleReset, const Color(0xFF6EE7B7), const Color(0xFF047857), true),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildActionButton('Close', _handleReset, Colors.white.withOpacity(0.7), const Color(0xFF334155), false),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionButton('Rescan', _handleReset, const Color(0xFF93C5FD), const Color(0xFF1D4ED8), true),
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

  String _formatMealSlot(String mealSlot) {
    switch (mealSlot) {
      case 'BREAKFAST':
        return 'Breakfast';
      case 'LUNCH':
        return 'Lunch';
      case 'SNACKS':
        return 'Snacks';
      case 'DINNER':
        return 'Dinner';
      default:
        return mealSlot;
    }
  }

  String _formatTime(dynamic scannedAt) {
    try {
      final dateTime = scannedAt is String ? DateTime.parse(scannedAt) : DateTime.now();
      final timeOfDay = TimeOfDay.fromDateTime(dateTime.toLocal());
      final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
      final minute = timeOfDay.minute.toString().padLeft(2, '0');
      final suffix = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $suffix';
    } catch (_) {
      return 'Just now';
    }
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String _statusTitle(String type) {
    switch (type) {
      case 'verified':
        return 'VERIFIED';
      case 'already_used':
        return 'ALREADY USED';
      case 'expired':
        return 'EXPIRED';
      case 'blocked':
        return 'BLOCKED';
      default:
        return 'INVALID';
    }
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
