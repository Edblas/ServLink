import '../../core/network/dio_client.dart';
import '../models/carona_model.dart';

class CaronaRemoteDataSource {
  CaronaRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<CaronaModel>> listar() async {
    final res = await _client.dio.get('/api/caronas');
    final list = res.data as List<dynamic>;
    return list.map((e) => CaronaModel.fromJson(e as Map<String, dynamic>)).toList();
    }

  Future<CaronaModel> criar({
    required String origem,
    required String destino,
    required DateTime dataHora,
    required int vagas,
    double? valor,
    required String telefone,
    String? observacao,
  }) async {
    final data = <String, dynamic>{
      'origem': origem,
      'destino': destino,
      'dataHora': dataHora.toIso8601String(),
      'vagas': vagas,
      'telefone': telefone,
    };
    if (valor != null) data['valor'] = valor;
    if (observacao != null && observacao.trim().isNotEmpty) {
      data['observacao'] = observacao.trim();
    }
    final res = await _client.dio.post('/api/caronas', data: data);
    return CaronaModel.fromJson(res.data as Map<String, dynamic>);
  }
}
