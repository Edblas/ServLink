import '../entities/avaliacao_entity.dart';

abstract class AvaliacaoRepository {
  Future<void> criarAvaliacao({
    required int profissionalId,
    required int nota,
    required String comentario,
  });

  Future<List<AvaliacaoEntity>> listarAvaliacoesPorProfissional(int profissionalId);
}
