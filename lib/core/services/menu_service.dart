import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/menu_model.dart';

class MenuService {
  MenuService._();
  static final MenuService instance = MenuService._();

  Future<List<MenuModel>> getTodayMenu() async {
    final data = await api.get(kMenuToday);
    return (data as List<dynamic>)
        .map((e) => MenuModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MenuModel>> getWeeklyMenu() async {
    final data = await api.get(kMenuWeek);
    return (data as List<dynamic>)
        .map((e) => MenuModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createMenu({required String date, required String mealType, required List<Map<String, dynamic>> dishes}) async {
    // Admin API Request to create/publish a menu
    await api.post('/menu', body: {
      'date': date,
      'mealType': mealType,
      'dishes': dishes,
    });
  }
}

final menuService = MenuService.instance;
