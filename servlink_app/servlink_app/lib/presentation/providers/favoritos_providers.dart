import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../data/datasources/favoritos_local_data_source.dart';
import '../../data/repositories/favoritos_repository_impl.dart';
import '../../domain/entities/profissional_entity.dart';
import '../../domain/repositories/favoritos_repository.dart';
import 'auth_providers.dart';

final favoritosRepositoryProvider = Provider<FavoritosRepository>((ref) {
  final storage = ref.read(secureStorageProvider);
  return FavoritosRepositoryImpl(FavoritosLocalDataSource(storage));
});

class FavoritosController
    extends StateNotifier<AsyncValue<List<ProfissionalEntity>>> {
  FavoritosController(this._repository) : super(const AsyncLoading()) {
    _load();
  }

  final FavoritosRepository _repository;

  Future<void> _load() async {
    try {
      final result = await _repository.listar();
      state = AsyncData(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggle(ProfissionalEntity profissional) async {
    final current = state.value ?? const <ProfissionalEntity>[];
    final exists = current.any((p) => p.id == profissional.id);
    final next = exists
        ? current.where((p) => p.id != profissional.id).toList(growable: false)
        : [...current, profissional];

    state = AsyncData(next);
    try {
      await _repository.salvar(next);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  bool isFavorito(int profissionalId) {
    final current = state.value;
    if (current == null) return false;
    return current.any((p) => p.id == profissionalId);
  }
}

final favoritosControllerProvider = StateNotifierProvider<FavoritosController,
    AsyncValue<List<ProfissionalEntity>>>((ref) {
  final repository = ref.read(favoritosRepositoryProvider);
  return FavoritosController(repository);
});

class VagasFavoritasController extends StateNotifier<AsyncValue<Set<int>>> {
  VagasFavoritasController(this._storage) : super(const AsyncLoading()) {
    _load();
  }

  final SecureStorageService _storage;

  static const String _key = 'favoritos_vagas_ids_v1';

  Future<void> _load() async {
    try {
      final raw = await _storage.getString(_key);
      if (raw == null || raw.trim().isEmpty) {
        state = const AsyncData(<int>{});
        return;
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      final ids = decoded.map((e) => e as int).toSet();
      state = AsyncData(ids);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  bool isFavorito(int vagaId) {
    final current = state.value;
    if (current == null) return false;
    return current.contains(vagaId);
  }

  Future<void> toggle(int vagaId) async {
    final current = state.value ?? <int>{};
    final next = {...current};
    if (next.contains(vagaId)) {
      next.remove(vagaId);
    } else {
      next.add(vagaId);
    }

    state = AsyncData(next);
    try {
      await _storage.saveString(
        _key,
        jsonEncode(next.toList(growable: false)),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final vagasFavoritasControllerProvider =
    StateNotifierProvider<VagasFavoritasController, AsyncValue<Set<int>>>((ref) {
  final storage = ref.read(secureStorageProvider);
  return VagasFavoritasController(storage);
});
