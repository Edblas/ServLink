import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/catalog_providers.dart';
import '../profile/profile_page.dart';
import '../professional/professional_dashboard_page.dart';
import '../professional/professional_list_page.dart';
import '../vagas/vagas_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final cidade = ref.watch(cidadeSelecionadaProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cidade != null
              ? 'Serviços em ${cidade.nome}'
              : 'Serviços',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.work),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VagasPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          if (authState.session?.role == 'PROFISSIONAL')
            IconButton(
              icon: const Icon(Icons.dashboard),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfessionalDashboardPage(),
                  ),
                );
              },
            ),
        ],
      ),
      body: categoriasAsync.when(
        data: (categorias) {
          if (categorias.isEmpty) {
            return const Center(child: Text('Nenhuma categoria cadastrada'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3 / 2,
            ),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return InkWell(
                onTap: () {
                  ref.read(categoriaSelecionadaProvider.notifier).state =
                      categoria;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfessionalListPage(),
                    ),
                  );
                },
                child: Card(
                  child: Center(
                    child: Text(
                      categoria.nome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Erro ao carregar categorias')),
      ),
    );
  }
}
