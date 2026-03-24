import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/carona_providers.dart';

class CriarCaronaPage extends ConsumerStatefulWidget {
  const CriarCaronaPage({super.key});

  @override
  ConsumerState<CriarCaronaPage> createState() => _CriarCaronaPageState();
}

class _CriarCaronaPageState extends ConsumerState<CriarCaronaPage> {
  final _formKey = GlobalKey<FormState>();
  final _origemController = TextEditingController();
  final _destinoController = TextEditingController();
  final _vagasController = TextEditingController(text: '1');
  final _valorController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _obsController = TextEditingController();
  DateTime? _dataHora;

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _vagasController.dispose();
    _valorController.dispose();
    _telefoneController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dataHora ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (!mounted) return;
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHora ?? now),
    );
    if (!mounted) return;
    if (time == null) return;
    setState(() {
      _dataHora = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  int? _parseIntOrNull(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  double? _parseDoubleOrNull(String v) {
    final t = v.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(caronaActionControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova carona'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _origemController,
                decoration: const InputDecoration(
                  labelText: 'Origem',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe a origem' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destinoController,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o destino' : null,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.calendar_today),
                label: Text(_dataHora == null
                    ? 'Escolher data e hora'
                    : '${_dataHora!.day.toString().padLeft(2, '0')}/'
                      '${_dataHora!.month.toString().padLeft(2, '0')}/'
                      '${_dataHora!.year} '
                      '${_dataHora!.hour.toString().padLeft(2, '0')}:'
                      '${_dataHora!.minute.toString().padLeft(2, '0')}'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vagasController,
                decoration: const InputDecoration(
                  labelText: 'Vagas',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final parsed = _parseIntOrNull(v ?? '');
                  if (parsed == null || parsed <= 0) return 'Informe um número válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor (opcional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone para contato',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _obsController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: action.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (_dataHora == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selecione data e hora')),
                          );
                          return;
                        }
                        await ref.read(caronaActionControllerProvider.notifier).criar(
                              origem: _origemController.text.trim(),
                              destino: _destinoController.text.trim(),
                              dataHora: _dataHora!,
                              vagas: _parseIntOrNull(_vagasController.text)!,
                              valor: _parseDoubleOrNull(_valorController.text),
                              telefone: _telefoneController.text.trim(),
                              observacao: _obsController.text.trim(),
                            );
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                child: action.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Publicar carona'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
