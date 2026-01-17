import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, ThemeMode>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<ThemeMode> {
  SettingsNotifier({bool shouldLoad = true}) : super(ThemeMode.system) {
    if (shouldLoad) _loadSettings();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadSettings() async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    final String? themeString = box.get(_themeKey);
    if (themeString != null) {
      state = _getThemeModeFromString(themeString);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final box = await Hive.openBox(AppConstants.settingsBox);
    await box.put(_themeKey, mode.toString());
  }

  ThemeMode _getThemeModeFromString(String themeString) {
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeString,
      orElse: () => ThemeMode.system,
    );
  }
}
