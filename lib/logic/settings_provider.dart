import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../data/models/app_settings.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier({bool shouldLoad = true}) : super(const AppSettings()) {
    if (shouldLoad) _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox<AppSettings>(AppConstants.settingsBox);
    try {
      final storedSettings = box.get(AppConstants.settingsKey);
      if (storedSettings != null && storedSettings is AppSettings) {
        state = storedSettings;
      } else {
        // Fallback or migration if needed (e.g. if previous data was different)
        // For now, if type mismatch or null, keep default.
      }
    } catch (e) {
      // Handle error, maybe reset box?
      // print('Error loading settings: $e');
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    state = newSettings;
    final box = await Hive.openBox<AppSettings>(AppConstants.settingsBox);
    await box.put(AppConstants.settingsKey, newSettings);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    final newSettings = state.copyWith(themeMode: mode.toString());
    await updateSettings(newSettings);
  }
}
