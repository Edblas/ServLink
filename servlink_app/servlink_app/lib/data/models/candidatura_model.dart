import '../../domain/entities/candidatura_entity.dart';

class CandidaturaModel {
  CandidaturaModel({
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

  factory CandidaturaModel.fromJson(Map<String, dynamic> json) {
    return CandidaturaModel(
      id: (json['id'] as num).toInt(),
      vagaId: (json['vagaId'] as num).toInt(),
      vagaTitulo: (json['vagaTitulo'] as String?) ?? '',
      profissionalId: (json['profissionalId'] as num).toInt(),
      profissionalNome: (json['profissionalNome'] as String?) ?? '',
      profissionalMediaAvaliacoes: (json['profissionalMediaAvaliacoes'] as num?)
          ?.toDouble(),
      profissionalDescricao: json['profissionalDescricao'] as String?,
      profissionalCategoria: json['profissionalCategoria'] as String?,
      status: (json['status'] as String?) ?? '',
      dataCandidatura: DateTime.parse(json['dataCandidatura'] as String),
    );
  }

  CandidaturaEntity toEntity() {
    return CandidaturaEntity(
      id: id,
      vagaId: vagaId,
      vagaTitulo: vagaTitulo,
      profissionalId: profissionalId,
      profissionalNome: profissionalNome,
      profissionalMediaAvaliacoes: profissionalMediaAvaliacoes,
      profissionalDescricao: profissionalDescricao,
      profissionalCategoria: profissionalCategoria,
      status: status,
      dataCandidatura: dataCandidatura,
    );
  }
}
