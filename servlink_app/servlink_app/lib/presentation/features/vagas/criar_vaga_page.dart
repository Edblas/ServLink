import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/vaga_providers.dart';

class CriarVagaPage extends ConsumerStatefulWidget {
  const CriarVagaPage({super.key});

  @override
  ConsumerState<CriarVagaPage> createState() => _CriarVagaPageState();
}

class _CriarVagaPageState extends ConsumerState<CriarVagaPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  DateTime? _dataTrabalho;
  int? _categoriaId;
  String _urgencia = 'FLEXIVEL';
  String _tipo = 'BICO';

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataTrabalho ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      _dataTrabalho = picked;
    });
  }

  double? _parseValor(String value) {
    final normalized = value.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(normalized);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cidade = ref.read(cidadeSelecionadaProvider);
    if (cidade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma cidade primeiro')),
      );
      return;
    }

    final data = _dataTrabalho;
    if (data == null) return;

    final categoriaId = _categoriaId;
    if (categoriaId == null) return;

    final valor = _parseValor(_valorController.text);
    if (valor == null) return;

    try {
      await ref.read(vagaActionControllerProvider.notifier).criarVaga(
            titulo: _tituloController.text.trim(),
            descricao: _descricaoController.text.trim(),
            valor: valor,
            cidadeId: cidade.id,
            dataTrabalho: data,
            urgencia: _urgencia,
            tipo: _tipo,
            categoriaId: categoriaId,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao criar vaga')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final role = authState.session?.role;
    final categoriasAsync = ref.watch(categoriasProvider);
    final actionState = ref.watch(vagaActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar vaga'),
      ),
      body: role != 'CLIENTE'
          ? const Center(child: Text('Apenas empresas podem criar vagas'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe a descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valorController,
                      decoration:
                          const InputDecoration(labelText: 'Valor estimado (R\$)'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o valor';
                        }
                        if (_parseValor(value) == null) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _urgencia,
                      decoration: const InputDecoration(labelText: 'Urgência'),
                      items: const [
                        DropdownMenuItem(
                          value: 'HOJE',
                          child: Text('Hoje'),
                        ),
                        DropdownMenuItem(
                          value: 'SEMANA',
                          child: Text('Essa semana'),
                        ),
                        DropdownMenuItem(
                          value: 'FLEXIVEL',
                          child: Text('Flexível'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _urgencia = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipo,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        DropdownMenuItem(
                          value: 'BICO',
                          child: Text('Bico (temporário)'),
                        ),
                        DropdownMenuItem(
                          value: 'EMPREGO',
                          child: Text('Emprego'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _tipo = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    categoriasAsync.when(
                      data: (categorias) {
                        return DropdownButtonFormField<int>(
                          value: _categoriaId,
                          decoration:
                              const InputDecoration(labelText: 'Categoria'),
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
                      loading: () => const LinearProgressIndicator(),
                      error: (error, stack) =>
                          const Text('Erro ao carregar categorias'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(
                        _dataTrabalho == null
                            ? 'Selecionar data do trabalho'
                            : 'Data: ${_dataTrabalho!.day.toString().padLeft(2, '0')}/${_dataTrabalho!.month.toString().padLeft(2, '0')}/${_dataTrabalho!.year.toString().padLeft(4, '0')}',
                      ),
                    ),
                    if (_dataTrabalho == null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Selecione a data do trabalho',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: actionState.isLoading ? null : _submit,
                      child: actionState.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Publicar vaga'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
