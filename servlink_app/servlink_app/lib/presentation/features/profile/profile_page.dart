import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/profissional_profile_providers.dart';
import '../auth/login_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _fotoUrlController = TextEditingController();
  final _anosExperienciaController = TextEditingController();
  final _bairroController = TextEditingController();

  bool _formInitialized = false;
  bool _saving = false;

  int? _cidadeId;
  int? _categoriaId;

  @override
  void dispose() {
    _descricaoController.dispose();
    _fotoUrlController.dispose();
    _anosExperienciaController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  int? _parseIntOrNull(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final session = state.session;
    final isProfissional = session?.role == 'PROFISSIONAL';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: session == null
          ? const Center(child: Text('Nenhum usuário autenticado'))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          child: Text(session.nome.substring(0, 1)),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.nome,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(session.email),
                            const SizedBox(height: 4),
                            Text('Tipo: ${session.role}'),
                          ],
                        ),
                      ],
                    ),
                    if (isProfissional) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Perfil profissional',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildProfissionalForm(),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfissionalForm() {
    final profissionalAsync = ref.watch(profissionalMeProvider);
    final cidadesAsync = ref.watch(cidadesProvider);
    final categoriasAsync = ref.watch(categoriasProvider);

    return profissionalAsync.when(
      data: (profissional) {
        if (!_formInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _formInitialized) return;
            setState(() {
              _descricaoController.text = profissional.descricao;
              _fotoUrlController.text = profissional.fotoUrl ?? '';
              _anosExperienciaController.text =
                  profissional.anosExperiencia?.toString() ?? '';
              _bairroController.text = profissional.bairro ?? '';
              _cidadeId = profissional.cidadeId;
              _categoriaId = profissional.categoriaId;
              _formInitialized = true;
            });
          });
        }

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição / profissão',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _anosExperienciaController,
                decoration: const InputDecoration(
                  labelText: 'Anos de experiência',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = _parseIntOrNull(value ?? '');
                  if (parsed == null) return null;
                  if (parsed < 0) return 'Informe um valor válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fotoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Foto (URL)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              cidadesAsync.when(
                data: (cidades) {
                  return DropdownButtonFormField<int>(
                    value: _cidadeId,
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      border: OutlineInputBorder(),
                    ),
                    items: cidades
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.nome} - ${c.estado}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _cidadeId = value;
                      });
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Erro ao carregar cidades'),
              ),
              const SizedBox(height: 12),
              categoriasAsync.when(
                data: (categorias) {
                  return DropdownButtonFormField<int>(
                    value: _categoriaId,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: categorias
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaId = value;
                      });
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Erro ao carregar categorias'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _saveProfissional,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Salvar perfil'),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Erro ao carregar perfil profissional'),
    );
  }

  Future<void> _saveProfissional() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      final remote = ref.read(profissionalProfileRemoteProvider);
      await remote.atualizar(
        descricao: _descricaoController.text.trim(),
        fotoUrl: _fotoUrlController.text.trim().isEmpty
            ? ''
            : _fotoUrlController.text.trim(),
        anosExperiencia: _parseIntOrNull(_anosExperienciaController.text),
        bairro:
            _bairroController.text.trim().isEmpty ? '' : _bairroController.text.trim(),
        cidadeId: _cidadeId,
        categoriaId: _categoriaId,
      );
      ref.invalidate(profissionalMeProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao atualizar perfil')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
