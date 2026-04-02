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
  final _enderecoController = TextEditingController();
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _idadeController = TextEditingController();

  int? _cidadeId;
  int? _categoriaId;
  String _tipoPagamento = 'DIARIA';
  bool _carteiraMotorista = false;
  bool _isEmpresa = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _enderecoController.dispose();
    _cepController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _cnpjController.dispose();
    _descricaoController.dispose();
    _idadeController.dispose();
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
      role: _isEmpresa ? 'CLIENTE' : 'PROFISSIONAL',
      cnpj: _isEmpresa ? _cnpjController.text.trim() : null,
      endereco: _enderecoController.text.trim(),
      cep: _cepController.text.trim(),
      numero: _numeroController.text.trim(),
      complemento: _complementoController.text.trim(),
    );
    final state = ref.read(authControllerProvider);
    if (state.session != null) {
      if (_isEmpresa) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CitySelectionPage()),
          (route) => false,
        );
        return;
      }
      try {
        final remote = ref.read(profissionalProfileRemoteProvider);
        await remote.criarOuObter();
        final model = await remote.atualizar(
          nome: _nomeController.text.trim(),
          telefone: _telefoneController.text.trim(),
          descricao: _descricaoController.text.trim(),
          idade: _parseIntOrNull(_idadeController.text),
          tipoPagamento: _tipoPagamento,
          endereco: _enderecoController.text.trim(),
          cep: _cepController.text.trim(),
          numero: _numeroController.text.trim(),
          complemento: _complementoController.text.trim(),
          carteiraMotorista: _carteiraMotorista,
          cidadeId: _cidadeId,
          categoriaId: _categoriaId,
        );
        final entity = model.toEntity();
        if (!mounted) return;
        if (!entity.isPerfilProfissionalCompleto) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const ProfilePage(isOnboarding: true),
            ),
            (route) => false,
          );
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CitySelectionPage()),
          (route) => false,
        );
      } catch (_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const ProfilePage(isOnboarding: true),
          ),
          (route) => false,
        );
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Criar conta',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEmpresa
                          ? 'Informe os dados da empresa para criar sua conta.'
                          : 'Complete seus dados profissionais para criar sua conta.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                labelText: 'Nome',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o nome';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o email';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _telefoneController,
                              decoration: const InputDecoration(
                                labelText: 'Telefone',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o telefone';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _senhaController,
                              decoration: const InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Senha deve ter ao menos 6 caracteres';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              value: _isEmpresa,
                              onChanged: (value) {
                                setState(() {
                                  _isEmpresa = value;
                                });
                              },
                              title: const Text('Cadastrar como empresa (CNPJ)'),
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 16),
                            if (_isEmpresa) ...[
                              TextFormField(
                                controller: _cnpjController,
                                decoration: const InputDecoration(
                                  labelText: 'CNPJ',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                                  if (digits.isEmpty) return 'Informe o CNPJ';
                                  if (digits.length != 14) return 'CNPJ inválido';
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _enderecoController,
                              decoration: const InputDecoration(
                                labelText: 'Endereço',
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o endereço';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _cepController,
                              decoration: const InputDecoration(
                                labelText: 'CEP',
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final digits =
                                    (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                                if (digits.isEmpty) return 'Informe o CEP';
                                if (digits.length != 8) return 'CEP inválido';
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _numeroController,
                              decoration: const InputDecoration(
                                labelText: 'Número',
                                prefixIcon: Icon(Icons.numbers_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o número';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _complementoController,
                              decoration: const InputDecoration(
                                labelText: 'Complemento (opcional)',
                                prefixIcon: Icon(Icons.home_work_outlined),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            if (_isEmpresa) ...[
                              if (authState.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ] else ...[
                            TextFormField(
                              controller: _descricaoController,
                              decoration: const InputDecoration(
                                labelText: 'Descrição / profissão',
                                prefixIcon: Icon(Icons.work_outline),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe sua profissão';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _idadeController,
                              decoration: const InputDecoration(
                                labelText: 'Idade',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final parsed = _parseIntOrNull(value ?? '');
                                if (parsed == null) return 'Informe sua idade';
                                if (parsed < 14) return 'Informe uma idade válida';
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _tipoPagamento,
                              decoration: const InputDecoration(
                                labelText: 'Pagamento',
                                prefixIcon: Icon(Icons.payments_outlined),
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
                            const SizedBox(height: 16),
                            SwitchListTile(
                              value: _carteiraMotorista,
                              onChanged: (value) {
                                setState(() {
                                  _carteiraMotorista = value;
                                });
                              },
                              title: const Text('Possui carteira de motorista'),
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 16),
                            cidadesAsync.when(
                              data: (cidades) {
                                return DropdownButtonFormField<int>(
                                  value: _cidadeId,
                                  decoration: const InputDecoration(
                                    labelText: 'Cidade',
                                    prefixIcon: Icon(Icons.location_city_outlined),
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
                                    if (value == null) return 'Selecione a cidade';
                                    return null;
                                  },
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (_, __) => const Text('Erro ao carregar cidades'),
                            ),
                            const SizedBox(height: 16),
                            categoriasAsync.when(
                              data: (categorias) {
                                return DropdownButtonFormField<int>(
                                  value: _categoriaId,
                                  decoration: const InputDecoration(
                                    labelText: 'Categoria',
                                    prefixIcon: Icon(Icons.category_outlined),
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
                                    if (value == null) {
                                      return 'Selecione a categoria';
                                    }
                                    return null;
                                  },
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (_, __) => const Text('Erro ao carregar categorias'),
                            ),
                            if (authState.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                authState.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Cadastrar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Já tenho conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
