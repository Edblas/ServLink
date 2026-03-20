import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/features/splash/splash_page.dart';

void main() {
  runApp(const ProviderScope(child: ServLinkApp()));
}

class ServLinkApp extends StatelessWidget {
  const ServLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
