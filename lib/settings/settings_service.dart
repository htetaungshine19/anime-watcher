import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    final box = await Hive.openBox('theme');
    final theme = await box.get("theme");
    box.close();
    if (theme != null) {
      if (theme == "1") {
        return ThemeMode.light;
      } else if (theme == "2") {
        return ThemeMode.dark;
      } else if (theme == "3") {
        return ThemeMode.system;
      } else {
        return ThemeMode.system;
      }
    } else {
      return ThemeMode.system;
    }
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    final box = await Hive.openBox('theme');
    if (theme == ThemeMode.light) {
      box.put("theme", "1");
    }
    if (theme == ThemeMode.dark) {
      box.put("theme", "2");
    }
    if (theme == ThemeMode.system) {
      box.put("theme", "3");
    }
  }
}
