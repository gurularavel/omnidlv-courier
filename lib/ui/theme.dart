import 'package:flutter/material.dart';

/// The courier "porcelain" look from the web app (DESIGN.md in the omnidlv repo): white
/// ground, midnight ink, one scarlet action, line-drawn outlines, a big numeral for time.
class Palette {
  Palette._();

  static const night = Color(0xFF0B1230);
  static const text = Color(0xFF0B1230);
  static const text2 = Color(0xFF45506E);
  static const text3 = Color(0xFF6B7591);
  static const outline = Color(0xFF0B1230);
  static const hairline = Color(0xFFDDE1EA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceHover = Color(0xFFF3F4F8);
  static const action = Color(0xFFE21D2D); // scarlet: the one thing to press, and "late"
  static const danger = Color(0xFFC8102E);
  static const risk = Color(0xFF8A5D00); // amber that reads on white
  static const green = Color(0xFF1F9D55);
  static const teal = Color(0xFF14B8A6);

  static Color parse(String? hex, {Color fallback = teal}) {
    if (hex == null || !hex.startsWith('#') || hex.length != 7) return fallback;
    return Color(int.parse('FF${hex.substring(1)}', radix: 16));
  }
}

class Typo {
  Typo._();

  /// The time-left numeral on the home screen.
  static const hero = TextStyle(fontSize: 56, height: 1, fontWeight: FontWeight.w800, letterSpacing: -1.5, color: Palette.text, fontFeatures: [FontFeature.tabularFigures()]);
  static const display = TextStyle(fontSize: 32, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Palette.text);
  static const title = TextStyle(fontSize: 20, height: 1.2, fontWeight: FontWeight.w700, color: Palette.text);
  static const body = TextStyle(fontSize: 16, height: 1.4, color: Palette.text);
  static const label = TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Palette.text2);
  static const code = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Palette.text2, fontFeatures: [FontFeature.tabularFigures()]);
}

const radiusPlate = 12.0;

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: Palette.action, primary: Palette.action, onPrimary: Colors.white, surface: Palette.surface, onSurface: Palette.text, error: Palette.danger);
  final outline = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPlate), side: const BorderSide(color: Palette.outline, width: 1.5));

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.surface,
    textTheme: const TextTheme(bodyMedium: Typo.body, bodyLarge: Typo.body, titleLarge: Typo.title),
    appBarTheme: const AppBarTheme(backgroundColor: Palette.surface, foregroundColor: Palette.text, elevation: 0, scrolledUnderElevation: 0, centerTitle: false),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.action,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(60),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPlate)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.text,
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0),
        shape: outline,
        side: const BorderSide(color: Palette.outline, width: 1.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Palette.text, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusPlate), borderSide: const BorderSide(color: Palette.outline, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusPlate), borderSide: const BorderSide(color: Palette.outline, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusPlate), borderSide: const BorderSide(color: Palette.action, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusPlate), borderSide: const BorderSide(color: Palette.danger, width: 1.5)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Palette.surface, showDragHandle: true, constraints: BoxConstraints(maxWidth: 520)),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: Palette.night),
    dividerTheme: const DividerThemeData(color: Palette.hairline, thickness: 1, space: 1),
  );
}
