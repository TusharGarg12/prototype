import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class OptimizationService {
  OptimizationService._();
  static final OptimizationService instance = OptimizationService._();

  Future<Map<String, dynamic>> getSurgeRecommendation({
    required String date,
    required String mealSlot,
    int totalStudents = 600,
    int totalCapacity = 600,
    String? academicEvent,
    bool isRaining = false,
  }) async {
    final data = await api.post(kOptimizationSurge, body: {
      'date': date,
      'mealSlot': mealSlot,
      'totalStudents': totalStudents,
      'totalCapacity': totalCapacity,
      if (academicEvent != null && academicEvent.trim().isNotEmpty) 'academicEvent': academicEvent.trim(),
      'isRaining': isRaining,
    });
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWasteRecommendation({
    required String date,
    required String mealSlot,
    required List<String> menuItems,
    int totalStudents = 600,
    int totalCapacity = 600,
    String? academicEvent,
    bool isRaining = false,
  }) async {
    final data = await api.post(kOptimizationWaste, body: {
      'date': date,
      'mealSlot': mealSlot,
      'menuItems': menuItems,
      'totalStudents': totalStudents,
      'totalCapacity': totalCapacity,
      if (academicEvent != null && academicEvent.trim().isNotEmpty) 'academicEvent': academicEvent.trim(),
      'isRaining': isRaining,
    });
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMenuGuidance({
    required String date,
    required String mealSlot,
    required List<String> menuItems,
    int totalStudents = 600,
    String? weather,
    double? temperatureC,
    String? academicEvent,
    String? branchName,
  }) async {
    final data = await api.post(kOptimizationMenuGuidance, body: {
      'date': date,
      'mealSlot': mealSlot,
      'menuItems': menuItems,
      'totalStudents': totalStudents,
      if (weather != null && weather.trim().isNotEmpty) 'weather': weather.trim(),
      if (temperatureC != null) 'temperatureC': temperatureC,
      if (academicEvent != null && academicEvent.trim().isNotEmpty) 'academicEvent': academicEvent.trim(),
      if (branchName != null && branchName.trim().isNotEmpty) 'branchName': branchName.trim(),
    });
    return data as Map<String, dynamic>;
  }
}

final optimizationService = OptimizationService.instance;