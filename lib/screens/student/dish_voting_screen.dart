import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';

class DishVotingScreen extends StatefulWidget {
  const DishVotingScreen({super.key});

  @override
  State<DishVotingScreen> createState() => _DishVotingScreenState();
}

class _DishVotingScreenState extends State<DishVotingScreen> {
  int? _votedDish;
  int _days = 2;
  int _hours = 14;
  int _minutes = 32;
  Timer? _timer;

  final List<Map<String, dynamic>> _dishes = [
    { 'name': 'Paneer Tikka Masala', 'votes': 234, 'totalVotes': 450, 'color': const Color(0xFFF97316) },
    { 'name': 'Chole Bhature', 'votes': 189, 'totalVotes': 450, 'color': const Color(0xFFEAB308) },
    { 'name': 'Palak Paneer', 'votes': 156, 'totalVotes': 450, 'color': const Color(0xFF22C55E) },
    { 'name': 'Rajma Chawal', 'votes': 198, 'totalVotes': 450, 'color': const Color(0xFFDC2626) },
    { 'name': 'Aloo Paratha', 'votes': 167, 'totalVotes': 450, 'color': const Color(0xFFFB923C) },
    { 'name': 'Dosa with Sambhar', 'votes': 223, 'totalVotes': 450, 'color': const Color(0xFFFBBF24) },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        if (_minutes > 0) {
          _minutes--;
        } else if (_hours > 0) {
          _hours--;
          _minutes = 59;
        } else if (_days > 0) {
          _days--;
          _hours = 23;
          _minutes = 59;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleVote(int index) {
    if (_votedDish == null) {
      setState(() {
        _votedDish = index;
        _dishes[index]['votes'] = (_dishes[index]['votes'] as int) + 1;
        for (var dish in _dishes) {
          dish['totalVotes'] = (dish['totalVotes'] as int) + 1;
        }
      });
    }
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
                  const Text('Vote for Next Week', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                tint: GlassTint.purple,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vote closes in', style: TextStyle(fontSize: 12, color: Color(0xFF7E22CE))),
                        const SizedBox(height: 4),
                        Text('${_days}d ${_hours}h ${_minutes}m', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Color(0xFF581C87))),
                      ],
                    ),
                    const StatusPill(text: 'Active Poll', variant: StatusVariant.purple, showDot: true),
                  ],
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('SELECT YOUR FAVORITE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _dishes.length,
                      itemBuilder: (context, index) {
                        final dish = _dishes[index];
                        final votePercentage = (dish['votes'] / dish['totalVotes']) * 100;
                        final isVoted = _votedDish == index;
                        final isDimmed = _votedDish != null && !isVoted;
                        
                        return Opacity(
                          opacity: isDimmed ? 0.5 : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: isVoted ? Border.all(color: const Color(0xFFC084FC), width: 2) : null,
                            ),
                            child: GlassCard(
                              tint: isVoted ? GlassTint.purple : GlassTint.none,
                              padding: const EdgeInsets.all(16),
                              onTap: _votedDish == null ? () => _handleVote(index) : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: dish['color'],
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      (dish['name'] as String).split(' ').first,
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(dish['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0).withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: votePercentage / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isVoted ? const Color(0xFFA855F7) : const Color(0xFF94A3B8),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${dish['votes']} votes', style: const TextStyle(fontSize: 10, color: Color(0xFF334155))),
                                      Text('${votePercentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isVoted ? const Color(0xFF7E22CE) : const Color(0xFF475569))),
                                    ],
                                  ),
                                  if (isVoted)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Center(child: Text('✓ Voted', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF7E22CE)))),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    if (_votedDish != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: GlassCard(
                          tint: GlassTint.success,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: const [
                              Text('Vote Recorded!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF064E3B))),
                              SizedBox(height: 4),
                              Text('Thank you for participating. Results will be announced on Sunday.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF047857))),
                            ],
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
    );
  }
}
