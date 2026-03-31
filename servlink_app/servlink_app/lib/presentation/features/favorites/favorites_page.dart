import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/favoritos_providers.dart';
import '../../providers/vaga_providers.dart';
import '../../providers/whatsapp_providers.dart';
import '../../widgets/professional_card.dart';
import '../professional/professional_detail_page.dart';
import '../vagas/vaga_detail_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
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
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritosAsync = ref.watch(favoritosControllerProvider);
    final whatsAppService = ref.watch(whatsAppServiceProvider);
    final vagasFavoritasAsync = ref.watch(vagasFavoritasControllerProvider);
    final vagasAsync = ref.watch(vagasProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus favoritos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Profissionais'),
              Tab(text: 'Vagas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            favoritosAsync.when(
              data: (favoritos) {
                if (favoritos.isEmpty) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Você ainda não favoritou nenhum profissional',
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Encontrar profissionais'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final favoritosSet = favoritos.map((p) => p.id).toSet();

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: favoritos.length,
                      itemBuilder: (context, index) {
                        final profissional = favoritos[index];
                        return ProfessionalCard(
                          profissional: profissional,
                          isFavorite: favoritosSet.contains(profissional.id),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProfessionalDetailPage(
                                  profissional: profissional,
                                ),
                              ),
                            );
                          },
                          onToggleFavorite: () async {
                            await ref
                                .read(favoritosControllerProvider.notifier)
                                .toggle(profissional);
                          },
                          onWhatsApp: profissional.telefone
                                  .trim()
                                  .replaceAll(RegExp(r'[^0-9]'), '')
                                  .isEmpty
                              ? null
                              : () async {
                                  final link =
                                      whatsAppService.buildProfessionalLink(
                                    telefone: profissional.telefone,
                                    categoria: profissional.categoria,
                                  );
                                  await whatsAppService.open(link);
                                },
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('Erro ao carregar favoritos')),
            ),
            vagasFavoritasAsync.when(
              data: (ids) {
                if (ids.isEmpty) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Você ainda não salvou nenhuma vaga'),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ver vagas'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return vagasAsync.when(
                  data: (vagas) {
                    final salvas = vagas
                        .where((v) => ids.contains(v.id))
                        .toList(growable: false);
                    salvas.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    if (salvas.isEmpty) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Você ainda não salvou nenhuma vaga'),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () =>
                                        ref.invalidate(vagasProvider),
                                    child: const Text('Recarregar'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: salvas.length,
                          itemBuilder: (context, index) {
                            final vaga = salvas[index];
                            final hasTelefone = vaga.empresaTelefone
                                .trim()
                                .replaceAll(RegExp(r'[^0-9]'), '')
                                .isNotEmpty;

                            return Card(
                              child: ListTile(
                                title: Text(vaga.titulo),
                                subtitle: Text(
                                  '${vaga.empresaNome} • ${vaga.cidadeNome} • ${_formatUrgencia(vaga.urgencia)} • ${_formatDate(vaga.dataTrabalho)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        await ref
                                            .read(
                                              vagasFavoritasControllerProvider
                                                  .notifier,
                                            )
                                            .toggle(vaga.id);
                                      },
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                    ),
                                    if (hasTelefone)
                                      IconButton(
                                        onPressed: () async {
                                          final link =
                                              whatsAppService.buildClienteLink(
                                            telefone: vaga.empresaTelefone,
                                            mensagem:
                                                'Olá, vi sua vaga no ServLink: ${vaga.titulo}',
                                          );
                                          await whatsAppService.open(link);
                                        },
                                        icon: Icon(
                                          Icons.chat,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VagaDetailPage(vagaId: vaga.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      const Center(child: Text('Erro ao carregar vagas')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('Erro ao carregar vagas salvas')),
            ),
          ],
        ),
      ),
    );
  }
}
