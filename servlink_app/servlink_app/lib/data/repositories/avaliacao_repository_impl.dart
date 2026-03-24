import '../../domain/entities/avaliacao_entity.dart';
import '../../domain/repositories/avaliacao_repository.dart';
import '../datasources/avaliacao_remote_data_source.dart';

class AvaliacaoRepositoryImpl implements AvaliacaoRepository {
  AvaliacaoRepositoryImpl(this._remote);

  final AvaliacaoRemoteDataSource _remote;

  @override
  Future<void> criarAvaliacao({
    required int profissionalId,
    required int nota,
    String? comentario,
  }) {
    return _remote.criarAvaliacao(
      profissionalId: profissionalId,
      nota: nota,
      comentario: comentario,
    );
  }

  @override
  Future<List<AvaliacaoEntity>> listarAvaliacoesPorProfissional(
    int profissionalId,
  ) async {
    final result =
        await _remote.listarAvaliacoesPorProfissional(profissionalId);
    return result.map((e) => e.toEntity()).toList();
  }
}
