import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/vaga_providers.dart';
import '../../providers/whatsapp_providers.dart';
import 'candidatos_page.dart';

class VagaDetailPage extends ConsumerWidget {
  const VagaDetailPage({super.key, required this.vagaId});

  final int vagaId;

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vagaAsync = ref.watch(vagaDetailProvider(vagaId));
    final authState = ref.watch(authControllerProvider);
    final role = authState.session?.role;
    final actionState = ref.watch(vagaActionControllerProvider);
    final whatsAppService = ref.watch(whatsAppServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da vaga'),
      ),
      body: vagaAsync.when(
        data: (vaga) {
          final canApply =
              role == 'PROFISSIONAL' && vaga.status == 'ABERTA' && !actionState.isLoading;
          final hasTelefone =
              vaga.empresaTelefone.trim().replaceAll(RegExp(r'[^0-9]'), '').isNotEmpty;
          final urgenciaLabel = switch (vaga.urgencia) {
            'HOJE' => 'Hoje',
            'SEMANA' => 'Essa semana',
            _ => 'Flexível',
          };
          final tipoLabel = switch (vaga.tipo) {
            'EMPREGO' => 'Emprego',
            _ => 'Bico (temporário)',
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  vaga.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${vaga.empresaNome} • ${vaga.cidadeNome}'),
                const SizedBox(height: 4),
                Text('Categoria: ${vaga.categoriaNome}'),
                const SizedBox(height: 4),
                Text('Data: ${_formatDate(vaga.dataTrabalho)}'),
                const SizedBox(height: 4),
                Text('Urgência: $urgenciaLabel'),
                const SizedBox(height: 4),
                Text('Tipo: $tipoLabel'),
                const SizedBox(height: 4),
                Text('Valor estimado: R\$ ${vaga.valor.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                Text('Status: ${vaga.status}'),
                const SizedBox(height: 16),
                const Text(
                  'Descrição',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(vaga.descricao),
                const SizedBox(height: 24),
                if (role == 'CLIENTE')
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CandidatosPage(vagaId: vaga.id),
                        ),
                      );
                    },
                    child: const Text('Ver candidatos'),
                  ),
                if (role == 'CLIENTE') const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: hasTelefone
                      ? () async {
                          final link = whatsAppService.buildClienteLink(
                            telefone: vaga.empresaTelefone,
                            mensagem: 'Olá, vi sua vaga no ServLink: ${vaga.titulo}',
                          );
                          final ok = await whatsAppService.open(link);
                          if (!context.mounted) return;
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Não foi possível abrir o WhatsApp'),
                              ),
                            );
                          }
                        }
                      : null,
                  child: const Text('Entrar em contato'),
                ),
                const SizedBox(height: 12),
                if (role == 'PROFISSIONAL')
                  ElevatedButton(
                    onPressed: canApply
                        ? () async {
                            try {
                              await ref
                                  .read(vagaActionControllerProvider.notifier)
                                  .candidatar(vaga.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Candidatura enviada'),
                                ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Falha ao candidatar'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: actionState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Candidatar-se'),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Erro ao carregar vaga')),
      ),
    );
  }
}
