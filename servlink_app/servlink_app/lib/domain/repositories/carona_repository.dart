import '../entities/carona_entity.dart';

abstract class CaronaRepository {
  Future<List<CaronaEntity>> listar();
  Future<CaronaEntity> criar({
    required String origem,
    required String destino,
    required DateTime dataHora,
    required int vagas,
    double? valor,
    required String telefone,
    String? observacao,
  });
}
