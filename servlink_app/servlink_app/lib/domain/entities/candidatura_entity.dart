class CandidaturaEntity {
  CandidaturaEntity({
    required this.id,
    required this.vagaId,
    required this.vagaTitulo,
    required this.profissionalId,
    required this.profissionalNome,
    required this.profissionalMediaAvaliacoes,
    required this.profissionalDescricao,
    required this.profissionalCategoria,
    required this.status,
    required this.dataCandidatura,
  });

  final int id;
  final int vagaId;
  final String vagaTitulo;
  final int profissionalId;
  final String profissionalNome;
  final double? profissionalMediaAvaliacoes;
  final String? profissionalDescricao;
  final String? profissionalCategoria;
  final String status;
  final DateTime dataCandidatura;
}
