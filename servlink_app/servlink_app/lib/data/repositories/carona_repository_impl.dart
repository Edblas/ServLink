import '../../domain/entities/carona_entity.dart';
import '../../domain/repositories/carona_repository.dart';
import '../datasources/carona_remote_data_source.dart';

class CaronaRepositoryImpl implements CaronaRepository {
  CaronaRepositoryImpl(this._remote);

  final CaronaRemoteDataSource _remote;

  @override
  Future<List<CaronaEntity>> listar() async {
    final models = await _remote.listar();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<CaronaEntity> criar({
    required String origem,
    required String destino,
    required DateTime dataHora,
    required int vagas,
    double? valor,
    required String telefone,
    String? observacao,
  }) async {
    final model = await _remote.criar(
      origem: origem,
      destino: destino,
      dataHora: dataHora,
      vagas: vagas,
      valor: valor,
      telefone: telefone,
      observacao: observacao,
    );
    return model.toEntity();
  }
}
