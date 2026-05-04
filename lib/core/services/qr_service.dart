import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/qr_pass_model.dart';

class QrService {
  QrService._();
  static final QrService instance = QrService._();

  /// Generates (or refreshes) the QR pass for the current meal slot.
  Future<QrPassModel> generatePass({String? mealSlot}) async {
    final body = mealSlot != null ? {'mealSlot': mealSlot} : <String, dynamic>{};
    final data = await api.post(kQrGenerate, body: body);
    return QrPassModel.fromJson(data as Map<String, dynamic>);
  }

  /// Admin/Staff validates a student QR
  Future<Map<String, dynamic>> validatePass(String token, {String? counterId}) async {
    final body = {
      'token': token,
      if (counterId != null) 'counterId': counterId,
    };
    final data = await api.post(kQrValidate, body: body);
    return data as Map<String, dynamic>;
  }
}

final qrService = QrService.instance;
