import '../../domain/entities/categoria_entity.dart';
import '../../domain/entities/profissional_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Future<List<CategoriaEntity>> listarCategorias() async {
    final result = await _remote.listarCategorias();
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<ProfissionalEntity>> listarProfissionais({
    required int page,
    required int size,
    int? cidadeId,
    int? categoriaId,
  }) async {
    final result = await _remote.listarProfissionais(
      page: page,
      size: size,
      cidadeId: cidadeId,
      categoriaId: categoriaId,
    );
    return result.map((e) => e.toEntity()).toList();
  }
}

