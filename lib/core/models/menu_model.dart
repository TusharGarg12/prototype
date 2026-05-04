class DishModel {
  final String id;
  final String name;
  final String category;
  final bool isVeg;
  final String? description;

  const DishModel({
    required this.id,
    required this.name,
    required this.category,
    required this.isVeg,
    this.description,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) => DishModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        isVeg: json['isVeg'] as bool? ?? true,
        description: json['description'] as String?,
      );
}

class MenuItemModel {
  final String id;
  final DishModel dish;

  const MenuItemModel({required this.id, required this.dish});

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        id: json['id'] as String,
        dish: DishModel.fromJson(json['dish'] as Map<String, dynamic>),
      );
}

class MenuModel {
  final String id;
  final String mealSlot;
  final DateTime menuDate;
  final bool isPublished;
  final List<MenuItemModel> menuItems;

  const MenuModel({
    required this.id,
    required this.mealSlot,
    required this.menuDate,
    required this.isPublished,
    required this.menuItems,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        id: json['id'] as String,
        mealSlot: json['mealSlot'] as String,
        menuDate: DateTime.parse(json['menuDate'] as String),
        isPublished: json['isPublished'] as bool? ?? false,
        menuItems: (json['menuItems'] as List<dynamic>? ?? [])
            .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  List<DishModel> get dishes => menuItems.map((mi) => mi.dish).toList();

  String get slotLabel {
    switch (mealSlot) {
      case 'BREAKFAST': return 'Breakfast';
      case 'LUNCH':     return 'Lunch';
      case 'SNACKS':    return 'Snacks';
      case 'DINNER':    return 'Dinner';
      default:          return mealSlot;
    }
  }
}
