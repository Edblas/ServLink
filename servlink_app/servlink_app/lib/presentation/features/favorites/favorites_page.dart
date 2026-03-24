import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/favoritos_providers.dart';
import '../../providers/whatsapp_providers.dart';
import '../../widgets/professional_card.dart';
import '../professional/professional_detail_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritosAsync = ref.watch(favoritosControllerProvider);
    final whatsAppService = ref.watch(whatsAppServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus favoritos'),
      ),
      body: favoritosAsync.when(
        data: (favoritos) {
          if (favoritos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Você ainda não favoritou nenhum profissional'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Encontrar profissionais'),
                    ),
                  ],
                ),
              ),
            );
          }

          final favoritosSet = favoritos.map((p) => p.id).toSet();

          return ListView.builder(
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              final profissional = favoritos[index];
              return ProfessionalCard(
                profissional: profissional,
                isFavorite: favoritosSet.contains(profissional.id),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfessionalDetailPage(profissional: profissional),
                    ),
                  );
                },
                onToggleFavorite: () async {
                  await ref
                      .read(favoritosControllerProvider.notifier)
                      .toggle(profissional);
                },
                onWhatsApp: profissional.telefone
                        .trim()
                        .replaceAll(RegExp(r'[^0-9]'), '')
                        .isEmpty
                    ? null
                    : () async {
                        final link = whatsAppService.buildProfessionalLink(
                          telefone: profissional.telefone,
                          categoria: profissional.categoria,
                        );
                        await whatsAppService.open(link);
                      },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Erro ao carregar favoritos')),
      ),
    );
  }
}
