import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/profissional_entity.dart';
import '../../providers/avaliacao_providers.dart';
import '../../providers/favoritos_providers.dart';
import '../../providers/whatsapp_providers.dart';
import 'professional_evaluations_page.dart';

class ProfessionalDetailPage extends ConsumerWidget {
  const ProfessionalDetailPage({super.key, required this.profissional});

  final ProfissionalEntity profissional;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avaliacaoState = ref.watch(avaliacaoFormControllerProvider);
    final avaliacoesAsync =
        ref.watch(avaliacoesPorProfissionalProvider(profissional.id));
    final whatsAppService = ref.watch(whatsAppServiceProvider);
    final favoritosAsync = ref.watch(favoritosControllerProvider);
    final hasTelefone =
        profissional.telefone.trim().replaceAll(RegExp(r'[^0-9]'), '').isNotEmpty;
    final isFavorito = favoritosAsync.value?.any((p) => p.id == profissional.id) ?? false;
    final instagramLink = _normalizeInstagram(profissional.instagramUrl);
    final tiktokLink = _normalizeTikTok(profissional.tiktokUrl);
    final siteLink = _normalizeSite(profissional.siteUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(profissional.nome),
        actions: [
          IconButton(
            onPressed: () async {
              await ref
                  .read(favoritosControllerProvider.notifier)
                  .toggle(profissional);
            },
            icon: Icon(
              isFavorito ? Icons.favorite : Icons.favorite_border,
              color: isFavorito ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                        if (profissional.anosExperiencia != null) ...[
                          const SizedBox(height: 4),
                          Text('${profissional.anosExperiencia} anos de experiência'),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(profissional.mediaAvaliacoes.toStringAsFixed(1)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.badge,
                              size: 18,
                              color: profissional.carteiraMotorista ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(profissional.carteiraMotorista
                                ? 'Carteira de motorista'
                                : 'Sem carteira de motorista'),
                          ],
                        ),
                        if (instagramLink != null ||
                            tiktokLink != null ||
                            siteLink != null) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            children: [
                              if (instagramLink != null)
                                IconButton(
                                  onPressed: () => _openExternalUrl(context, instagramLink),
                                  icon: const FaIcon(FontAwesomeIcons.instagram),
                                  color: Theme.of(context).colorScheme.primary,
                                  tooltip: 'Instagram',
                                ),
                              if (tiktokLink != null)
                                IconButton(
                                  onPressed: () => _openExternalUrl(context, tiktokLink),
                                  icon: const FaIcon(FontAwesomeIcons.tiktok),
                                  color: Theme.of(context).colorScheme.primary,
                                  tooltip: 'TikTok',
                                ),
                              if (siteLink != null)
                                IconButton(
                                  onPressed: () => _openExternalUrl(context, siteLink),
                                  icon: const Icon(Icons.public),
                                  color: Theme.of(context).colorScheme.primary,
                                  tooltip: 'Site',
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                profissional.descricao,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Avaliações',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  avaliacoesAsync.when(
                    data: (avaliacoes) {
                      if (avaliacoes.isEmpty) {
                        return const Text('Ainda não há avaliações');
                      }
                      final limit = avaliacoes.length > 3 ? 3 : avaliacoes.length;
                      return Column(
                        children: [
                          for (var i = 0; i < limit; i++)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                child: Text(avaliacoes[i].nota.toString()),
                              ),
                              title: Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(avaliacoes[i].nota.toString()),
                                ],
                              ),
                              subtitle: (avaliacoes[i].comentario.trim().isEmpty)
                                  ? null
                                  : Text(avaliacoes[i].comentario),
                            ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stackTrace) =>
                        const Text('Erro ao carregar avaliações'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color:
                    profissional.plano == 'DESTAQUE' ? Colors.orange : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                profissional.plano == 'DESTAQUE' ? 'Plano Destaque' : 'Plano Básico',
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 72),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: (!hasTelefone)
                ? null
                : () async {
                    final link = whatsAppService.buildProfessionalLink(
                      telefone: profissional.telefone,
                      categoria: profissional.categoria,
                    );
                    final ok = await whatsAppService.open(link);
                    if (!context.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
                      );
                    }
                  },
            icon: const Icon(Icons.chat),
            label: const Text('Chamar no WhatsApp'),
          ),
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
                  comentario: comentarioController.text.trim().isEmpty
                      ? null
                      : comentarioController.text.trim(),
                );
                if (context.mounted) {
                  ref.invalidate(
                    avaliacoesPorProfissionalProvider(profissional.id),
                  );
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

  static String? _normalizeInstagram(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final handle = raw.replaceAll('@', '').trim();
    if (handle.isEmpty) return null;
    return 'https://instagram.com/$handle';
  }

  static String? _normalizeTikTok(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final handle = raw.replaceAll('@', '').trim();
    if (handle.isEmpty) return null;
    return 'https://www.tiktok.com/@$handle';
  }

  static String? _normalizeSite(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return 'https://$raw';
  }

  static Future<void> _openExternalUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link inválido')),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link')),
      );
    }
  }
}
