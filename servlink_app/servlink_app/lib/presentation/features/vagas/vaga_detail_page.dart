import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/favoritos_providers.dart';
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
    final vagasFavoritasAsync = ref.watch(vagasFavoritasControllerProvider);
    final isFavorita = vagasFavoritasAsync.value?.contains(vagaId) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da vaga'),
        actions: [
          if (role == 'CLIENTE' || role == 'PROFISSIONAL')
            IconButton(
              onPressed: actionState.isLoading
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Apagar vaga'),
                            content: const Text(
                              'Deseja apagar esta vaga? Ela deixará de aparecer para os usuários.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Apagar'),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmed != true) return;
                      try {
                        await ref
                            .read(vagaActionControllerProvider.notifier)
                            .apagarVaga(vagaId);
                        ref.invalidate(vagasProvider);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vaga apagada')),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Falha ao apagar vaga')),
                        );
                      }
                    },
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Apagar vaga',
            ),
          IconButton(
            onPressed: () async {
              await ref
                  .read(vagasFavoritasControllerProvider.notifier)
                  .toggle(vagaId);
            },
            icon: Icon(
              isFavorita ? Icons.favorite : Icons.favorite_border,
              color: isFavorita ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: vagaAsync.when(
        data: (vaga) {
          final sessionEmail = authState.session?.email.trim().toLowerCase();
          final empresaEmail = vaga.empresaEmail.trim().toLowerCase();
          final isOwnVaga = sessionEmail != null && sessionEmail.isNotEmpty && sessionEmail == empresaEmail;
          final canApply = role == 'PROFISSIONAL' &&
              vaga.status == 'ABERTA' &&
              !actionState.isLoading &&
              !isOwnVaga;
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
          final expiraLabel = vaga.expiraEm == null ? null : _formatDate(vaga.expiraEm!);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              Text(
                                'Valor estimado: R\$ ${vaga.valor.toStringAsFixed(2)}',
                              ),
                              if (expiraLabel != null) ...[
                                const SizedBox(height: 4),
                                Text('Expira em: $expiraLabel'),
                              ],
                              const SizedBox(height: 4),
                              Text('Status: ${vaga.status}'),
                              const SizedBox(height: 4),
                              Text('Candidatos: ${vaga.candidaturasCount}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Descrição',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(vaga.descricao),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (role == 'CLIENTE')
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CandidatosPage(vagaId: vaga.id),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Ver candidatos (${vaga.candidaturasCount})',
                                  ),
                                ),
                              if (role == 'CLIENTE') const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: hasTelefone
                                    ? () async {
                                        final link =
                                            whatsAppService.buildClienteLink(
                                          telefone: vaga.empresaTelefone,
                                          mensagem:
                                              'Olá, vi sua vaga no ServLink: ${vaga.titulo}',
                                        );
                                        final ok = await whatsAppService.open(
                                          link,
                                        );
                                        if (!context.mounted) return;
                                        if (!ok) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Não foi possível abrir o WhatsApp',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                child: const Text('Entrar em contato'),
                              ),
                              if (role == 'PROFISSIONAL') ...[
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: canApply
                                      ? () async {
                                          try {
                                            await ref
                                                .read(
                                                  vagaActionControllerProvider
                                                      .notifier,
                                                )
                                                .candidatar(vaga.id);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('Candidatura enviada'),
                                              ),
                                            );
                                          } catch (_) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('Falha ao candidatar'),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
