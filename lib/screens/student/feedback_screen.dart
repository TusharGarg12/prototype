import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/services/feedback_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  String _selectedSlot = 'LUNCH';
  bool _isAnon = false;
  bool _submitting = false;
  final TextEditingController _messageController = TextEditingController();

  final List<String> _slots = ['BREAKFAST', 'LUNCH', 'SNACKS', 'DINNER'];
  final List<String> _slotLabels = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await feedbackService.submitFeedback(
        rating: _rating,
        message: _messageController.text.isEmpty ? null : _messageController.text,
        mealSlot: _selectedSlot,
        isAnon: _isAnon,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted! Thank you 🙏'), backgroundColor: Color(0xFF10B981)),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.60), border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5)),
                    child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => context.pop(), child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF334155)))),
                  ),
                  const SizedBox(width: 12),
                  const Text('Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 32),

              // Meal slot selector
              const Text('MEAL SLOT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569), letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(
                children: List.generate(_slots.length, (i) {
                  final isSelected = _selectedSlot == _slots[i];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == _slots.length - 1 ? 0 : 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedSlot = _slots[i]),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.80) : Colors.white.withOpacity(0.50),
                            border: Border.all(color: isSelected ? const Color(0xFF93C5FD) : Colors.white.withOpacity(0.60), width: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_slotLabels[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF475569))),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Star rating
              const Text('RATING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569), letterSpacing: 1)),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < _rating;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          filled ? LucideIcons.star : LucideIcons.star,
                          size: 36,
                          color: filled ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Message
              const Text('COMMENT (OPTIONAL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569), letterSpacing: 1)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(
                    hintText: 'What did you like or dislike?',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Anonymous toggle
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Submit anonymously', style: TextStyle(fontSize: 13, color: Color(0xFF334155))),
                    Switch(value: _isAnon, onChanged: (v) => setState(() => _isAnon = v), activeColor: const Color(0xFF3B82F6)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Submit
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
