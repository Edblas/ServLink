class ProfissionalEntity {
  ProfissionalEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.descricao,
    required this.fotoUrl,
    required this.anosExperiencia,
    required this.bairro,
    required this.plano,
    required this.cidadeId,
    required this.cidade,
    required this.categoriaId,
    required this.categoria,
    required this.mediaAvaliacoes,
  });

  final int id;
  final String nome;
  final String email;
  final String telefone;
  final String descricao;
  final String? fotoUrl;
  final int? anosExperiencia;
  final String? bairro;
  final String plano;
  final int? cidadeId;
  final String cidade;
  final int? categoriaId;
  final String categoria;
  final double mediaAvaliacoes;
}
