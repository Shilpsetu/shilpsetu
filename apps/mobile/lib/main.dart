import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilpsetu/core/localization/language_provider.dart';
import 'package:shilpsetu/core/router/app_router.dart';
import 'package:shilpsetu/core/theme/app_theme.dart';
import 'package:shilpsetu/core/theme/tokens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ShilpsetuApp()));
}

class ShilpsetuApp extends ConsumerWidget {
  const ShilpsetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final langState = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'Shilpsetu',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      locale: langState.selectedLanguage.locale,
      supportedLocales: SupportedLocales.phase1,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
