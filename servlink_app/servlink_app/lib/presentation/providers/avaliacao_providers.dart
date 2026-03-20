import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/avaliacao_remote_data_source.dart';
import '../../data/repositories/avaliacao_repository_impl.dart';
import '../../domain/entities/avaliacao_entity.dart';
import '../../domain/repositories/avaliacao_repository.dart';
import 'auth_providers.dart';

final avaliacaoRepositoryProvider = Provider<AvaliacaoRepository>((ref) {
  final client = ref.read(dioClientProvider);
  return AvaliacaoRepositoryImpl(AvaliacaoRemoteDataSource(client));
});

final avaliacoesPorProfissionalProvider = FutureProvider.autoDispose
    .family<List<AvaliacaoEntity>, int>((ref, profissionalId) async {
  final repository = ref.read(avaliacaoRepositoryProvider);
  return repository.listarAvaliacoesPorProfissional(profissionalId);
});

class AvaliacaoFormController extends StateNotifier<AsyncValue<void>> {
  AvaliacaoFormController(this._repository, this._ref)
      : super(const AsyncData(null));

  final AvaliacaoRepository _repository;
  final Ref _ref;

  Future<void> enviar({
    required int profissionalId,
    required int nota,
    required String comentario,
  }) async {
    state = const AsyncLoading();
    try {
      final authState = _ref.read(authControllerProvider);
      final session = authState.session;
      if (session == null) {
        throw Exception('Usuário não autenticado');
      }
      await _repository.criarAvaliacao(
        profissionalId: profissionalId,
        nota: nota,
        comentario: comentario,
      );
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final avaliacaoFormControllerProvider =
    StateNotifierProvider<AvaliacaoFormController, AsyncValue<void>>((ref) {
  final repository = ref.read(avaliacaoRepositoryProvider);
  return AvaliacaoFormController(repository, ref);
});
