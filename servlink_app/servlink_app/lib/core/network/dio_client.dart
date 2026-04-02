import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  DioClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;
          final isAuthRoute =
              path.startsWith('/api/auth/') || path.startsWith('/api/health');
          if (!isAuthRoute) {
            try {
              final token = await _storage
                  .getAccessToken()
                  .timeout(const Duration(seconds: 2));
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (_) {}
          }
          handler.next(options);
        },
      ),
    );
  }

  late final Dio dio;
  final SecureStorageService _storage;
}
