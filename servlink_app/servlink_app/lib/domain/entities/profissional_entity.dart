class ProfissionalEntity {
  ProfissionalEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.descricao,
    required this.fotoUrl,
    required this.bairro,
    required this.plano,
    required this.cidade,
    required this.categoria,
    required this.mediaAvaliacoes,
  });

  final int id;
  final String nome;
  final String email;
  final String telefone;
  final String descricao;
  final String? fotoUrl;
  final String? bairro;
  final String plano;
  final String cidade;
  final String categoria;
  final double mediaAvaliacoes;
}
