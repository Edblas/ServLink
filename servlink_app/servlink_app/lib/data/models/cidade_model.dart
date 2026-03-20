import '../../domain/entities/cidade_entity.dart';

class CidadeModel {
  CidadeModel({
    required this.id,
    required this.nome,
    required this.estado,
  });

  final int id;
  final String nome;
  final String estado;

  factory CidadeModel.fromJson(Map<String, dynamic> json) {
    return CidadeModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      estado: json['estado'] as String,
    );
  }

  CidadeEntity toEntity() {
    return CidadeEntity(
      id: id,
      nome: nome,
      estado: estado,
    );
  }
}

