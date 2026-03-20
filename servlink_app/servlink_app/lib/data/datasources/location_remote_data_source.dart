import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/cidade_model.dart';

class LocationRemoteDataSource {
  LocationRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<List<CidadeModel>> listarCidades() async {
    final response = await _dio.get('/api/cidades');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => CidadeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
