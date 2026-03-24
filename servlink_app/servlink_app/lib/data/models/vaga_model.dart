import '../../domain/entities/vaga_entity.dart';

class VagaModel {
  VagaModel({
    required this.id,
    required this.empresaId,
    required this.empresaNome,
    required this.empresaTelefone,
    required this.titulo,
    required this.descricao,
    required this.valor,
    required this.cidadeId,
    required this.cidadeNome,
    required this.dataTrabalho,
    required this.urgencia,
    required this.tipo,
    required this.status,
    required this.categoriaId,
    required this.categoriaNome,
    required this.createdAt,
  });

  final int id;
  final int empresaId;
  final String empresaNome;
  final String empresaTelefone;
  final String titulo;
  final String descricao;
  final double valor;
  final int cidadeId;
  final String cidadeNome;
  final DateTime dataTrabalho;
  final String urgencia;
  final String tipo;
  final String status;
  final int categoriaId;
  final String categoriaNome;
  final DateTime createdAt;

  factory VagaModel.fromJson(Map<String, dynamic> json) {
    return VagaModel(
      id: (json['id'] as num).toInt(),
      empresaId: (json['empresaId'] as num).toInt(),
      empresaNome: (json['empresaNome'] as String?) ?? '',
      empresaTelefone: (json['empresaTelefone'] as String?) ?? '',
      titulo: (json['titulo'] as String?) ?? '',
      descricao: (json['descricao'] as String?) ?? '',
      valor: ((json['valor_estimado'] ?? json['valor']) as num).toDouble(),
      cidadeId: (json['cidadeId'] as num).toInt(),
      cidadeNome: (json['cidadeNome'] as String?) ?? '',
      dataTrabalho: DateTime.parse(json['dataTrabalho'] as String),
      urgencia: (json['urgencia'] as String?) ?? 'FLEXIVEL',
      tipo: (json['tipo'] as String?) ?? 'BICO',
      status: (json['status'] as String?) ?? '',
      categoriaId: (json['categoriaId'] as num).toInt(),
      categoriaNome: (json['categoriaNome'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  VagaEntity toEntity() {
    return VagaEntity(
      id: id,
      empresaId: empresaId,
      empresaNome: empresaNome,
      empresaTelefone: empresaTelefone,
      titulo: titulo,
      descricao: descricao,
      valor: valor,
      cidadeId: cidadeId,
      cidadeNome: cidadeNome,
      dataTrabalho: dataTrabalho,
      urgencia: urgencia,
      tipo: tipo,
      status: status,
      categoriaId: categoriaId,
      categoriaNome: categoriaNome,
      createdAt: createdAt,
    );
  }
}
