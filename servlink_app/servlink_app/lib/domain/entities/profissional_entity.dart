class ProfissionalEntity {
  ProfissionalEntity({
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
    required this.cidade,
    required this.categoriaId,
    required this.categoria,
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
  final bool carteiraMotorista;
  final String plano;
  final int? cidadeId;
  final String cidade;
  final int? categoriaId;
  final String categoria;
  final double mediaAvaliacoes;

  bool get isPerfilProfissionalCompleto {
    final descricaoOk = descricao.trim().isNotEmpty &&
        descricao.trim().toLowerCase() != 'atualize seu perfil';
    final cidadeOk = cidadeId != null;
    final categoriaOk = categoriaId != null;
    return descricaoOk && cidadeOk && categoriaOk;
  }

  double get percentualPerfilCompleto {
    var total = 0;
    var ok = 0;

    total++;
    if (descricao.trim().isNotEmpty &&
        descricao.trim().toLowerCase() != 'atualize seu perfil') {
      ok++;
    }

    total++;
    if (idade != null && idade! > 0) ok++;

    total++;
    if ((tipoPagamento ?? '').trim().isNotEmpty) ok++;

    total++;
    if ((endereco ?? '').trim().isNotEmpty) ok++;

    total++;
    if ((cep ?? '').trim().isNotEmpty) ok++;

    total++;
    if ((numero ?? '').trim().isNotEmpty) ok++;

    total++;
    if (cidadeId != null) ok++;

    total++;
    if (categoriaId != null) ok++;

    if (total == 0) return 0;
    return ok / total;
  }
}
