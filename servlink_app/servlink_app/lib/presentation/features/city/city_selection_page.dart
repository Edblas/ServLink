import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog_providers.dart';
import '../home/home_page.dart';

class CitySelectionPage extends ConsumerStatefulWidget {
  const CitySelectionPage({super.key});

  @override
  ConsumerState<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends ConsumerState<CitySelectionPage> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final cidadesAsync = ref.watch(cidadesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione sua cidade'),
      ),
      body: cidadesAsync.when(
        data: (cidades) {
          if (cidades.isEmpty) {
            return const Center(child: Text('Nenhuma cidade cadastrada'));
          }
          if (!_navigated && cidades.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _navigated) return;
              _navigated = true;
              ref.read(cidadeSelecionadaProvider.notifier).state = cidades.first;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            });
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: cidades.length,
            itemBuilder: (context, index) {
              final cidade = cidades[index];
              return ListTile(
                title: Text('${cidade.nome} - ${cidade.estado}'),
                onTap: () {
                  ref.read(cidadeSelecionadaProvider.notifier).state = cidade;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Erro ao carregar cidades')),
      ),
    );
  }
}
