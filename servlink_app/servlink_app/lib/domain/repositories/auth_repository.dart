import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String senha,
  });

  Future<AuthSession> register({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String role,
  });

  Future<void> logout();
}

