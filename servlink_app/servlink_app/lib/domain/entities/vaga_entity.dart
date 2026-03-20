class VagaEntity {
  VagaEntity({
    required this.id,
    required this.empresaId,
    required this.empresaNome,
    required this.titulo,
    required this.descricao,
    required this.valor,
    required this.cidadeId,
    required this.cidadeNome,
    required this.dataTrabalho,
    required this.status,
    required this.categoriaId,
    required this.categoriaNome,
    required this.createdAt,
  });

  final int id;
  final int empresaId;
  final String empresaNome;
  final String titulo;
  final String descricao;
  final double valor;
  final int cidadeId;
  final String cidadeNome;
  final DateTime dataTrabalho;
  final String status;
  final int categoriaId;
  final String categoriaNome;
  final DateTime createdAt;
}

