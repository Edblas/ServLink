import '../../domain/entities/vaga_entity.dart';
import '../../domain/entities/candidatura_entity.dart';
import '../../domain/repositories/vaga_repository.dart';
import '../datasources/vaga_remote_data_source.dart';

class VagaRepositoryImpl implements VagaRepository {
  VagaRepositoryImpl(this._remote);

  final VagaRemoteDataSource _remote;

  @override
  Future<List<VagaEntity>> listarVagas() async {
    final result = await _remote.listarVagas();
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<VagaEntity> obterVaga(int id) async {
    final result = await _remote.obterVaga(id);
    return result.toEntity();
  }

  @override
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
    final result = await _remote.criarVaga(
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
    return result.toEntity();
  }

  @override
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
  }) async {
    final result = await _remote.atualizarVaga(
      id: id,
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
    return result.toEntity();
  }

  @override
  Future<void> candidatar(int vagaId) {
    return _remote.candidatar(vagaId);
  }

  @override
  Future<List<CandidaturaEntity>> listarCandidatosDaVaga(int vagaId) async {
    final result = await _remote.getCandidatosDaVaga(vagaId);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> atualizarStatusCandidatura({
    required int candidaturaId,
    required String status,
  }) {
    return _remote.atualizarStatusCandidatura(
      candidaturaId: candidaturaId,
      status: status,
    );
  }

  @override
  Future<void> apagarVaga(int vagaId) {
    return _remote.apagarVaga(vagaId);
  }
}
