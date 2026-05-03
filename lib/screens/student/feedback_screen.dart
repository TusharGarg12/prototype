import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedTab = 'mess';
  bool _isAnonymous = false;
  bool _submitted = false;
  
  final Map<String, int> _ratings = {
    'foodQuality': 0,
    'hygiene': 0,
    'service': 0,
    'variety': 0,
  };
  
  final TextEditingController _feedbackController = TextEditingController();

  final List<Map<String, String>> _categories = [
    { 'name': 'Food Quality', 'key': 'foodQuality' },
    { 'name': 'Hygiene', 'key': 'hygiene' },
    { 'name': 'Service', 'key': 'service' },
    { 'name': 'Variety', 'key': 'variety' },
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() {
      _submitted = true;
    });
    
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _submitted = false;
        _ratings.updateAll((key, value) => 0);
        _feedbackController.clear();
      });
    });
  }

  bool _isFormValid() {
    return _ratings.values.any((rating) => rating > 0);
  }

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
                  const Text('Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Expanded(child: _buildTab('Mess Service', 'mess')),
                    Expanded(child: _buildTab('App Experience', 'app')),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: !_submitted ? Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: _categories.map((category) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category['name']!, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (index) {
                                  int star = index + 1;
                                  bool isFilled = star <= (_ratings[category['key']] ?? 0);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _ratings[category['key']!] = star;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        LucideIcons.star,
                                        size: 28,
                                        color: isFilled ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Additional Comments', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _feedbackController,
                            maxLines: 5,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              hintText: 'Share your thoughts...',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.60),
                              contentPadding: const EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.70), width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.80), width: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Submit Anonymously', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                              SizedBox(height: 2),
                              Text("Your name won't be shared", style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isAnonymous = !_isAnonymous),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 48,
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: _isAnonymous ? const Color(0xFF34D399) : const Color(0xFFCBD5E1),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    top: 4,
                                    left: _isAnonymous ? 24 : 4,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isFormValid() ? _handleSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.70),
                          foregroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: Colors.white.withOpacity(0.40),
                          disabledForegroundColor: const Color(0xFF2563EB).withOpacity(0.50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: const Color(0xFF93C5FD).withOpacity(_isFormValid() ? 1.0 : 0.5), width: 0.5),
                          ),
                        ),
                        child: const Text('Submit Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ) : GlassCard(
                  tint: GlassTint.success,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD1FAE5).withOpacity(0.70),
                          border: Border.all(color: const Color(0xFFA7F3D0), width: 0.5),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF86EFAC).withOpacity(0.20), blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check, size: 32, color: Color(0xFF059669)),
                      ),
                      const Text('Thank You!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF064E3B))),
                      const SizedBox(height: 8),
                      const Text(
                        'Your feedback helps us improve the mess experience for everyone.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Color(0xFF047857)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.70) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.80) : Colors.transparent, 
            width: 0.5
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
          ] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
