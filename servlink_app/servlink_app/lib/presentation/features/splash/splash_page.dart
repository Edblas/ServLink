import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/profissional_profile_providers.dart';
import '../auth/login_page.dart';
import '../city/city_selection_page.dart';
import '../profile/profile_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      final authState = ref.read(authControllerProvider);
      final session = authState.session;
      if (session == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }

      if (session.role == 'PROFISSIONAL') {
        try {
          final remote = ref.read(profissionalProfileRemoteProvider);
          final profissional = await remote.criarOuObter();
          final entity = profissional.toEntity();
          if (!mounted) return;
          if (!entity.isPerfilProfissionalCompleto) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const ProfilePage(isOnboarding: true),
              ),
            );
            return;
          }
        } catch (_) {
          if (!mounted) return;
        }
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CitySelectionPage()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ServLink',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
