import '../entities/categoria_entity.dart';
import '../entities/profissional_entity.dart';

abstract class CatalogRepository {
  Future<List<CategoriaEntity>> listarCategorias();

  Future<List<ProfissionalEntity>> listarProfissionais({
    required int page,
    required int size,
    int? cidadeId,
    int? categoriaId,
    String? q,
    String? bairro,
  });
}
