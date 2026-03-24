import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/settings_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiBaseUrlController = TextEditingController();
  bool _apiInitialized = false;

  @override
  void dispose() {
    _apiBaseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);
    final apiBaseUrlAsync = ref.watch(apiBaseUrlProvider);

    apiBaseUrlAsync.whenData((value) {
      if (_apiInitialized) return;
      _apiBaseUrlController.text = value ?? '';
      _apiInitialized = true;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Servidor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiBaseUrlController,
            decoration: const InputDecoration(
              labelText: 'API Base URL (opcional)',
              hintText: 'https://seu-backend.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(secureStorageProvider).clearApiBaseUrl();
                    ref.invalidate(apiBaseUrlProvider);
                    ref.invalidate(dioClientProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Servidor restaurado')),
                      );
                    }
                  },
                  child: const Text('Restaurar padrão'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final value = _apiBaseUrlController.text.trim();
                    if (value.isEmpty) {
                      await ref.read(secureStorageProvider).clearApiBaseUrl();
                    } else {
                      await ref.read(secureStorageProvider).saveApiBaseUrl(value);
                    }
                    ref.invalidate(apiBaseUrlProvider);
                    ref.invalidate(dioClientProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Servidor atualizado')),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Aparência',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ThemeMode>(
            value: themeMode,
            decoration: const InputDecoration(
              labelText: 'Tema',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('Sistema'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Claro'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Escuro'),
              ),
            ],
            onChanged: (value) async {
              if (value == null) return;
              await ref.read(themeControllerProvider.notifier).setMode(value);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Conta',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

