import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics_service.dart';

const _localeKey = 'selected_locale';

class LocaleNotifier extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved == null) return null; // null = use device locale
    final parts = saved.split('_');
    return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }

  Future<void> setLocale(Locale? locale) async {
    final changed = locale != state.value;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      final key = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await prefs.setString(_localeKey, key);
    }
    state = AsyncData(locale);
    if (changed && locale != null) {
      unawaited(ref.read(analyticsProvider).logChangeLanguage(locale));
    }
  }
}

final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
