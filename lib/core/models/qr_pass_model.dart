class QrPassModel {
  final String token;
  final String mealSlot;
  final DateTime mealDate;
  final DateTime expiresAt;

  const QrPassModel({
    required this.token,
    required this.mealSlot,
    required this.mealDate,
    required this.expiresAt,
  });

  factory QrPassModel.fromJson(Map<String, dynamic> json) => QrPassModel(
        token: json['token'] as String,
        mealSlot: json['mealSlot'] as String,
        mealDate: DateTime.parse(json['mealDate'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  Duration get timeRemaining => expiresAt.difference(DateTime.now());
  bool get isExpired => timeRemaining.isNegative;

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
