import 'dart:async';
import 'dart:io';
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
        sendTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.headers['Authorization'] == null) {
            try {
              final token = await _storage
                  .getAccessToken()
                  .timeout(const Duration(seconds: 8));
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (_) {}
          }
          handler.next(options);
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final request = error.requestOptions;
          final shouldRetry = _shouldRetry(error);
          final attempt = (request.extra['retry_attempt'] as int?) ?? 0;
          if (shouldRetry && attempt < 2) {
            const delays = [Duration(seconds: 1), Duration(seconds: 2)];
            await Future.delayed(delays[attempt]);
            request.extra['retry_attempt'] = attempt + 1;
            try {
              final response = await dio.fetch(request);
              return handler.resolve(response);
            } catch (_) {
              return handler.next(error);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio dio;
  final SecureStorageService _storage;

  void setAccessToken(String? token) {
    if (token == null || token.trim().isEmpty) {
      dio.options.headers.remove('Authorization');
      return;
    }
    dio.options.headers['Authorization'] = 'Bearer ${token.trim()}';
  }

  bool _shouldRetry(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return true;
    }
    final status = error.response?.statusCode ?? 0;
    if (status == 502 || status == 503 || status == 504) {
      return true;
    }
    if (error.error is SocketException) {
      return true;
    }
    return false;
  }
}
