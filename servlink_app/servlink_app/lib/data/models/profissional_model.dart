import '../../domain/entities/profissional_entity.dart';

class ProfissionalModel {
  ProfissionalModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.descricao,
    required this.fotoUrl,
    required this.plano,
    required this.cidadeNome,
    required this.categoriaNome,
    required this.mediaAvaliacoes,
  });

  final int id;
  final String nome;
  final String email;
  final String telefone;
  final String descricao;
  final String? fotoUrl;
  final String plano;
  final String cidadeNome;
  final String categoriaNome;
  final double mediaAvaliacoes;

  factory ProfissionalModel.fromJson(Map<String, dynamic> json) {
    return ProfissionalModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String,
      descricao: json['descricao'] as String,
      fotoUrl: json['fotoUrl'] as String?,
      plano: json['plano'] as String,
      cidadeNome: json['cidadeNome'] as String,
      categoriaNome: json['categoriaNome'] as String,
      mediaAvaliacoes: (json['mediaAvaliacoes'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ProfissionalEntity toEntity() {
    return ProfissionalEntity(
      id: id,
      nome: nome,
      email: email,
      telefone: telefone,
      descricao: descricao,
      fotoUrl: fotoUrl,
      plano: plano,
      cidade: cidadeNome,
      categoria: categoriaNome,
      mediaAvaliacoes: mediaAvaliacoes,
    );
  }
}
