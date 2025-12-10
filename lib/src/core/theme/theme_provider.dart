import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;
  AppTheme({required this.light, required this.dark, required this.mode});
}

final themeProvider = Provider<AppTheme>((ref) {
  final hour = DateTime.now().hour;

  final isDay = hour >= 6 && hour < 18;
  final primary = const Color(0xFF1DB954);
  final swatch = MaterialColor(primary.value, {
    50: primary.withOpacity(.1),
    100: primary.withOpacity(.2),
    200: primary.withOpacity(.3),
    300: primary.withOpacity(.4),
    400: primary.withOpacity(.5),
    500: primary,
    600: primary,
    700: primary,
    800: primary,
    900: primary,
  });

  final light = ThemeData(
    brightness: Brightness.light,
    primarySwatch: swatch,
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  );

  final dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: swatch,
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  );

  return AppTheme(
    light: light,
    dark: dark,
    mode: isDay ? ThemeMode.light : ThemeMode.dark,
  );
});
