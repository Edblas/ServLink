import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _apiBaseUrlKey = 'api_base_url';
  static const String _themeModeKey = 'theme_mode';

  Future<void> saveAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> clearAccessToken() {
    return _storage.delete(key: _accessTokenKey);
  }

  Future<void> saveApiBaseUrl(String baseUrl) {
    return _storage.write(key: _apiBaseUrlKey, value: baseUrl);
  }

  Future<String?> getApiBaseUrl() {
    return _storage.read(key: _apiBaseUrlKey);
  }

  Future<void> clearApiBaseUrl() {
    return _storage.delete(key: _apiBaseUrlKey);
  }

  Future<void> saveThemeMode(String mode) {
    return _storage.write(key: _themeModeKey, value: mode);
  }

  Future<String?> getThemeMode() {
    return _storage.read(key: _themeModeKey);
  }

  Future<void> saveString(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) {
    return _storage.read(key: key);
  }

  Future<void> deleteKey(String key) {
    return _storage.delete(key: key);
  }
}
