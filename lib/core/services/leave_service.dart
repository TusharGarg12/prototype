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

  Future<List<dynamic>> getPendingLeaves() async {
    // Admin API Request
    return await api.get('/admin/leaves') as List<dynamic>;
  }

  Future<dynamic> processLeave(String leaveId, String status) async {
    // Admin API Request (APPROVED | REJECTED)
    return await api.patch('/admin/leaves/$leaveId', body: {'status': status});
  }
}

final leaveService = LeaveService.instance;
