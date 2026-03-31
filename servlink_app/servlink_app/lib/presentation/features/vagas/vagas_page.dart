import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../domain/entities/vaga_entity.dart';
import '../../providers/auth_providers.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/favoritos_providers.dart';
import '../../providers/vaga_providers.dart';
import '../../providers/whatsapp_providers.dart';
import 'criar_vaga_page.dart';
import 'vaga_detail_page.dart';

class VagasPage extends ConsumerStatefulWidget {
  const VagasPage({super.key});

  @override
  ConsumerState<VagasPage> createState() => _VagasPageState();
}

class _VagasPageState extends ConsumerState<VagasPage> {
  final _queryController = TextEditingController();

  int? _categoriaId;
  String _urgencia = 'TODAS';
  String _ordenacao = 'RECENTE';
  bool _somenteAbertas = true;
  bool _somenteSalvas = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  List<VagaEntity> _applyFilters(
    List<VagaEntity> vagas, {
    required String tipo,
    required int? cidadeId,
    required Set<int> favoritasIds,
  }) {
    final query = _queryController.text.trim().toLowerCase();

    final filtered = vagas.where((v) {
      if (v.tipo != tipo) return false;
      if (cidadeId != null && v.cidadeId != cidadeId) return false;
      if (_somenteAbertas && v.status != 'ABERTA') return false;
      if (_somenteSalvas && !favoritasIds.contains(v.id)) return false;
      if (_categoriaId != null && v.categoriaId != _categoriaId) return false;
      if (_urgencia != 'TODAS' && v.urgencia != _urgencia) return false;

      if (query.isEmpty) return true;
      return v.titulo.toLowerCase().contains(query) ||
          v.descricao.toLowerCase().contains(query) ||
          v.empresaNome.toLowerCase().contains(query);
    }).toList(growable: false);

    filtered.sort((a, b) {
      switch (_ordenacao) {
        case 'VALOR_MAIOR':
          return b.valor.compareTo(a.valor);
        case 'VALOR_MENOR':
          return a.valor.compareTo(b.valor);
        case 'DATA_TRABALHO':
          return a.dataTrabalho.compareTo(b.dataTrabalho);
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  String _formatUrgencia(String value) {
    switch (value) {
      case 'HOJE':
        return 'Hoje';
      case 'SEMANA':
        return 'Essa semana';
      case 'FLEXIVEL':
        return 'Flexível';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vagasAsync = ref.watch(vagasProvider);
    final authState = ref.watch(authControllerProvider);
    final role = authState.session?.role;
    final whatsAppService = ref.watch(whatsAppServiceProvider);
    final cidade = ref.watch(cidadeSelecionadaProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final vagasFavoritasAsync = ref.watch(vagasFavoritasControllerProvider);
    final favoritasIds = vagasFavoritasAsync.value ?? <int>{};

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Empregos e bicos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bicos'),
              Tab(text: 'Empregos'),
            ],
          ),
        ),
        floatingActionButton: role == 'CLIENTE' || role == 'PROFISSIONAL'
            ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CriarVagaPage()),
                  );
                  ref.invalidate(vagasProvider);
                },
                child: const Icon(Icons.add),
              )
            : null,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              cidade == null
                                  ? 'Cidade não selecionada'
                                  : 'Cidade: ${cidade.nome} - ${cidade.estado}',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _queryController,
                              decoration: const InputDecoration(
                                labelText: 'Buscar vaga',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                            categoriasAsync.when(
                              data: (categorias) {
                                return DropdownButtonFormField<int?>(
                                  value: _categoriaId,
                                  decoration: const InputDecoration(
                                    labelText: 'Categoria',
                                    prefixIcon: Icon(Icons.category_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('Todas'),
                                    ),
                                    ...categorias.map(
                                      (c) => DropdownMenuItem<int?>(
                                        value: c.id,
                                        child: Text(c.nome),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _categoriaId = value;
                                    });
                                  },
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error: (_, __) => const Text(
                                'Erro ao carregar categorias',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _urgencia,
                                    decoration: const InputDecoration(
                                      labelText: 'Urgência',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'TODAS',
                                        child: Text('Todas'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'HOJE',
                                        child: Text('Hoje'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'SEMANA',
                                        child: Text('Essa semana'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'FLEXIVEL',
                                        child: Text('Flexível'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _urgencia = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _ordenacao,
                                    decoration: const InputDecoration(
                                      labelText: 'Ordenar',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'RECENTE',
                                        child: Text('Mais recentes'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'DATA_TRABALHO',
                                        child: Text('Data do trabalho'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'VALOR_MAIOR',
                                        child: Text('Maior valor'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'VALOR_MENOR',
                                        child: Text('Menor valor'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _ordenacao = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            CheckboxListTile(
                              value: _somenteAbertas,
                              onChanged: (value) {
                                setState(() {
                                  _somenteAbertas = value ?? true;
                                });
                              },
                              title: const Text('Somente vagas abertas'),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            CheckboxListTile(
                              value: _somenteSalvas,
                              onChanged: (value) {
                                setState(() {
                                  _somenteSalvas = value ?? false;
                                });
                              },
                              title: const Text('Somente vagas salvas'),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: vagasAsync.when(
                      data: (vagas) {
                        final bicos = _applyFilters(
                          vagas,
                          tipo: 'BICO',
                          cidadeId: cidade?.id,
                          favoritasIds: favoritasIds,
                        );
                        final empregos = _applyFilters(
                          vagas,
                          tipo: 'EMPREGO',
                          cidadeId: cidade?.id,
                          favoritasIds: favoritasIds,
                        );

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(vagasProvider);
                            await ref.read(vagasProvider.future);
                          },
                          child: TabBarView(
                            children: [
                              _buildList(
                                vagas: bicos,
                                whatsAppService: whatsAppService,
                                emptyText: 'Nenhum bico encontrado',
                                favoritasIds: favoritasIds,
                              ),
                              _buildList(
                                vagas: empregos,
                                whatsAppService: whatsAppService,
                                emptyText: 'Nenhum emprego encontrado',
                                favoritasIds: favoritasIds,
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Erro ao carregar vagas',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () =>
                                        ref.invalidate(vagasProvider),
                                    child: const Text('Tentar novamente'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList({
    required List<VagaEntity> vagas,
    required WhatsAppService whatsAppService,
    required String emptyText,
    required Set<int> favoritasIds,
  }) {
    if (vagas.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                emptyText,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: vagas.length,
      itemBuilder: (context, index) {
        final vaga = vagas[index];
        final hasTelefone =
            vaga.empresaTelefone.trim().replaceAll(RegExp(r'[^0-9]'), '').isNotEmpty;
        final isFavorita = favoritasIds.contains(vaga.id);

        return Card(
          child: ListTile(
            title: Text(vaga.titulo),
            subtitle: Text(
              '${vaga.empresaNome} • ${vaga.cidadeNome} • ${_formatUrgencia(vaga.urgencia)} • ${_formatDate(vaga.dataTrabalho)}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('R\$ ${vaga.valor.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(vagasFavoritasControllerProvider.notifier)
                            .toggle(vaga.id);
                      },
                      icon: Icon(
                        isFavorita ? Icons.favorite : Icons.favorite_border,
                        color: isFavorita ? Colors.red : null,
                      ),
                    ),
                    if (hasTelefone)
                      IconButton(
                        onPressed: () async {
                          final link = whatsAppService.buildClienteLink(
                            telefone: vaga.empresaTelefone,
                            mensagem: 'Olá, vi sua vaga no ServLink: ${vaga.titulo}',
                          );
                          await whatsAppService.open(link);
                        },
                        icon: Icon(
                          Icons.chat,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VagaDetailPage(vagaId: vaga.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
