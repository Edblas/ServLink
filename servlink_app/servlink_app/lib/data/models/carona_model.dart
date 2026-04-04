import '../../domain/entities/carona_entity.dart';

class CaronaModel {
  CaronaModel({
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

  factory CaronaModel.fromJson(Map<String, dynamic> json) {
    return CaronaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      usuarioId: (json['usuarioId'] as num?)?.toInt() ?? 0,
      usuarioNome: (json['usuarioNome'] as String?) ?? '',
      origem: (json['origem'] as String?) ?? '',
      destino: (json['destino'] as String?) ?? '',
      dataHora: DateTime.parse((json['dataHora'] as String?) ?? DateTime.now().toIso8601String()),
      vagas: (json['vagas'] as num?)?.toInt() ?? 0,
      valor: (json['valor'] as num?)?.toDouble(),
      telefone: (json['telefone'] as String?) ?? '',
      observacao: json['observacao'] as String?,
    );
  }

  CaronaEntity toEntity() {
    return CaronaEntity(
      id: id,
      usuarioId: usuarioId,
      usuarioNome: usuarioNome,
      origem: origem,
      destino: destino,
      dataHora: dataHora,
      vagas: vagas,
      valor: valor,
      telefone: telefone,
      observacao: observacao,
    );
  }
}
