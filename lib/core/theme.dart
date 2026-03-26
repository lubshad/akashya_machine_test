import 'package:flutter/material.dart';

class AppTheme {
  // ─── Premium Color System ──────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF3E8EF7); // Electric blue
  static const Color secondaryAccentColor = Color(0xFF7BC4FF); // Sky blue
  static const Color highlightColor = Color(0xFF5BAAFF); // Blue glow
  static const Color accentGold = Color(0xFFF5C242); // Premium gold
  static const Color accentCyan = Color(0xFF00C8E8); // Cyan accent

  static const Color backgroundColorStart = Color(
    0xFF020A14,
  ); // Ultra-deep dark
  static const Color backgroundColorEnd = Color(0xFF071525); // Deep navy
  static const Color backgroundColor = Color(0xFF020A14);

  static const Color surfaceColor = Color(0x0DFFFFFF); // ~5% white glass
  static const Color textPrimary = Color(0xFFEDF2FF); // Cool white
  static const Color textSecondary = Color(0xFF6A8BB2); // Steel blue-gray
  // ────────────────────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: "Kanit",
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryAccentColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          elevation: 0,
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0AFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
        prefixIconColor: primaryColor,
      ),
    );
  }

  // ─── Background gradient ─────────────────────────────────────────────────
  static BoxDecoration get mainGradient => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [backgroundColorStart, backgroundColorEnd],
    ),
  );

  // ─── Premium glassmorphism: gradient glass + dual-layer shadow ────────────
  static BoxDecoration get glassDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x11FFFFFF), // ~7% white
        Color(0x06FFFFFF), // ~2% white
      ],
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: const Color(0x14FFFFFF), // ~8% white border
      width: 0.8,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withValues(alpha: 0.07),
        blurRadius: 32,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ─── Premium featured card (stronger glow, for hero cards) ───────────────
  static BoxDecoration get premiumGlassDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x18FFFFFF), // ~9% white
        Color(0x08FFFFFF), // ~3% white
      ],
    ),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(
      color: const Color(0x1AFFFFFF), // ~10% white border
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withValues(alpha: 0.14),
        blurRadius: 48,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
