import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthesia/src/core/theme/theme_provider.dart';
import 'src/presentation/pages/splash_screen.dart';
import 'src/presentation/pages/onboarding_page.dart';
import 'src/presentation/pages/login_page.dart';
import 'src/presentation/pages/home_page.dart';
import 'src/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SynthesiaApp()));
}

class SynthesiaApp extends ConsumerWidget {
  const SynthesiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Synthesia',
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: theme.mode,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const OnboardingPage(),
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}
