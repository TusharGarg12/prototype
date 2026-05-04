import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false}) async {
    final data = await api.get(kNotifications,
        params: {'page': 1, 'limit': 20, 'unreadOnly': unreadOnly});
    return ((data as Map<String, dynamic>)['notifications'] as List<dynamic>)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    await api.patch('$kNotifications/$id/read');
  }

  Future<void> markAllRead() async {
    await api.patch('$kNotifications/read-all');
  }
}

final notificationService = NotificationService.instance;
