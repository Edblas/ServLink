import '../entities/vaga_entity.dart';
import '../entities/candidatura_entity.dart';

abstract class VagaRepository {
  Future<List<VagaEntity>> listarVagas();

  Future<VagaEntity> obterVaga(int id);

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
  });

  Future<VagaEntity> atualizarVaga({
    required int id,
    required String titulo,
    required String descricao,
    required double valor,
    required int cidadeId,
    required DateTime dataTrabalho,
    required int categoriaId,
    required String urgencia,
    required String tipo,
    int? diasExpiracao,
  });

  Future<void> candidatar(int vagaId);

  Future<List<CandidaturaEntity>> listarCandidatosDaVaga(int vagaId);

  Future<void> atualizarStatusCandidatura({
    required int candidaturaId,
    required String status,
  });

  Future<void> apagarVaga(int vagaId);
}
