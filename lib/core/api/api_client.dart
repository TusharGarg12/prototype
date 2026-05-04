import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _dio = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));

    // ── Request interceptor: attach Bearer token ────────────────────────────
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (err, handler) async {
        // ── Auto-refresh on 401 ─────────────────────────────────────────────
        if (err.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          final refresh = prefs.getString('refresh_token');
          if (refresh != null) {
            try {
              final resp = await _dio.post(kRefreshToken,
                  data: {'refreshToken': refresh},
                  options: Options(headers: {'Authorization': null}));
              final newToken = resp.data['data']['accessToken'] as String;
              await prefs.setString('access_token', newToken);

              // Retry original request with new token
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              final retry = await _dio.fetch(opts);
              return handler.resolve(retry);
            } catch (_) {
              // Refresh failed — clear tokens so app routes to login
              await prefs.remove('access_token');
              await prefs.remove('refresh_token');
            }
          }
        }
        return handler.next(err);
      },
    ));

    _initialized = true;
  }

  Dio get dio {
    if (!_initialized) init();
    return _dio;
  }

  // ── Convenience wrappers ──────────────────────────────────────────────────

  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    final res = await dio.get(path, queryParameters: params);
    return res.data['data'];
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    final res = await dio.post(path, data: body);
    return res.data['data'];
  }

  Future<dynamic> patch(String path, {dynamic body}) async {
    final res = await dio.patch(path, data: body);
    return res.data['data'];
  }

  Future<dynamic> delete(String path) async {
    final res = await dio.delete(path);
    return res.data['data'];
  }
}

final api = ApiClient.instance;
