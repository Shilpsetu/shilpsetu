import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karigar/core/theme/tokens.dart';

void main() {
  runApp(const ProviderScope(child: KarigarApp()));
}

class KarigarApp extends StatelessWidget {
  const KarigarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karigar',
      debugShowCheckedModeBanner: false,
      supportedLocales: SupportedLocales.phase1,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.primary,
          surface: Palette.surface,
        ),
        // Enforced globally so no screen can accidentally ship a small target.
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      home: const _Placeholder(),
    );
  }
}

/// Replaced in Phase 0 by the go_router shell. Exists so `flutter run` works
/// on day one and CI has something to analyse.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(Sizes.gutter),
          child: Text(
            'Karigar',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
