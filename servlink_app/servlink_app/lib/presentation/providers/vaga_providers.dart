import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/vaga_remote_data_source.dart';
import '../../data/repositories/vaga_repository_impl.dart';
import '../../domain/entities/candidatura_entity.dart';
import '../../domain/entities/vaga_entity.dart';
import '../../domain/repositories/vaga_repository.dart';
import 'auth_providers.dart';

final vagaRepositoryProvider = Provider<VagaRepository>((ref) {
  final client = ref.read(dioClientProvider);
  return VagaRepositoryImpl(VagaRemoteDataSource(client));
});

final vagasProvider = FutureProvider.autoDispose<List<VagaEntity>>((ref) async {
  final repository = ref.read(vagaRepositoryProvider);
  return repository.listarVagas();
});

final vagaDetailProvider =
    FutureProvider.autoDispose.family<VagaEntity, int>((ref, id) async {
  final repository = ref.read(vagaRepositoryProvider);
  return repository.obterVaga(id);
});

final candidatosProvider = FutureProvider.autoDispose
    .family<List<CandidaturaEntity>, int>((ref, vagaId) async {
  final repository = ref.read(vagaRepositoryProvider);
  return repository.listarCandidatosDaVaga(vagaId);
});

class VagaActionController extends StateNotifier<AsyncValue<void>> {
  VagaActionController(this._repository) : super(const AsyncData(null));

  final VagaRepository _repository;

  Future<void> candidatar(int vagaId) async {
    state = const AsyncLoading();
    try {
      await _repository.candidatar(vagaId);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<VagaEntity> criarVaga({
    required String titulo,
    required String descricao,
    required double valor,
    required int cidadeId,
    required DateTime dataTrabalho,
    required int categoriaId,
    required String urgencia,
    required String tipo,
    int? diasExpiracao,
  }) async {
    state = const AsyncLoading();
    try {
      final vaga = await _repository.criarVaga(
        titulo: titulo,
        descricao: descricao,
        valor: valor,
        cidadeId: cidadeId,
        dataTrabalho: dataTrabalho,
        categoriaId: categoriaId,
        urgencia: urgencia,
        tipo: tipo,
        diasExpiracao: diasExpiracao,
      );
      state = const AsyncData(null);
      return vaga;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> apagarVaga(int vagaId) async {
    state = const AsyncLoading();
    try {
      await _repository.apagarVaga(vagaId);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> atualizarStatusCandidatura({
    required int candidaturaId,
    required String status,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.atualizarStatusCandidatura(
        candidaturaId: candidaturaId,
        status: status,
      );
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final vagaActionControllerProvider =
    StateNotifierProvider<VagaActionController, AsyncValue<void>>((ref) {
  final repository = ref.read(vagaRepositoryProvider);
  return VagaActionController(repository);
});
