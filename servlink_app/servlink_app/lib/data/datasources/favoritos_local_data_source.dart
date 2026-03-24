import 'dart:convert';
import '../../core/storage/secure_storage_service.dart';
import '../../domain/entities/profissional_entity.dart';

class FavoritosLocalDataSource {
  FavoritosLocalDataSource(this._storage);

  final SecureStorageService _storage;

  static const String _key = 'favoritos_profissionais_v1';

  Future<List<ProfissionalEntity>> listar() async {
    final raw = await _storage.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> salvar(List<ProfissionalEntity> profissionais) async {
    final value = jsonEncode(profissionais.map(_toJson).toList(growable: false));
    await _storage.saveString(_key, value);
  }

  Map<String, dynamic> _toJson(ProfissionalEntity p) {
    return {
      'id': p.id,
      'nome': p.nome,
      'email': p.email,
      'telefone': p.telefone,
      'descricao': p.descricao,
      'fotoUrl': p.fotoUrl,
      'anosExperiencia': p.anosExperiencia,
      'idade': p.idade,
      'tipoPagamento': p.tipoPagamento,
      'instagramUrl': p.instagramUrl,
      'tiktokUrl': p.tiktokUrl,
      'siteUrl': p.siteUrl,
      'bairro': p.bairro,
      'plano': p.plano,
      'cidadeId': p.cidadeId,
      'cidade': p.cidade,
      'categoriaId': p.categoriaId,
      'categoria': p.categoria,
      'mediaAvaliacoes': p.mediaAvaliacoes,
    };
  }

  ProfissionalEntity _fromJson(Map<String, dynamic> json) {
    return ProfissionalEntity(
      id: (json['id'] as num).toInt(),
      nome: (json['nome'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      telefone: (json['telefone'] as String?) ?? '',
      descricao: (json['descricao'] as String?) ?? '',
      fotoUrl: json['fotoUrl'] as String?,
      anosExperiencia: (json['anosExperiencia'] as num?)?.toInt(),
      idade: (json['idade'] as num?)?.toInt(),
      tipoPagamento: json['tipoPagamento'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      siteUrl: json['siteUrl'] as String?,
      bairro: json['bairro'] as String?,
      plano: (json['plano'] as String?) ?? 'BASICO',
      cidadeId: (json['cidadeId'] as num?)?.toInt(),
      cidade: (json['cidade'] as String?) ?? '',
      categoriaId: (json['categoriaId'] as num?)?.toInt(),
      categoria: (json['categoria'] as String?) ?? '',
      mediaAvaliacoes: (json['mediaAvaliacoes'] as num?)?.toDouble() ?? 0,
    );
  }
}
