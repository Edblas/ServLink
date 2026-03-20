import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/vaga_providers.dart';
import 'criar_vaga_page.dart';
import 'vaga_detail_page.dart';

class VagasPage extends ConsumerWidget {
  const VagasPage({super.key});

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vagasAsync = ref.watch(vagasProvider);
    final authState = ref.watch(authControllerProvider);
    final role = authState.session?.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vagas'),
      ),
      floatingActionButton: role == 'CLIENTE'
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
      body: vagasAsync.when(
        data: (vagas) {
          if (vagas.isEmpty) {
            return const Center(child: Text('Nenhuma vaga disponível'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(vagasProvider);
              await ref.read(vagasProvider.future);
            },
            child: ListView.separated(
              itemCount: vagas.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final vaga = vagas[index];
                return ListTile(
                  title: Text(vaga.titulo),
                  subtitle: Text(
                    '${vaga.empresaNome} • ${vaga.cidadeNome} • ${_formatDate(vaga.dataTrabalho)}',
                  ),
                  trailing: Text('R\$ ${vaga.valor.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VagaDetailPage(vagaId: vaga.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Erro ao carregar vagas')),
      ),
    );
  }
}

