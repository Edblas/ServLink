class AvaliacaoEntity {
  AvaliacaoEntity({
    required this.id,
    required this.clienteId,
    required this.profissionalId,
    required this.nota,
    required this.comentario,
    required this.dataCriacao,
  });

  final int id;
  final int clienteId;
  final int profissionalId;
  final int nota;
  final String comentario;
  final DateTime dataCriacao;
}

