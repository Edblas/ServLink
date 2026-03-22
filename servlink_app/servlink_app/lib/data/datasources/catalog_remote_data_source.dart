import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/categoria_model.dart';
import '../models/profissional_model.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<List<CategoriaModel>> listarCategorias() async {
    final response = await _dio.get('/api/categorias');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => CategoriaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProfissionalModel>> listarProfissionais({
    required int page,
    required int size,
    int? cidadeId,
    int? categoriaId,
    String? q,
    String? bairro,
  }) async {
    final queryParameters = <String, dynamic>{
      'pagina': page,
      'tamanho': size,
    };
    if (cidadeId != null) {
      queryParameters['cidadeId'] = cidadeId;
    }
    if (categoriaId != null) {
      queryParameters['categoriaId'] = categoriaId;
    }
    if (q != null && q.trim().isNotEmpty) {
      queryParameters['q'] = q.trim();
    }
    if (bairro != null && bairro.trim().isNotEmpty) {
      queryParameters['bairro'] = bairro.trim();
    }
    final response = await _dio.get(
      '/api/profissionais',
      queryParameters: queryParameters,
    );
    final content = (response.data['content'] as List<dynamic>);
    return content
        .map((e) => ProfissionalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
