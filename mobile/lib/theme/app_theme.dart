import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand palette ──────────────────────────────────────────────
  static const Color primary = Color(0xFF1C3A2A); // dark forest green
  static const Color primaryContainer = Color(0xFF2A5040); // medium forest green
  static const Color accent = Color(0xFFB8F04A); // bright lime green
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFE8A020);
  static const Color error = Color(0xFFD94040);

  // ── Light cream surfaces ────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF0EDE4); // cream/off-white
  static const Color surfaceLight = Color(0xFFF7F4EC); // lighter cream
  static const Color surfaceCard = Color(0xFFEDE9DF); // card cream
  static const Color cardBorder = Color(0xFFDDD9CF);

  // ── Dark surfaces (kept for compatibility) ──────────────────────
  static const Color backgroundDark = Color(0xFFF0EDE4); // now maps to cream
  static const Color surfaceDark = Color(0xFFEDE9DF);
  static const Color surfaceVariantDark = Color(0xFFE5E1D7);
  static const Color cardGlass = Color(0x14000000);
  static const Color cardGlassBorder = Color(0x20000000);

  // ── Text colors ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A2A1E);
  static const Color textSecondary = Color(0xFF5A6B5E);
  static const Color textMuted = Color(0xFF8A9B8E);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: accent,
      onSecondary: primary,
      tertiary: accentGreen,
      onTertiary: Colors.white,
      surface: surfaceLight,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceCard,
      onSurfaceVariant: textSecondary,
      error: error,
      onError: Colors.white,
      outline: cardBorder,
      outlineVariant: Color(0xFFCCC8BE),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.dmSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.5,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: cardBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textMuted),
      hintStyle: const TextStyle(color: textMuted),
    ),
    dividerTheme: const DividerThemeData(
      color: cardBorder,
      thickness: 1,
      space: 0,
    ),
  );

  static ThemeData get lightTheme => darkTheme;
}
