class VagaEntity {
  VagaEntity({
    required this.id,
    required this.empresaId,
    required this.empresaNome,
    required this.empresaTelefone,
    required this.empresaEmail,
    required this.titulo,
    required this.descricao,
    required this.valor,
    required this.cidadeId,
    required this.cidadeNome,
    required this.dataTrabalho,
    required this.urgencia,
    required this.tipo,
    required this.status,
    required this.categoriaId,
    required this.categoriaNome,
    required this.createdAt,
    required this.expiraEm,
    required this.candidaturasCount,
  });

  final int id;
  final int empresaId;
  final String empresaNome;
  final String empresaTelefone;
  final String empresaEmail;
  final String titulo;
  final String descricao;
  final double valor;
  final int cidadeId;
  final String cidadeNome;
  final DateTime dataTrabalho;
  final String urgencia;
  final String tipo;
  final String status;
  final int categoriaId;
  final String categoriaNome;
  final DateTime createdAt;
  final DateTime? expiraEm;
  final int candidaturasCount;
}
