import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import 'auth_providers.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController(this._storage) : super(ThemeMode.system) {
    _load();
  }

  final SecureStorageService _storage;

  Future<void> _load() async {
    final value = await _storage.getThemeMode();
    state = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.saveThemeMode(value);
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ThemeController(storage);
});

final apiBaseUrlProvider = FutureProvider<String?>((ref) async {
  final storage = ref.read(secureStorageProvider);
  return storage.getApiBaseUrl();
});

