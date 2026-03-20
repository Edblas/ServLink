import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return DioClient(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.read(dioClientProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepositoryImpl(AuthRemoteDataSource(client), storage);
});

class AuthState {
  AuthState({
    this.session,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthSession? session;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthSession? session,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(AuthState());

  final AuthRepository _repository;

  Future<void> login(String email, String senha) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final session = await _repository.login(email: email, senha: senha);
      state = state.copyWith(session: session, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao autenticar',
      );
    }
  }

  Future<void> register({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final session = await _repository.register(
        nome: nome,
        email: email,
        telefone: telefone,
        senha: senha,
        role: role,
      );
      state = state.copyWith(session: session, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao registrar',
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthController(repository);
});

