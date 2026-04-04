class AuthSession {
  AuthSession({
    required this.accessToken,
    required this.userId,
    required this.nome,
    required this.email,
    required this.role,
  });

  final String accessToken;
  final int userId;
  final String nome;
  final String email;
  final String role;
}
