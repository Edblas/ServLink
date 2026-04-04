import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../providers/auth_providers.dart';
import '../../providers/profissional_profile_providers.dart';
import '../city/city_selection_page.dart';
import '../profile/profile_page.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _sendingReset = false;
  bool _resettingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final auth = ref.read(authControllerProvider.notifier);
    await auth.login(_emailController.text.trim().toLowerCase(), _passwordController.text);
    final state = ref.read(authControllerProvider);
    if (state.session != null) {
      if (!mounted) return;
      final session = state.session!;
      if (session.role == 'PROFISSIONAL') {
        try {
          final remote = ref.read(profissionalProfileRemoteProvider);
          final model = await remote
              .criarOuObter()
              .timeout(const Duration(seconds: 60));
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
        } catch (_) {
          if (!mounted) return;
        }
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CitySelectionPage()),
        (route) => false,
      );
    }
  }

  Future<void> _openForgotPasswordDialog() async {
    final controller = TextEditingController(text: _emailController.text.trim());
    final rootContext = context;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Recuperar senha'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: _resettingPassword
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      _openResetPasswordDialog();
                    },
              child: const Text('Já tenho o código'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _sendingReset
                  ? null
                  : () async {
                      setState(() {
                        _sendingReset = true;
                      });
                      try {
                        final repo = ref.read(authRepositoryProvider);
                        await repo.forgotPassword(
                          email: controller.text.trim().toLowerCase(),
                        );
                        if (!mounted || !dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(rootContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Se o email existir, enviamos um código de recuperação.',
                            ),
                          ),
                        );
                      } catch (_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(rootContext).showSnackBar(
                          const SnackBar(content: Text('Falha ao solicitar recuperação')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _sendingReset = false;
                          });
                        }
                      }
                    },
              child: _sendingReset
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar código'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  Future<void> _openResetPasswordDialog() async {
    final tokenController = TextEditingController();
    final passwordController = TextEditingController();
    final rootContext = context;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Redefinir senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tokenController,
                decoration: const InputDecoration(labelText: 'Código'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Nova senha'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _resettingPassword
                  ? null
                  : () async {
                      setState(() {
                        _resettingPassword = true;
                      });
                      try {
                        final token = tokenController.text.trim();
                        final senha = passwordController.text;
                        if (token.isEmpty || senha.length < 6) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(rootContext).showSnackBar(
                            const SnackBar(content: Text('Informe código e senha válida')),
                          );
                          return;
                        }
                        final repo = ref.read(authRepositoryProvider);
                        await repo.resetPassword(token: token, novaSenha: senha);
                        if (!mounted || !dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(rootContext).showSnackBar(
                          const SnackBar(content: Text('Senha atualizada')),
                        );
                      } catch (_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(rootContext).showSnackBar(
                          const SnackBar(content: Text('Falha ao redefinir senha')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _resettingPassword = false;
                          });
                        }
                      }
                    },
              child: _resettingPassword
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmar'),
            ),
          ],
        );
      },
    );
    tokenController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Bem-vindo de volta',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entre para encontrar profissionais, vagas e caronas.',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
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
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
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
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Informe a senha';
                              }
                              return null;
                            },
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                    : const Text('Entrar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text('Criar conta'),
              ),
              TextButton(
                onPressed: _sendingReset ? null : _openForgotPasswordDialog,
                child: const Text('Esqueci minha senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
