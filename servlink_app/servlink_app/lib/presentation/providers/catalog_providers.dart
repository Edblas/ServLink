import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/catalog_remote_data_source.dart';
import '../../data/datasources/location_remote_data_source.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/categoria_entity.dart';
import '../../domain/entities/cidade_entity.dart';
import '../../domain/entities/profissional_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/location_repository.dart';
import 'auth_providers.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final client = ref.read(dioClientProvider);
  return LocationRepositoryImpl(LocationRemoteDataSource(client));
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final client = ref.read(dioClientProvider);
  return CatalogRepositoryImpl(CatalogRemoteDataSource(client));
});

final cidadesProvider = FutureProvider<List<CidadeEntity>>((ref) async {
  final repository = ref.read(locationRepositoryProvider);
  return repository.listarCidades();
});

final categoriasProvider = FutureProvider<List<CategoriaEntity>>((ref) async {
  final repository = ref.read(catalogRepositoryProvider);
  return repository.listarCategorias();
});

final cidadeSelecionadaProvider = StateProvider<CidadeEntity?>((ref) {
  return null;
});

final categoriaSelecionadaProvider = StateProvider<CategoriaEntity?>((ref) {
  return null;
});

final profissionaisQueryProvider = StateProvider<String>((ref) {
  return '';
});

final profissionaisBairroProvider = StateProvider<String>((ref) {
  return '';
});

final profissionaisProvider = FutureProvider.autoDispose
    .family<List<ProfissionalEntity>, int>((ref, page) async {
  final cidade = ref.watch(cidadeSelecionadaProvider);
  final categoria = ref.watch(categoriaSelecionadaProvider);
  final query = ref.watch(profissionaisQueryProvider);
  final bairro = ref.watch(profissionaisBairroProvider);
  final repository = ref.read(catalogRepositoryProvider);
  return repository.listarProfissionais(
    page: page,
    size: 20,
    cidadeId: cidade?.id,
    categoriaId: categoria?.id,
    q: query,
    bairro: bairro,
  );
});

final categoriaCountsProvider = FutureProvider.autoDispose<Map<int, int>>((ref) async {
  final cidade = ref.watch(cidadeSelecionadaProvider);
  final repository = ref.read(catalogRepositoryProvider);
  return repository.contarProfissionaisPorCategoria(cidadeId: cidade?.id);
});
