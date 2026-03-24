class CaronaEntity {
  CaronaEntity({
    required this.id,
    required this.usuarioId,
    required this.usuarioNome,
    required this.origem,
    required this.destino,
    required this.dataHora,
    required this.vagas,
    this.valor,
    required this.telefone,
    this.observacao,
  });

  final int id;
  final int usuarioId;
  final String usuarioNome;
  final String origem;
  final String destino;
  final DateTime dataHora;
  final int vagas;
  final double? valor;
  final String telefone;
  final String? observacao;
}
