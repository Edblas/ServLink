import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/vaga_providers.dart';

class CandidatosPage extends ConsumerWidget {
  const CandidatosPage({super.key, required this.vagaId});

  final int vagaId;

  String _formatRating(double? value) {
    if (value == null) return 'Sem avaliações';
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatosAsync = ref.watch(candidatosProvider(vagaId));
    final actionState = ref.watch(vagaActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidatos'),
      ),
      body: candidatosAsync.when(
        data: (candidaturas) {
          if (candidaturas.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhuma candidatura ainda',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(candidatosProvider(vagaId));
              await ref.read(candidatosProvider(vagaId).future);
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: candidaturas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final candidatura = candidaturas[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              candidatura.profissionalNome,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '⭐ ${_formatRating(candidatura.profissionalMediaAvaliacoes)}',
                            ),
                            const SizedBox(height: 4),
                            if (candidatura.profissionalCategoria != null &&
                                candidatura.profissionalCategoria!.isNotEmpty)
                              Text(
                                'Categoria: ${candidatura.profissionalCategoria}',
                              ),
                            if (candidatura.profissionalDescricao != null &&
                                candidatura.profissionalDescricao!
                                    .trim()
                                    .isNotEmpty)
                              Text(
                                'Habilidades: ${candidatura.profissionalDescricao}',
                              ),
                            const SizedBox(height: 6),
                            Text('Status: ${candidatura.status}'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: actionState.isLoading
                                        ? null
                                        : () async {
                                            await ref
                                                .read(
                                                  vagaActionControllerProvider
                                                      .notifier,
                                                )
                                                .atualizarStatusCandidatura(
                                                  candidaturaId: candidatura.id,
                                                  status: 'RECUSADO',
                                                );
                                            ref.invalidate(
                                              candidatosProvider(vagaId),
                                            );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text('Atualizado'),
                                              ),
                                            );
                                          },
                                    child: const Text('RECUSAR'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: actionState.isLoading
                                        ? null
                                        : () async {
                                            await ref
                                                .read(
                                                  vagaActionControllerProvider
                                                      .notifier,
                                                )
                                                .atualizarStatusCandidatura(
                                                  candidaturaId: candidatura.id,
                                                  status: 'ACEITO',
                                                );
                                            ref.invalidate(
                                              candidatosProvider(vagaId),
                                            );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text('Atualizado'),
                                              ),
                                            );
                                          },
                                    child: const Text('ACEITAR'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Erro ao carregar candidatos')),
      ),
    );
  }
}
