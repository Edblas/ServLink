import '../../domain/entities/profissional_entity.dart';
import '../../domain/repositories/favoritos_repository.dart';
import '../datasources/favoritos_local_data_source.dart';

class FavoritosRepositoryImpl implements FavoritosRepository {
  FavoritosRepositoryImpl(this._local);

  final FavoritosLocalDataSource _local;

  @override
  Future<List<ProfissionalEntity>> listar() {
    return _local.listar();
  }

  @override
  Future<void> salvar(List<ProfissionalEntity> profissionais) {
    return _local.salvar(profissionais);
  }
}

