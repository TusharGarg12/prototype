import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/models/notification_model.dart';
import '../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await notificationService.getNotifications();
      if (mounted) setState(() { _notifications = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    await notificationService.markAllRead();
    setState(() {
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id, title: n.title, body: n.body,
        channel: n.channel, isRead: true, createdAt: n.createdAt,
      )).toList();
    });
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return GlobalGlassScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.60), border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5)),
                        child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => context.pop(), child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF334155)))),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          if (unread > 0)
                            Text('$unread unread', style: const TextStyle(fontSize: 11, color: Color(0xFF3B82F6))),
                        ],
                      ),
                    ],
                  ),
                  if (unread > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: const Text('Mark all read', style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6), fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                  ? const Center(child: Text('No notifications yet', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, i) {
                        final n = _notifications[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            padding: const EdgeInsets.all(14),
                            onTap: () async {
                              if (!n.isRead) {
                                await notificationService.markRead(n.id);
                                setState(() {
                                  _notifications[i] = NotificationModel(
                                    id: n.id, title: n.title, body: n.body,
                                    channel: n.channel, isRead: true, createdAt: n.createdAt,
                                  );
                                });
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  margin: const EdgeInsets.only(top: 5, right: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: n.isRead ? Colors.transparent : const Color(0xFF3B82F6),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n.title, style: TextStyle(fontSize: 13, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, color: const Color(0xFF0F172A))),
                                      const SizedBox(height: 3),
                                      Text(n.body, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                      const SizedBox(height: 4),
                                      Text(_timeAgo(n.createdAt), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
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
