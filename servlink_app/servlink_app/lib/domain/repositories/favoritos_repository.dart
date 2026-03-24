import '../entities/profissional_entity.dart';

abstract class FavoritosRepository {
  Future<List<ProfissionalEntity>> listar();

  Future<void> salvar(List<ProfissionalEntity> profissionais);
}

