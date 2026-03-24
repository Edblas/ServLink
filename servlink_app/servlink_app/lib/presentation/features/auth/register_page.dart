import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/profissional_profile_providers.dart';
import '../city/city_selection_page.dart';
import '../profile/profile_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _anosExperienciaController = TextEditingController();
  final _idadeController = TextEditingController();
  final _bairroController = TextEditingController();
  String _role = 'CLIENTE';
  int? _cidadeId;
  int? _categoriaId;
  String _tipoPagamento = 'DIARIA';

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _descricaoController.dispose();
    _anosExperienciaController.dispose();
    _idadeController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  int? _parseIntOrNull(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final auth = ref.read(authControllerProvider.notifier);
    await auth.register(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      telefone: _telefoneController.text.trim(),
      senha: _senhaController.text,
      role: _role,
    );
    final state = ref.read(authControllerProvider);
    if (state.session != null) {
      if (_role == 'PROFISSIONAL') {
        final remote = ref.read(profissionalProfileRemoteProvider);
        final updated = await remote.atualizar(
          descricao: _descricaoController.text.trim().isEmpty
              ? null
              : _descricaoController.text.trim(),
          anosExperiencia: _parseIntOrNull(_anosExperienciaController.text),
          idade: _parseIntOrNull(_idadeController.text),
          tipoPagamento: _tipoPagamento,
          bairro:
              _bairroController.text.trim().isEmpty ? null : _bairroController.text.trim(),
          cidadeId: _cidadeId,
          categoriaId: _categoriaId,
        );
        final entity = updated.toEntity();
        if (!entity.isPerfilProfissionalCompleto) {
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const ProfilePage(isOnboarding: true),
            ),
            (route) => false,
          );
          return;
        }
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CitySelectionPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final cidadesAsync = ref.watch(cidadesProvider);
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Senha deve ter ao menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Tipo de conta'),
                items: const [
                  DropdownMenuItem(
                    value: 'CLIENTE',
                    child: Text('Cliente'),
                  ),
                  DropdownMenuItem(
                    value: 'PROFISSIONAL',
                    child: Text('Profissional'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _role = value;
                  });
                },
              ),
              if (_role == 'PROFISSIONAL') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Profissão / descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (_role != 'PROFISSIONAL') return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe sua profissão';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _idadeController,
                  decoration: const InputDecoration(
                    labelText: 'Idade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_role != 'PROFISSIONAL') return null;
                    final parsed = _parseIntOrNull(value ?? '');
                    if (parsed == null) return 'Informe sua idade';
                    if (parsed < 0) return 'Informe um valor válido';
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
                    if (_role != 'PROFISSIONAL') return null;
                    final parsed = _parseIntOrNull(value ?? '');
                    if (parsed == null) return null;
                    if (parsed < 0) return 'Informe um valor válido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tipoPagamento,
                  decoration: const InputDecoration(
                    labelText: 'Pagamento',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'DIARIA',
                      child: Text('Diária'),
                    ),
                    DropdownMenuItem(
                      value: 'EMPREITA',
                      child: Text('Empreita'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _tipoPagamento = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro/Região',
                    border: OutlineInputBorder(),
                  ),
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
                      validator: (value) {
                        if (_role != 'PROFISSIONAL') return null;
                        if (value == null) return 'Selecione sua cidade';
                        return null;
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                      validator: (value) {
                        if (_role != 'PROFISSIONAL') return null;
                        if (value == null) return 'Selecione sua categoria';
                        return null;
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Erro ao carregar categorias'),
                ),
              ],
              if (authState.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  authState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: authState.isLoading ? null : _submit,
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
