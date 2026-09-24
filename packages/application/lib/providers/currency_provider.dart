import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _currencyKey = 'selected_currency';

class CurrencyConfig {
  final String symbol;
  final String code;
  final String locale;

  const CurrencyConfig({
    required this.symbol,
    required this.code,
    required this.locale,
  });
}

// Supported currencies
const supportedCurrencies = [
  CurrencyConfig(symbol: '¥', code: 'JPY', locale: 'ja_JP'),
  CurrencyConfig(symbol: 'NT\$', code: 'TWD', locale: 'zh_TW'),
  CurrencyConfig(symbol: '\$', code: 'USD', locale: 'en_US'),
  CurrencyConfig(symbol: '€', code: 'EUR', locale: 'fr_FR'),
  CurrencyConfig(symbol: '£', code: 'GBP', locale: 'en_GB'),
  CurrencyConfig(symbol: 'CN¥', code: 'CNY', locale: 'zh_CN'),
];

// Maps device locale to default currency
CurrencyConfig _defaultForLocale(Locale? locale) {
  if (locale == null) return supportedCurrencies[0];
  final lang = locale.languageCode;
  final country = locale.countryCode ?? '';

  if (lang == 'ja') return supportedCurrencies[0]; // JPY
  if (lang == 'zh' && country == 'TW') return supportedCurrencies[1]; // TWD
  if (lang == 'zh') return supportedCurrencies[5]; // CNY
  if (lang == 'en' && country == 'US') return supportedCurrencies[2]; // USD
  if (lang == 'en') return supportedCurrencies[2]; // USD
  if (lang == 'fr' || lang == 'it' || lang == 'es') {
    return supportedCurrencies[3]; // EUR
  }
  return supportedCurrencies[2]; // default USD
}

class CurrencyNotifier extends AsyncNotifier<CurrencyConfig> {
  @override
  Future<CurrencyConfig> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_currencyKey);
    if (saved != null) {
      final match = supportedCurrencies
          .where((c) => c.code == saved)
          .firstOrNull;
      if (match != null) return match;
    }
    // Fall back to device locale
    final deviceLocale = PlatformDispatcher.instance.locale;
    return _defaultForLocale(deviceLocale);
  }

  Future<void> setCurrency(CurrencyConfig currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.code);
    state = AsyncData(currency);
  }
}

final currencyProvider =
    AsyncNotifierProvider<CurrencyNotifier, CurrencyConfig>(
      CurrencyNotifier.new,
    );
