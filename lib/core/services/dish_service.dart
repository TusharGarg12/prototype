import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/menu_model.dart';

class DishService {
  DishService._();
  static final DishService instance = DishService._();

  Future<List<DishModel>> listDishes({bool activeOnly = true}) async {
    final data = await api.get(kDishes, params: {
      'activeOnly': activeOnly,
    });
    return (data as List<dynamic>)
        .map((e) => DishModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final dishService = DishService.instance;
