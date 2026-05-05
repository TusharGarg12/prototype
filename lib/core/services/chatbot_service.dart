import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class ChatbotService {
  ChatbotService._();
  static final ChatbotService instance = ChatbotService._();

  Future<String> ask(String message) async {
    final data = await api.post(kChatbotAsk, body: {'message': message});
    final reply = (data as Map<String, dynamic>)['reply'];
    return reply is String ? reply : 'I could not generate a reply right now.';
  }
}

final chatbotService = ChatbotService.instance;