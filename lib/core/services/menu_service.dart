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

  Future<List<MenuModel>> queryMenus({String? date, String? mealSlot}) async {
    final data = await api.get(kMenuAdmin, params: {
      if (date != null) 'date': date,
      if (mealSlot != null) 'mealSlot': mealSlot,
    });
    return (data as List<dynamic>)
        .map((e) => MenuModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MenuModel> createMenu({
    required DateTime menuDate,
    required String mealSlot,
    required List<String> dishIds,
    bool isPublished = false,
  }) async {
    final data = await api.post(kMenuAdmin, body: {
      'menuDate': _formatDate(menuDate),
      'mealSlot': mealSlot,
      'dishIds': dishIds,
      'isPublished': isPublished,
    });
    return MenuModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MenuModel> updateMenu({
    required String id,
    List<String>? dishIds,
    bool? isPublished,
  }) async {
    final data = await api.patch('$kMenuAdmin/$id', body: {
      if (dishIds != null) 'dishIds': dishIds,
      if (isPublished != null) 'isPublished': isPublished,
    });
    return MenuModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteMenu(String id) async {
    await api.delete('$kMenuAdmin/$id');
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

final menuService = MenuService.instance;
