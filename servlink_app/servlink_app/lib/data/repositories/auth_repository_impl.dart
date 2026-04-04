import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage, this._client);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;
  final DioClient _client;

  @override
  Future<AuthSession> login({
    required String email,
    required String senha,
  }) async {
    final response = await _remote.login(
      LoginRequestModel(email: email, senha: senha),
    );
    await _storage.saveAccessToken(response.accessToken);
    await _storage.saveSession(
      nome: response.nome,
      email: response.email,
      role: response.role,
    );
    _client.setAccessToken(response.accessToken);
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
    String? cnpj,
    String? endereco,
    String? cep,
    String? numero,
    String? complemento,
  }) async {
    final response = await _remote.register(
      RegisterRequestModel(
        nome: nome,
        email: email,
        telefone: telefone,
        senha: senha,
        role: role,
        cnpj: cnpj,
        endereco: endereco,
        cep: cep,
        numero: numero,
        complemento: complemento,
      ),
    );
    await _storage.saveAccessToken(response.accessToken);
    await _storage.saveSession(
      nome: response.nome,
      email: response.email,
      role: response.role,
    );
    _client.setAccessToken(response.accessToken);
    return AuthSession(
      accessToken: response.accessToken,
      nome: response.nome,
      email: response.email,
      role: response.role,
    );
  }

  @override
  Future<void> forgotPassword({required String email}) {
    return _remote.forgotPassword(
      ForgotPasswordRequestModel(email: email),
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String novaSenha,
  }) {
    return _remote.resetPassword(
      ResetPasswordRequestModel(
        token: token,
        novaSenha: novaSenha,
      ),
    );
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      _client.setAccessToken(null);
      return null;
    }
    try {
      _client.setAccessToken(token);
      final cached = await _storage.getSession();
      if (cached != null) {
        return AuthSession(
          accessToken: token,
          nome: cached['nome'] ?? '',
          email: cached['email'] ?? '',
          role: cached['role'] ?? '',
        );
      }
      final me = await _remote.me();
      await _storage.saveSession(nome: me.nome, email: me.email, role: me.role);
      return AuthSession(
        accessToken: token,
        nome: me.nome,
        email: me.email,
        role: me.role,
      );
    } catch (e) {
      if (e is DioException) {
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          await _storage.clearAccessToken();
          await _storage.clearSession();
          _client.setAccessToken(null);
        }
      }
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _storage.clearAccessToken();
    await _storage.clearSession();
    _client.setAccessToken(null);
  }
}
