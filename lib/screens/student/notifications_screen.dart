import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    { 'id': 1, 'type': 'surge', 'title': 'Happy Hour Active!', 'message': 'Earn +30 bonus points by visiting the mess before 3:00 PM', 'time': '5 min ago', 'read': false },
    { 'id': 2, 'type': 'menu', 'title': "Tomorrow's Menu Published", 'message': 'Special Saturday menu includes Paneer Tikka and Gulab Jamun', 'time': '1 hour ago', 'read': false },
    { 'id': 3, 'type': 'leave', 'title': 'Leave Request Approved', 'message': 'Your leave request for Apr 25-26 has been approved', 'time': '2 hours ago', 'read': true },
    { 'id': 4, 'type': 'vote', 'title': 'Vote for Next Week', 'message': 'Poll closes in 2 days. Vote for your favorite dishes now!', 'time': '5 hours ago', 'read': true },
    { 'id': 5, 'type': 'system', 'title': 'Mess Closed for Maintenance', 'message': 'Dinner service will start 30 minutes late today', 'time': '1 day ago', 'read': true },
    { 'id': 6, 'type': 'reward', 'title': 'Milestone Achieved!', 'message': 'Congratulations! You reached 1000 reward points', 'time': '2 days ago', 'read': true },
  ];

  int get _unreadCount => _notifications.where((n) => !(n['read'] as bool)).length;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });
  }

  String _getNotificationIcon(String type) {
    switch (type) {
      case 'surge': return '⚡';
      case 'menu': return '🍽️';
      case 'leave': return '✅';
      case 'vote': return '🗳️';
      case 'reward': return '🎁';
      default: return '🔔';
    }
  }

  Color _getNotificationColor(String type, bool read) {
    if (read) return Colors.white.withOpacity(0.50);
    switch (type) {
      case 'surge': return const Color(0xFFFFFBEB).withOpacity(0.70); // amber-50
      case 'menu': return const Color(0xFFECFDF5).withOpacity(0.70); // emerald-50
      case 'leave': return const Color(0xFFEFF6FF).withOpacity(0.70); // blue-50
      case 'vote': return const Color(0xFFFAF5FF).withOpacity(0.70); // purple-50
      case 'reward': return const Color(0xFFFFF1F2).withOpacity(0.70); // rose-50
      default: return Colors.white.withOpacity(0.60);
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                          const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                        ],
                      ),
                      if (_unreadCount > 0)
                        InkWell(
                          onTap: _markAllRead,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.60),
                              border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              children: const [
                                Icon(LucideIcons.checkCheck, size: 14, color: Color(0xFF1D4ED8)),
                                SizedBox(width: 4),
                                Text('Mark all read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8))),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        _unreadCount > 0 ? '$_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}' : 'All caught up!',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final isRead = notification['read'] as bool;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: !isRead ? const Border(left: BorderSide(color: Color(0xFF60A5FA), width: 4)) : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: _getNotificationColor(notification['type'], isRead),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.70),
                              border: Border.all(color: Colors.white.withOpacity(0.80), width: 0.5),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(_getNotificationIcon(notification['type']), style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(notification['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 4, left: 8),
                                        decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification['message'],
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(notification['time'], style: const TextStyle(fontSize: 10, color: Color(0xFF475569))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
