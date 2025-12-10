import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = _prepare();
  }

  Future<void> _prepare() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_onboarding') ?? false;
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      if (seen) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _init,
        builder: (context, snap) {
          return Container(
            alignment: Alignment.center,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Lottie.asset(
                    'assets/lottie/splash.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Synthesia',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
