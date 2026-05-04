class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? rollNumber;
  final String? photoUrl;
  final bool isActive;
  final int rewardPoints;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.rollNumber,
    this.photoUrl,
    this.isActive = true,
    this.rewardPoints = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        rollNumber: json['rollNumber'] as String?,
        photoUrl: json['photoUrl'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        rewardPoints: json['rewardPoints'] as int? ?? 0,
      );

  /// Initials for avatar (first letter of each name part, max 2)
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  bool get isAdmin => role == 'ADMIN';
  bool get isStudent => role == 'STUDENT';
  bool get isKitchen => role == 'KITCHEN_STAFF';
}
