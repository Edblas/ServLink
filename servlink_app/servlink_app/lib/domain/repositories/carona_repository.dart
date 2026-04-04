import '../entities/carona_entity.dart';

abstract class CaronaRepository {
  Future<List<CaronaEntity>> listar();
  Future<void> apagar(int id);
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
