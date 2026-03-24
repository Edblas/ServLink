import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../domain/entities/vaga_entity.dart';
import '../../providers/auth_providers.dart';
import '../../providers/vaga_providers.dart';
import '../../providers/whatsapp_providers.dart';
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
    final whatsAppService = ref.watch(whatsAppServiceProvider);

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
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(vagasProvider);
                await ref.read(vagasProvider.future);
              },
              child: TabBarView(
                children: [
                  _buildList(
                    context: context,
                    vagas: vagas.where((v) => v.tipo == 'BICO').toList(),
                    whatsAppService: whatsAppService,
                    emptyText: 'Nenhum bico disponível',
                  ),
                  _buildList(
                    context: context,
                    vagas: vagas.where((v) => v.tipo == 'EMPREGO').toList(),
                    whatsAppService: whatsAppService,
                    emptyText: 'Nenhum emprego disponível',
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              const Center(child: Text('Erro ao carregar vagas')),
        ),
      ),
    );
  }

  Widget _buildList({
    required BuildContext context,
    required List<VagaEntity> vagas,
    required WhatsAppService whatsAppService,
    required String emptyText,
  }) {
    if (vagas.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 32),
          Center(child: Text(emptyText)),
        ],
      );
    }

    return ListView.separated(
      itemCount: vagas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final vaga = vagas[index];
        final hasTelefone =
            vaga.empresaTelefone.trim().replaceAll(RegExp(r'[^0-9]'), '').isNotEmpty;
        final urgenciaLabel = switch (vaga.urgencia) {
          'HOJE' => 'Hoje',
          'SEMANA' => 'Essa semana',
          _ => 'Flexível',
        };
        return ListTile(
          title: Text(vaga.titulo),
          subtitle: Text(
            '${vaga.empresaNome} • ${vaga.cidadeNome} • $urgenciaLabel • ${_formatDate(vaga.dataTrabalho)}',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ ${vaga.valor.toStringAsFixed(2)}'),
              TextButton(
                onPressed: hasTelefone
                    ? () async {
                        final link = whatsAppService.buildClienteLink(
                          telefone: vaga.empresaTelefone,
                          mensagem: 'Olá, vi sua vaga no ServLink: ${vaga.titulo}',
                        );
                        await whatsAppService.open(link);
                      }
                    : null,
                child: const Text('Entrar em contato'),
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
        );
      },
    );
  }
}
