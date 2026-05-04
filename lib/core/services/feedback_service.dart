import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  Future<void> submitFeedback({
    required int rating,
    String? message,
    String? mealSlot,
    bool isAnon = false,
  }) async {
    await api.post(kFeedback, body: {
      'rating':   rating,
      if (message != null) 'message': message,
      if (mealSlot != null) 'mealSlot': mealSlot,
      'isAnon': isAnon,
    });
  }
}

final feedbackService = FeedbackService.instance;
