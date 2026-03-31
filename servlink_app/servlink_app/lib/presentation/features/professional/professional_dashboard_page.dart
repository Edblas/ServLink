import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';

class ProfessionalDashboardPage extends ConsumerWidget {
  const ProfessionalDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final session = state.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Profissional'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: session == null
                ? const Center(child: Text('Nenhum usuário autenticado'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Bem-vindo, ${session.nome}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Aqui você poderá futuramente acompanhar suas métricas, '
                            'avaliar engajamento e gerenciar seu perfil.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.star),
                          title: Text('Avaliação média'),
                          subtitle: Text('Em breve'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Clientes atendidos'),
                          subtitle: Text('Em breve'),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
