import '../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  @override
  Future<AuthSession> login({
    required String email,
    required String senha,
  }) async {
    final response = await _remote.login(
      LoginRequestModel(email: email, senha: senha),
    );
    await _storage.saveAccessToken(response.accessToken);
    return AuthSession(
      accessToken: response.accessToken,
      nome: response.nome,
      email: response.email,
      role: response.role,
    );
  }

  @override
  Future<AuthSession> register({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String role,
  }) async {
    final response = await _remote.register(
      RegisterRequestModel(
        nome: nome,
        email: email,
        telefone: telefone,
        senha: senha,
        role: role,
      ),
    );
    await _storage.saveAccessToken(response.accessToken);
    return AuthSession(
      accessToken: response.accessToken,
      nome: response.nome,
      email: response.email,
      role: response.role,
    );
  }

  @override
  Future<void> logout() {
    return _storage.clearAccessToken();
  }
}

