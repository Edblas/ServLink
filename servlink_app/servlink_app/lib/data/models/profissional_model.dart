import '../../domain/entities/profissional_entity.dart';

class ProfissionalModel {
  ProfissionalModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.descricao,
    required this.fotoUrl,
    required this.anosExperiencia,
    required this.idade,
    required this.tipoPagamento,
    required this.instagramUrl,
    required this.tiktokUrl,
    required this.siteUrl,
    required this.endereco,
    required this.cep,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.carteiraMotorista,
    required this.plano,
    required this.cidadeId,
    required this.cidadeNome,
    required this.categoriaId,
    required this.categoriaNome,
    required this.mediaAvaliacoes,
  });

  final int id;
  final String nome;
  final String email;
  final String telefone;
  final String descricao;
  final String? fotoUrl;
  final int? anosExperiencia;
  final int? idade;
  final String? tipoPagamento;
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? siteUrl;
  final String? endereco;
  final String? cep;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final bool? carteiraMotorista;
  final String plano;
  final int? cidadeId;
  final String cidadeNome;
  final int? categoriaId;
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
      anosExperiencia: json['anosExperiencia'] as int?,
      idade: json['idade'] as int?,
      tipoPagamento: json['tipoPagamento'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      siteUrl: json['siteUrl'] as String?,
      endereco: json['endereco'] as String?,
      cep: json['cep'] as String?,
      numero: json['numero'] as String?,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String?,
      carteiraMotorista: json['carteiraMotorista'] as bool?,
      plano: json['plano'] as String,
      cidadeId: json['cidadeId'] as int?,
      cidadeNome: json['cidadeNome'] as String,
      categoriaId: json['categoriaId'] as int?,
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
      anosExperiencia: anosExperiencia,
      idade: idade,
      tipoPagamento: tipoPagamento,
      instagramUrl: instagramUrl,
      tiktokUrl: tiktokUrl,
      siteUrl: siteUrl,
      endereco: endereco,
      cep: cep,
      numero: numero,
      complemento: complemento,
      bairro: bairro,
      carteiraMotorista: carteiraMotorista ?? false,
      plano: plano,
      cidadeId: cidadeId,
      cidade: cidadeNome,
      categoriaId: categoriaId,
      categoria: categoriaNome,
      mediaAvaliacoes: mediaAvaliacoes,
    );
  }
}
