
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color graphite = Color(0xFF343A40);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF343A40),
      onPrimary: Colors.white,

      primaryContainer: Color(0xFFDDE1E5),
      onPrimaryContainer: Color(0xFF17191C),

      secondary: Color(0xFF5D646C),
      onSecondary: Colors.white,

      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1B1D1F),

      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF8F9FA),
      surfaceContainer: Color(0xFFF0F1F2),

      outline: Color(0xFF737980),
      outlineVariant: Color(0xFFDDE0E3),
    ),

    scaffoldBackgroundColor: const Color(0xFFF4F5F6),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    ),

    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD5D9DE),
      onPrimary: Color(0xFF292D32),

      primaryContainer: Color(0xFF454A51),
      onPrimaryContainer: Color(0xFFECEEF0),

      secondary: Color(0xFFB9C0C8),
      onSecondary: Color(0xFF292D32),

      surface: Color(0xFF24272B),
      onSurface: Color(0xFFE4E7EA),

      surfaceContainerLowest: Color(0xFF181A1D),
      surfaceContainerLow: Color(0xFF1E2124),
      surfaceContainer: Color(0xFF292C30),

      outline: Color(0xFF8C939B),
      outlineVariant: Color(0xFF454A51),
    ),

    scaffoldBackgroundColor: const Color(0xFF181A1D),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    ),

    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
  );
}