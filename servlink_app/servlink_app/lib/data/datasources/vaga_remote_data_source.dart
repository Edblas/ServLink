import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/candidatura_model.dart';
import '../models/vaga_model.dart';

class VagaRemoteDataSource {
  VagaRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<List<VagaModel>> listarVagas() async {
    final response = await _dio.get('/api/vagas');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => VagaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VagaModel> obterVaga(int id) async {
    final response = await _dio.get('/api/vagas/$id');
    return VagaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VagaModel> criarVaga({
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
    final date = '${dataTrabalho.year.toString().padLeft(4, '0')}-'
        '${dataTrabalho.month.toString().padLeft(2, '0')}-'
        '${dataTrabalho.day.toString().padLeft(2, '0')}';
    final response = await _dio.post(
      '/api/vagas',
      data: {
        'titulo': titulo,
        'descricao': descricao,
        'valor_estimado': valor,
        'cidadeId': cidadeId,
        'dataTrabalho': date,
        'urgencia': urgencia,
        'tipo': tipo,
        'categoriaId': categoriaId,
        if (diasExpiracao != null) 'dias_expiracao': diasExpiracao,
      },
    );
    return VagaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VagaModel> atualizarVaga({
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
    final date = '${dataTrabalho.year.toString().padLeft(4, '0')}-'
        '${dataTrabalho.month.toString().padLeft(2, '0')}-'
        '${dataTrabalho.day.toString().padLeft(2, '0')}';
    final response = await _dio.put(
      '/api/vagas/$id',
      data: {
        'titulo': titulo,
        'descricao': descricao,
        'valor_estimado': valor,
        'cidadeId': cidadeId,
        'dataTrabalho': date,
        'urgencia': urgencia,
        'tipo': tipo,
        'categoriaId': categoriaId,
        if (diasExpiracao != null) 'dias_expiracao': diasExpiracao,
      },
    );
    return VagaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> candidatar(int vagaId) async {
    await _dio.post('/api/vagas/$vagaId/candidatar');
  }

  Future<List<CandidaturaModel>> getCandidatosDaVaga(int vagaId) async {
    final response = await _dio.get('/api/vagas/$vagaId/candidatos');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => CandidaturaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> atualizarStatusCandidatura({
    required int candidaturaId,
    required String status,
  }) async {
    await _dio.patch(
      '/api/candidaturas/$candidaturaId/status',
      data: {
        'status': status,
      },
    );
  }

  Future<void> apagarVaga(int vagaId) async {
    await _dio.delete('/api/vagas/$vagaId');
  }
}
