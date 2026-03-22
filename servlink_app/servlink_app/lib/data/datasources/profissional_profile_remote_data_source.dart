import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/profissional_model.dart';

class ProfissionalProfileRemoteDataSource {
  ProfissionalProfileRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<ProfissionalModel> criarOuObter() async {
    final response = await _dio.post('/api/profissionais/me');
    return ProfissionalModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProfissionalModel> obter() async {
    final response = await _dio.get('/api/profissionais/me');
    return ProfissionalModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProfissionalModel> atualizar({
    String? descricao,
    String? fotoUrl,
    int? anosExperiencia,
    String? bairro,
    int? cidadeId,
    int? categoriaId,
  }) async {
    final data = <String, dynamic>{};
    if (descricao != null) data['descricao'] = descricao;
    if (fotoUrl != null) data['fotoUrl'] = fotoUrl;
    if (anosExperiencia != null) data['anosExperiencia'] = anosExperiencia;
    if (bairro != null) data['bairro'] = bairro;
    if (cidadeId != null) data['cidadeId'] = cidadeId;
    if (categoriaId != null) data['categoriaId'] = categoriaId;

    final response = await _dio.patch(
      '/api/profissionais/me',
      data: data,
    );
    return ProfissionalModel.fromJson(response.data as Map<String, dynamic>);
  }
}
