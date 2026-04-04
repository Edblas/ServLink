import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../providers/auth_providers.dart';
import '../../providers/carona_providers.dart';
import 'criar_carona_page.dart';

class CaronasPage extends ConsumerWidget {
  const CaronasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caronasAsync = ref.watch(caronasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caronas'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CriarCaronaPage()),
          );
          ref.invalidate(caronasProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: caronasAsync.when(
        data: (caronas) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: caronas.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhuma carona disponível',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(caronasProvider);
                        await ref.read(caronasProvider.future);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: caronas.length,
                        itemBuilder: (context, index) {
                          final c = caronas[index];
                          final sessionUserId =
                              ref.read(authControllerProvider).session?.userId;
                          final canDelete =
                              sessionUserId != null && sessionUserId == c.usuarioId;
                          final date = '${c.dataHora.day.toString().padLeft(2, '0')}/'
                              '${c.dataHora.month.toString().padLeft(2, '0')}/'
                              '${c.dataHora.year} ${c.dataHora.hour.toString().padLeft(2, '0')}:'
                              '${c.dataHora.minute.toString().padLeft(2, '0')}';
                          final price = c.valor != null
                              ? ' • R\$ ${c.valor!.toStringAsFixed(2)}'
                              : '';

                          return Card(
                            child: ListTile(
                              title: Text('${c.origem} → ${c.destino}'),
                              subtitle: Text(
                                '$date • ${c.vagas} vagas$price • ${c.usuarioNome}',
                              ),
                              trailing: !canDelete
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Apagar carona'),
                                              content: const Text(
                                                'Deseja apagar esta carona?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(true),
                                                  child: const Text('Apagar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (confirm != true) return;
                                        try {
                                          await ref
                                              .read(caronaActionControllerProvider.notifier)
                                              .apagar(c.id);
                                          ref.invalidate(caronasProvider);
                                        } catch (_) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Falha ao apagar carona'),
                                            ),
                                          );
                                        }
                                      },
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
        error: (error, stack) {
          var message = 'Erro ao carregar caronas';
          if (error is DioException) {
            final status = error.response?.statusCode;
            if (status != null) {
              message = 'Erro ao carregar caronas (HTTP $status)';
              final data = error.response?.data;
              if (data is Map<String, dynamic>) {
                final text = data['message'];
                if (text is String && text.trim().isNotEmpty) {
                  message = text.trim();
                }
              }
            }
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(caronasProvider);
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
