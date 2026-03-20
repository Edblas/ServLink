import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/avaliacao_model.dart';

class AvaliacaoRemoteDataSource {
  AvaliacaoRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<void> criarAvaliacao({
    required int profissionalId,
    required int nota,
    required String comentario,
  }) async {
    await _dio.post(
      '/api/avaliacoes',
      data: {
        'profissionalId': profissionalId,
        'nota': nota,
        'comentario': comentario,
      },
    );
  }

  Future<List<AvaliacaoModel>> listarAvaliacoesPorProfissional(
    int profissionalId,
  ) async {
    final response = await _dio.get(
      '/api/profissionais/$profissionalId/avaliacoes',
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => AvaliacaoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
