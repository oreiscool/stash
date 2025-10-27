import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_providers.g.dart';

class ThemeSettings {
  final String themeMode; // 'system', 'light', 'dark'
  final String colorScheme; // 'system', 'stash'

  const ThemeSettings({this.themeMode = 'system', this.colorScheme = 'system'});

  ThemeSettings copyWith({String? themeMode, String? colorScheme}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }

  ThemeMode get themeModeEnum {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

@riverpod
class ThemeSettingsNotifier extends _$ThemeSettingsNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _colorSchemeKey = 'color_scheme';

  @override
  Future<ThemeSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString(_themeModeKey) ?? 'system';
    final colorScheme = prefs.getString(_colorSchemeKey) ?? 'system';

    return ThemeSettings(themeMode: themeMode, colorScheme: colorScheme);
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);

    state = AsyncValue.data(state.value!.copyWith(themeMode: mode));
  }

  Future<void> setColorScheme(String scheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorSchemeKey, scheme);

    state = AsyncValue.data(state.value!.copyWith(colorScheme: scheme));
  }
}
