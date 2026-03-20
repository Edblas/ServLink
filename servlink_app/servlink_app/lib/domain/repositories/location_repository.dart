import '../entities/cidade_entity.dart';

abstract class LocationRepository {
  Future<List<CidadeEntity>> listarCidades();
}

