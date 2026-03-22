import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profissional_profile_remote_data_source.dart';
import '../../domain/entities/profissional_entity.dart';
import 'auth_providers.dart';

final profissionalProfileRemoteProvider =
    Provider<ProfissionalProfileRemoteDataSource>((ref) {
  final client = ref.read(dioClientProvider);
  return ProfissionalProfileRemoteDataSource(client);
});

final profissionalMeProvider = FutureProvider.autoDispose<ProfissionalEntity>(
  (ref) async {
    final remote = ref.read(profissionalProfileRemoteProvider);
    final model = await remote.criarOuObter();
    return model.toEntity();
  },
);

