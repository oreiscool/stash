import 'package:flutter/material.dart';

class AppTheme {
  static const Color _stashPrimary = Color(0xFF003D66); // Dark blue from icon

  // Light Theme - Stash Colors
  static final ThemeData stashLightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _stashPrimary,
      brightness: Brightness.light,
    ),
  );

  // Dark Theme - Stash Colors
  static final ThemeData stashDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _stashPrimary,
      brightness: Brightness.dark,
    ),
  );

  static ThemeData lightThemeFromColorScheme(ColorScheme? colorScheme) {
    if (colorScheme == null) return stashLightTheme;

    // Used a workaround to regenerate the ColorScheme while the dynamic_color package
    // is currently not working as intended
    final regeneratedColorScheme = ColorScheme.fromSeed(
      seedColor: Color(colorScheme.primary.toARGB32()),
      brightness: Brightness.light,
    );

    return ThemeData(useMaterial3: true, colorScheme: regeneratedColorScheme);
  }

  static ThemeData darkThemeFromColorScheme(ColorScheme? colorScheme) {
    if (colorScheme == null) return stashDarkTheme;

    // Used a workaround to regenerate the ColorScheme while the dynamic_color package
    // is currently not working as intended
    final regeneratedColorScheme = ColorScheme.fromSeed(
      seedColor: Color(colorScheme.primary.toARGB32()),
      brightness: Brightness.dark,
    );

    return ThemeData(useMaterial3: true, colorScheme: regeneratedColorScheme);
  }
}
