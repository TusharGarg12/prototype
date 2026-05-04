import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  Future<List<Map<String, dynamic>>> getHeatmap({String? date, String? mealSlot}) async {
    final data = await api.get(kAnalyticsHeatmap, params: {
      if (date != null) 'date': date,
      if (mealSlot != null) 'mealSlot': mealSlot,
    });
    return (data['heatmap'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getFootfallSummary({required String date}) async {
    final data = await api.get(kFootfall, params: {'date': date});
    return (data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getRatingSummary({required String date}) async {
    final data = await api.get(kFeedbackSummary, params: {'date': date});
    return (data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPredictions({int days = 7, String? start}) async {
    final data = await api.get(kAnalyticsPredictions, params: {
      'days': days,
      if (start != null) 'start': start,
    });
    return ((data as Map<String, dynamic>)['predictions'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}

final analyticsService = AnalyticsService.instance;
