import 'package:flutter/material.dart';

/// Centralized app color constants.
/// Use these throughout the app instead of hardcoding colors,
/// so the theme can be easily adjusted from a single place.
class CadenceColors {
  // Brand colors
  // static const Color primary = Color(0xFF6C63FF);
  // static const Color secondary = Color(0xFF03DAC6);
  static const Color accent = Color.fromARGB(255, 111, 238, 252);
  static const Color accentLessOpacity = Color.fromARGB(35, 111, 238, 252);
  static const Color otherAccent = Color.fromARGB(255, 243, 176, 229);
  static const Color otherAccentLessOpacity = Color.fromARGB(20, 243, 176, 229);

  // Neutral colors
  static const Color black = Colors.black;
  static const Color background = Color(0xFF141218);
  static const Color border = Color.fromARGB(255, 53, 53, 52);
  static const Color surface = Color.fromARGB(255, 29, 28, 28);
  static const Color surfaceOnSurface = Color.fromARGB(255, 63, 53, 52);
  // static const Color error = Color(0xFFB00020);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  // static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color.fromARGB(255, 165, 214, 167);
  static const Color warning = Color.fromARGB(255, 233, 175, 166);
  static const Color danger = Colors.red;
  static const Color info = Color.fromARGB(255, 173, 216, 230);

  // Achievement tier colors
  static const Color bronze = Color.fromARGB(255, 205, 133, 84);
  static const Color silver = Color.fromARGB(255, 197, 203, 214);
  static const Color gold = Color.fromARGB(255, 240, 196, 100);
}
