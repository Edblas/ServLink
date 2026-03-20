import '../../domain/entities/categoria_entity.dart';

class CategoriaModel {
  CategoriaModel({
    required this.id,
    required this.nome,
    required this.descricao,
  });

  final int id;
  final String nome;
  final String descricao;

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: (json['descricao'] ?? '') as String,
    );
  }

  CategoriaEntity toEntity() {
    return CategoriaEntity(
      id: id,
      nome: nome,
      descricao: descricao,
    );
  }
}

