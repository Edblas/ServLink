import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_config.dart';
import '../../providers/auth_providers.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/profissional_profile_providers.dart';
import '../city/city_selection_page.dart';
import '../auth/login_page.dart';
import '../settings/settings_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.isOnboarding = false});

  final bool isOnboarding;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _fotoUrlController = TextEditingController();
  final _anosExperienciaController = TextEditingController();
  final _idadeController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _siteController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();

  bool _formInitialized = false;
  bool _saving = false;
  bool _uploadingPhoto = false;
  bool _carteiraMotorista = false;

  int? _cidadeId;
  int? _categoriaId;
  String _tipoPagamento = 'DIARIA';

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _descricaoController.dispose();
    _fotoUrlController.dispose();
    _anosExperienciaController.dispose();
    _idadeController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _siteController.dispose();
    _enderecoController.dispose();
    _cepController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
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
    final fotoUrl = isProfissional
        ? ref.watch(profissionalMeProvider).maybeWhen(
              data: (p) =>
                  (p.fotoUrl ?? '').trim().isEmpty ? null : p.fotoUrl!.trim(),
              orElse: () => null,
            )
        : null;
    final avatarUrl = fotoUrl == null
        ? null
        : (fotoUrl.startsWith('http')
            ? fotoUrl
            : '${AppConfig.apiBaseUrl}${fotoUrl.startsWith('/') ? '' : '/'}$fotoUrl');

    final content = Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: session == null
          ? const Center(child: Text('Nenhum usuário autenticado'))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundImage:
                                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                  child: avatarUrl == null
                                      ? Text(session.nome.substring(0, 1))
                                      : null,
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
                                  ],
                                ),
                                const Spacer(),
                                if (isProfissional)
                                  OutlinedButton.icon(
                                    onPressed: _uploadingPhoto ? null : _changePhoto,
                                    icon: _uploadingPhoto
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.photo_camera_outlined),
                                    label: const Text('Alterar foto'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!isProfissional) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Configurações',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const SettingsPage(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.settings),
                                    label: const Text('Abrir configurações'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          const Text(
                            'Perfil profissional',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildProfissionalForm(),
                          const SizedBox(height: 24),
                        ],
                        if (!widget.isOnboarding)
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
              ),
            ),
    );

    if (!widget.isOnboarding) return content;

    return PopScope(
      canPop: false,
      child: content,
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
              _nomeController.text = profissional.nome;
              _telefoneController.text = profissional.telefone;
              _descricaoController.text = profissional.descricao;
              _fotoUrlController.text = profissional.fotoUrl ?? '';
              _anosExperienciaController.text =
                  profissional.anosExperiencia?.toString() ?? '';
              _idadeController.text = profissional.idade?.toString() ?? '';
              _bairroController.text = profissional.bairro ?? '';
              _cidadeId = profissional.cidadeId;
              _categoriaId = profissional.categoriaId;
              _tipoPagamento = profissional.tipoPagamento ?? 'DIARIA';
              _instagramController.text = profissional.instagramUrl ?? '';
              _tiktokController.text = profissional.tiktokUrl ?? '';
              _siteController.text = profissional.siteUrl ?? '';
              _enderecoController.text = profissional.endereco ?? '';
              _cepController.text = profissional.cep ?? '';
              _numeroController.text = profissional.numero ?? '';
              _complementoController.text = profissional.complemento ?? '';
              _carteiraMotorista = profissional.carteiraMotorista;
              _formInitialized = true;
            });
          });
        }

        final percent = profissional.percentualPerfilCompleto;
        final missing = <String>[];
        if (profissional.descricao.trim().isEmpty ||
            profissional.descricao.trim().toLowerCase() == 'atualize seu perfil') {
          missing.add('profissão');
        }
        if (profissional.idade == null || profissional.idade! <= 0) {
          missing.add('idade');
        }
        if ((profissional.tipoPagamento ?? '').trim().isEmpty) {
          missing.add('pagamento');
        }
        if ((profissional.endereco ?? '').trim().isEmpty) {
          missing.add('endereço');
        }
        if ((profissional.cep ?? '').trim().isEmpty) {
          missing.add('cep');
        }
        if ((profissional.numero ?? '').trim().isEmpty) {
          missing.add('número');
        }
        if (profissional.cidadeId == null) {
          missing.add('cidade');
        }
        if (profissional.categoriaId == null) {
          missing.add('categoria');
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Text(
                'Perfil ${(percent * 100).round()}% completo',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: percent),
              if (missing.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Falta: ${missing.join(', ')}'),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _carteiraMotorista,
                onChanged: (value) {
                  setState(() {
                    _carteiraMotorista = value;
                  });
                },
                title: const Text('Possui carteira de motorista'),
              ),
              const SizedBox(height: 12),
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
                controller: _idadeController,
                decoration: const InputDecoration(
                  labelText: 'Idade',
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
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o endereço';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(
                  labelText: 'CEP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.isEmpty) return 'Informe o CEP';
                  if (digits.length != 8) return 'CEP inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _complementoController,
                decoration: const InputDecoration(
                  labelText: 'Complemento (opcional)',
                  border: OutlineInputBorder(),
                ),
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
              TextFormField(
                controller: _instagramController,
                decoration: const InputDecoration(
                  labelText: 'Instagram (link ou @)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _uploadingPhoto
                    ? null
                    : () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                        if (picked == null) return;
                        setState(() {
                          _uploadingPhoto = true;
                        });
                        try {
                          final remote = ref.read(profissionalProfileRemoteProvider);
                          final updated = await remote.uploadFoto(picked.path);
                          ref.invalidate(profissionalMeProvider);
                          if (mounted) {
                            _fotoUrlController.text = updated.fotoUrl ?? '';
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Foto atualizada')),
                            );
                          }
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Falha ao enviar foto')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _uploadingPhoto = false;
                            });
                          }
                        }
                      },
                icon: const Icon(Icons.photo),
                label: _uploadingPhoto ? const Text('Enviando...') : const Text('Enviar foto da galeria'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tiktokController,
                decoration: const InputDecoration(
                  labelText: 'TikTok (link ou @)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _siteController,
                decoration: const InputDecoration(
                  labelText: 'Site (opcional)',
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
                    : Text(widget.isOnboarding ? 'Salvar e continuar' : 'Salvar perfil'),
              ),
              ],
            ),
          ),
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
      final updated = await remote.atualizar(
        nome: _nomeController.text.trim(),
        telefone: _telefoneController.text.trim(),
        descricao: _descricaoController.text.trim(),
        fotoUrl: _fotoUrlController.text.trim().isEmpty
            ? ''
            : _fotoUrlController.text.trim(),
        anosExperiencia: _parseIntOrNull(_anosExperienciaController.text),
        idade: _parseIntOrNull(_idadeController.text),
        tipoPagamento: _tipoPagamento,
        instagramUrl: _instagramController.text.trim(),
        tiktokUrl: _tiktokController.text.trim(),
        siteUrl: _siteController.text.trim(),
        endereco: _enderecoController.text.trim(),
        cep: _cepController.text.trim(),
        numero: _numeroController.text.trim(),
        complemento: _complementoController.text.trim(),
        bairro:
            _bairroController.text.trim().isEmpty ? '' : _bairroController.text.trim(),
        carteiraMotorista: _carteiraMotorista,
        cidadeId: _cidadeId,
        categoriaId: _categoriaId,
      );
      ref
          .read(authControllerProvider.notifier)
          .updateSession(nome: updated.nome);
      ref.invalidate(profissionalMeProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado')),
        );
      }

      if (widget.isOnboarding) {
        final entity = updated.toEntity();
        if (entity.isPerfilProfissionalCompleto) {
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const CitySelectionPage()),
            (route) => false,
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Complete os campos obrigatórios')),
          );
        }
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

  Future<void> _changePhoto() async {
    if (_uploadingPhoto) return;
    setState(() {
      _uploadingPhoto = true;
    });
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      final remote = ref.read(profissionalProfileRemoteProvider);
      final updated = await remote.uploadFoto(picked.path);
      ref.invalidate(profissionalMeProvider);
      if (mounted) {
        _fotoUrlController.text = updated.fotoUrl ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada')),
        );
      }
    } catch (e) {
      var message = 'Falha ao enviar foto';
      if (e is DioException) {
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          message = 'Sessão expirada. Faça login novamente.';
        } else if (status != null) {
          message = 'Falha ao enviar foto (HTTP $status)';
          final data = e.response?.data;
          if (data is Map<String, dynamic>) {
            final text = data['message'];
            if (text is String && text.trim().isNotEmpty) {
              message = text.trim();
            }
          }
        } else if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          message = 'Sem conexão com o servidor. Verifique sua internet.';
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploadingPhoto = false;
        });
      }
    }
  }
}
