class UserEntity {
  UserEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.role,
  });

  final int id;
  final String nome;
  final String email;
  final String telefone;
  final String role;
}

