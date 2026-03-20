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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: session == null
            ? const Center(child: Text('Nenhum usuário autenticado'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo, ${session.nome}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aqui você poderá futuramente acompanhar suas métricas, '
                    'avaliar engajamento e gerenciar seu perfil.',
                  ),
                  const SizedBox(height: 24),
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
    );
  }
}

