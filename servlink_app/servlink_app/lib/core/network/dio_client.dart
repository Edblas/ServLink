import 'package:dio/dio.dart';
import 'dart:io';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  DioClient(this._storage) {
    final baseUrl = _resolveBaseUrl();
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  late final Dio dio;
  final SecureStorageService _storage;

  String _resolveBaseUrl() {
    final normalized = AppConfig.normalizeApiBaseUrl(AppConfig.apiBaseUrl);
    if (normalized.isEmpty) return normalized;

    if (!Platform.isAndroid) return normalized;

    try {
      final uri = Uri.parse(normalized);
      final host = uri.host.toLowerCase();
      if (host != 'localhost' && host != '127.0.0.1') return normalized;

      return uri
          .replace(host: '10.0.2.2')
          .toString();
    } catch (_) {
      return normalized;
    }
  }
}
