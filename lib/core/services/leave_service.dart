import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/leave_model.dart';

class LeaveService {
  LeaveService._();
  static final LeaveService instance = LeaveService._();

  Future<List<LeaveModel>> getMyLeaves({String? status}) async {
    final params = <String, dynamic>{'page': 1, 'limit': 20};
    if (status != null) params['status'] = status;
    final data = await api.get(kLeavesMe, params: params);
    return ((data as Map<String, dynamic>)['leaves'] as List<dynamic>)
        .map((e) => LeaveModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LeaveModel> createLeave({
    required String fromDate,
    required String toDate,
    String? reason,
  }) async {
    final data = await api.post(kLeaves, body: {
      'fromDate': fromDate,
      'toDate':   toDate,
      if (reason != null) 'reason': reason,
    });
    return LeaveModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LeaveModel> cancelLeave(String leaveId) async {
    final data = await api.patch('$kLeavesMe/$leaveId/cancel');
    return LeaveModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<LeaveModel>> getAdminLeaves({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) params['status'] = status;
    final data = await api.get(kLeaves, params: params);
    return ((data as Map<String, dynamic>)['leaves'] as List<dynamic>)
        .map((e) => LeaveModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LeaveModel> processLeave(String leaveId, String status, {String? reviewNote}) async {
    final data = await api.patch('$kLeaves/$leaveId/review', body: {
      'status': status,
      if (reviewNote != null && reviewNote.trim().isNotEmpty) 'reviewNote': reviewNote.trim(),
    });
    return LeaveModel.fromJson(data as Map<String, dynamic>);
  }
}

final leaveService = LeaveService.instance;
