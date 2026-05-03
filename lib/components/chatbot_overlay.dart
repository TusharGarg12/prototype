import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'glass_card.dart';

class ChatbotOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const ChatbotOverlay({super.key, required this.onClose});

  @override
  State<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<ChatbotOverlay> {
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'type': 'bot',
      'text': "Hi! I'm your SMMS assistant. How can I help you today?",
      'quickActions': ["Today's menu", "Check occupancy", "Report issue", "Leave request"],
    },
  ];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend([String? actionText]) {
    final text = actionText ?? _inputController.text;
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': _messages.length + 1,
        'type': 'user',
        'text': text,
      });
      _inputController.clear();
    });
    
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'id': _messages.length + 2,
          'type': 'bot',
          'text': _getBotResponse(text),
          'quickActions': ["Anything else?", "Check menu", "Done"],
        });
      });
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });
  }

  String _getBotResponse(String userInput) {
    final lower = userInput.toLowerCase();
    if (lower.contains('menu')) {
      return "Today's lunch menu includes Dal Makhani, Jeera Rice, Roti, and Salad. Would you like nutritional info?";
    } else if (lower.contains('occupancy') || lower.contains('crowd')) {
      return "Current occupancy is at 68%. It's a good time to visit! Peak hours are usually 12:30-1:30 PM.";
    } else if (lower.contains('issue') || lower.contains('complaint')) {
      return "I'm sorry to hear that. Please describe the issue and I'll forward it to the mess committee.";
    } else if (lower.contains('leave')) {
      return "You can request leave from the Leave Management section. Would you like me to guide you there?";
    } else {
      return "I understand. Is there anything else I can help you with?";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: const Color(0xFF0F172A).withOpacity(0.40), // Backdrop blur handled by parent or here if needed, but Flutter Stack does well with just color
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent tap from bubbling to close overlay
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              ),
              child: GlassCard(
                level: GlassLevel.level4,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.20))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFDBEAFE).withOpacity(0.70),
                                  border: Border.all(color: const Color(0xFFBFDBFE), width: 0.5),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Text('🤖', style: TextStyle(fontSize: 18)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('SMMS Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                  Row(
                                    children: [
                                      Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
                                      const SizedBox(width: 4),
                                      const Text('Online', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.50),
                              border: Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: widget.onClose,
                                child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF334155)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Messages Area
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUser = message['type'] == 'user';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isUser ? const Color(0xFFDBEAFE).withOpacity(0.70) : Colors.white.withOpacity(0.60),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(16),
                                          topRight: const Radius.circular(16),
                                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                                          bottomRight: Radius.circular(isUser ? 4 : 16),
                                        ),
                                        border: Border.all(
                                          color: isUser ? const Color(0xFFBFDBFE) : Colors.white.withOpacity(0.70),
                                          width: 0.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isUser ? const Color(0xFF3B82F6).withOpacity(0.15) : Colors.black.withOpacity(0.06),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(message['text'], style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                                    ),
                                  ],
                                ),
                                if (message.containsKey('quickActions') && message['quickActions'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8, left: 8),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: (message['quickActions'] as List<String>).map((action) {
                                        return InkWell(
                                          onTap: () => _handleSend(action),
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.50),
                                              border: Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
                                              ],
                                            ),
                                            child: Text(action, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Input Area
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.20))),
                      ),
                      child: GlassCard(
                        level: GlassLevel.level3,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _inputController,
                                onSubmitted: (_) => _handleSend(),
                                decoration: const InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFF475569)),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                                style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.50),
                                border: Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () {},
                                  child: const Icon(LucideIcons.mic, size: 16, color: Color(0xFF334155)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFDBEAFE).withOpacity(0.70),
                                border: Border.all(color: const Color(0xFFBFDBFE), width: 0.5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => _handleSend(),
                                  child: const Icon(LucideIcons.send, size: 16, color: Color(0xFF1D4ED8)),
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
            ),
          ),
        ),
      ),
    );
  }
}
