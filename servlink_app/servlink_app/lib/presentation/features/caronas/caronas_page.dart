import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                            ),
                          );
                        },
                      ),
                    ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('Erro ao carregar caronas')),
      ),
    );
  }
}
