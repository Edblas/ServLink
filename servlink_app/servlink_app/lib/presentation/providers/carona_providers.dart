import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/carona_remote_data_source.dart';
import '../../data/repositories/carona_repository_impl.dart';
import '../../domain/entities/carona_entity.dart';
import '../../domain/repositories/carona_repository.dart';
import 'auth_providers.dart';

final caronaRepositoryProvider = Provider<CaronaRepository>((ref) {
  final client = ref.read(dioClientProvider);
  return CaronaRepositoryImpl(CaronaRemoteDataSource(client));
});

final caronasProvider = FutureProvider.autoDispose<List<CaronaEntity>>((ref) async {
  final repository = ref.read(caronaRepositoryProvider);
  return repository.listar();
});

class CaronaActionState {
  CaronaActionState({required this.isLoading});
  final bool isLoading;
}

class CaronaActionController extends StateNotifier<CaronaActionState> {
  CaronaActionController(this._repository) : super(CaronaActionState(isLoading: false));

  final CaronaRepository _repository;

  Future<void> criar({
    required String origem,
    required String destino,
    required DateTime dataHora,
    required int vagas,
    double? valor,
    required String telefone,
    String? observacao,
  }) async {
    state = CaronaActionState(isLoading: true);
    try {
      await _repository.criar(
        origem: origem,
        destino: destino,
        dataHora: dataHora,
        vagas: vagas,
        valor: valor,
        telefone: telefone,
        observacao: observacao,
      );
    } finally {
      state = CaronaActionState(isLoading: false);
    }
  }
}

final caronaActionControllerProvider =
    StateNotifierProvider<CaronaActionController, CaronaActionState>((ref) {
  final repository = ref.read(caronaRepositoryProvider);
  return CaronaActionController(repository);
});
