import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/colors.dart';
import 'core/text.dart';
import 'data/app_state.dart';
import 'features/auth/reset_password_page.dart';
import 'features/auth/splash_page.dart';

class NgikutAjaApp extends StatelessWidget {
  const NgikutAjaApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'NgikutAja',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: const Locale('id'),
        supportedLocales: const [Locale('id'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const SplashPage(),
        onGenerateRoute: (settings) {
          // Tautan dari email reset password: /reset-password?email=...
          final uri = Uri.parse(settings.name ?? '/');
          if (uri.path == '/reset-password') {
            return MaterialPageRoute(builder: (_) => NewPasswordPage(email: uri.queryParameters['email'] ?? ''));
          }
          return null;
        },
      ),
    );
  }
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.ink,
    primary: AppColors.ink,
    onPrimary: AppColors.white,
    secondary: AppColors.teal,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    error: AppColors.negative,
  );
  return ThemeData(
