import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/avaliacao_providers.dart';

class ProfessionalEvaluationsPage extends ConsumerWidget {
  const ProfessionalEvaluationsPage({super.key, required this.profissionalId});

  final int profissionalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avaliacoesAsync =
        ref.watch(avaliacoesPorProfissionalProvider(profissionalId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliações'),
      ),
      body: avaliacoesAsync.when(
        data: (avaliacoes) {
          if (avaliacoes.isEmpty) {
            return const Center(child: Text('Nenhuma avaliação encontrada'));
          }
          return ListView.separated(
            itemCount: avaliacoes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final avaliacao = avaliacoes[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(avaliacao.nota.toString()),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(avaliacao.nota.toString()),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(avaliacao.comentario),
                    const SizedBox(height: 4),
                    Text(
                      avaliacao.dataCriacao.toLocal().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Erro ao carregar avaliações')),
      ),
    );
  }
}

