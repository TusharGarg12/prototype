class LeaveModel {
  final String id;
  final String userId;
  final DateTime fromDate;
  final DateTime toDate;
  final String? reason;
  final String status;
  final String? reviewNote;
  final DateTime createdAt;
  final String? userName;
  final String? userEmail;
  final String? rollNumber;

  const LeaveModel({
    required this.id,
    required this.userId,
    required this.fromDate,
    required this.toDate,
    this.reason,
    required this.status,
    this.reviewNote,
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.rollNumber,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        fromDate: DateTime.parse(json['fromDate'] as String),
        toDate: DateTime.parse(json['toDate'] as String),
        reason: json['reason'] as String?,
        status: json['status'] as String,
        reviewNote: json['reviewNote'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        userName: (json['user'] as Map<String, dynamic>?)?['name'] as String?,
        userEmail: (json['user'] as Map<String, dynamic>?)?['email'] as String?,
        rollNumber: (json['user'] as Map<String, dynamic>?)?['rollNumber'] as String?,
      );

  bool get isPending  => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
}
