import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../core/constants/app_constants.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _storage = FlutterSecureStorage();

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await _storage.read(key: AppConstants.themeKey);
    state = switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> toggle(Brightness systemBrightness) async {
    final effectivelyDark = state == ThemeMode.dark ||
        (state == ThemeMode.system && systemBrightness == Brightness.dark);

    state = effectivelyDark ? ThemeMode.light : ThemeMode.dark;
    await _storage.write(
      key: AppConstants.themeKey,
      value: state == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
