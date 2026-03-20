import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/profissional_entity.dart';
import '../../providers/avaliacao_providers.dart';
import 'professional_evaluations_page.dart';

class ProfessionalDetailPage extends ConsumerWidget {
  const ProfessionalDetailPage({super.key, required this.profissional});

  final ProfissionalEntity profissional;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avaliacaoState = ref.watch(avaliacaoFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(profissional.nome),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(profissional.nome.substring(0, 1)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profissional.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${profissional.categoria} • ${profissional.cidade}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            profissional.mediaAvaliacoes.toStringAsFixed(1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              profissional.descricao,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: profissional.plano == 'DESTAQUE'
                      ? Colors.orange
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  profissional.plano == 'DESTAQUE'
                      ? 'Plano Destaque'
                      : 'Plano Básico',
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfessionalEvaluationsPage(
                            profissionalId: profissional.id,
                          ),
                        ),
                      );
                    },
                    child: const Text('Ver avaliações'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: avaliacaoState.isLoading
                        ? null
                        : () {
                            _showAvaliarDialog(context, ref);
                          },
                    child: avaliacaoState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Avaliar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAvaliarDialog(BuildContext context, WidgetRef ref) {
    final notaNotifier = ValueNotifier<int>(5);
    final comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Avaliar profissional'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: notaNotifier,
                builder: (context, nota, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(
                          index < nota ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          notaNotifier.value = index + 1;
                        },
                      ),
                    ),
                  );
                },
              ),
              TextField(
                controller: comentarioController,
                decoration:
                    const InputDecoration(labelText: 'Comentário (opcional)'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final controller =
                    ref.read(avaliacaoFormControllerProvider.notifier);
                await controller.enviar(
                  profissionalId: profissional.id,
                  nota: notaNotifier.value,
                  comentario: comentarioController.text,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avaliação enviada')),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}

