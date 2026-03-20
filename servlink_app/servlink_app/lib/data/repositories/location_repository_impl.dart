import '../../domain/entities/cidade_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl(this._remote);

  final LocationRemoteDataSource _remote;

  @override
  Future<List<CidadeEntity>> listarCidades() async {
    final result = await _remote.listarCidades();
    return result.map((e) => e.toEntity()).toList();
  }
}

