
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/forgot_password.dart';
import 'screens/login.dart';
import 'screens/new_password.dart';
import 'screens/onboarding1.dart';
import 'screens/onboarding2.dart';
import 'screens/preference.dart';
import 'screens/register.dart';
import 'screens/splash.dart';
import 'core/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NgikutAjaApp());
}

class NgikutAjaApp extends StatelessWidget {
  const NgikutAjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NgikutAja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.ground,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.ink),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: AppColors.ink,
              displayColor: AppColors.ink,
            ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding1': (_) => const Onboarding1Screen(),
        '/onboarding2': (_) => const Onboarding2Screen(),
        '/preferences': (_) => const PreferenceScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/new-password': (_) => const NewPasswordScreen(),
        '/home': (_) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
      },
    );
  }
}
