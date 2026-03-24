import 'package:flutter_riverpod/flutter_riverpod.dart';
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

