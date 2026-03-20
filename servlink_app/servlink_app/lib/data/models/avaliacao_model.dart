import '../../domain/entities/avaliacao_entity.dart';

class AvaliacaoModel {
  AvaliacaoModel({
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

  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) {
    return AvaliacaoModel(
      id: json['id'] as int,
      clienteId: json['clienteId'] as int,
      profissionalId: json['profissionalId'] as int,
      nota: json['nota'] as int,
      comentario: json['comentario'] as String,
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
    );
  }

  AvaliacaoEntity toEntity() {
    return AvaliacaoEntity(
      id: id,
      clienteId: clienteId,
      profissionalId: profissionalId,
      nota: nota,
      comentario: comentario,
      dataCriacao: dataCriacao,
    );
  }
}

