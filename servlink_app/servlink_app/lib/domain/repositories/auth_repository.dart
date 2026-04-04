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
    String? cnpj,
    String? endereco,
    String? cep,
    String? numero,
    String? complemento,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String novaSenha,
  });

  Future<AuthSession?> restoreSession();

  Future<void> logout();
}
