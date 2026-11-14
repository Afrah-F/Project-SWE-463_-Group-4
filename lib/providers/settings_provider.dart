import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../utils/formatters.dart';

/// Language, currency, reminders and the onboarding flag. These are stored per
/// device (not per account) and read before the app starts.
class SettingsProvider extends ChangeNotifier {
  static const _kLang = 'mizania_lang';
  static const _kCurrency = 'mizania_currency';
  static const _kReminders = 'mizania_reminders';
  static const _kOnboarding = 'mizania_onboarding_done';

  final SharedPreferences _prefs;
  AppSettings _settings;

  SettingsProvider(this._prefs)
      : _settings = AppSettings(
          languageCode: _prefs.getString(_kLang) ?? 'en',
          currencyCode: _prefs.getString(_kCurrency) ?? 'SAR',
          billRemindersEnabled: _prefs.getBool(_kReminders) ?? true,
          onboardingDone: _prefs.getBool(_kOnboarding) ?? false,
        );

  AppSettings get settings => _settings;
  String get languageCode => _settings.languageCode;
  String get currencyCode => _settings.currencyCode;
  bool get isArabic => _settings.languageCode == 'ar';
  bool get billRemindersEnabled => _settings.billRemindersEnabled;
  bool get onboardingDone => _settings.onboardingDone;
  Locale get locale => Locale(_settings.languageCode);

  String money(double amount) => formatMoney(amount, currencyCode);

  Future<void> setLanguage(String code) async {
    if (code == _settings.languageCode) return;
    _settings = _settings.copyWith(languageCode: code);
    notifyListeners();
    await _prefs.setString(_kLang, code);
  }

  Future<void> setCurrency(String code) async {
    if (code == _settings.currencyCode) return;
    _settings = _settings.copyWith(currencyCode: code);
    notifyListeners();
    await _prefs.setString(_kCurrency, code);
  }

  Future<void> setBillReminders(bool value) async {
    _settings = _settings.copyWith(billRemindersEnabled: value);
    notifyListeners();
    await _prefs.setBool(_kReminders, value);
  }

  Future<void> completeOnboarding() async {
    _settings = _settings.copyWith(onboardingDone: true);
    notifyListeners();
    await _prefs.setBool(_kOnboarding, true);
  }
}
