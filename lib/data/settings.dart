import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/themes.dart';
import 'mood.dart';

/// User preferences, persisted with shared_preferences.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs);
  final SharedPreferences _prefs;

  static const supportedLanguages = ['tr', 'en'];

  String? get languageCode => _prefs.getString('locale');
  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  /// Language actually in use (explicit choice or device language).
  String resolvedLanguage(BuildContext context) => Localizations.localeOf(context).languageCode;

  Future<void> setLanguage(String? code) => _set('locale', code);

  String get themeId => _prefs.getString('theme') ?? AppThemes.defaultId;
  Future<void> setThemeId(String id) => _set('theme', id);

  String get moodPackId => _prefs.getString('moodPack') ?? MoodPacks.defaultId;
  Future<void> setMoodPackId(String id) => _set('moodPack', id);
  MoodPack get moodPack => MoodPacks.byId(moodPackId);

  bool get onboarded => _prefs.getBool('onboarded') ?? false;
  Future<void> setOnboarded(bool v) => _set('onboarded', v);

  bool get reminderOn => _prefs.getBool('reminderOn') ?? false;
  int get reminderMinutes => _prefs.getInt('reminderMinutes') ?? 21 * 60;
  TimeOfDay get reminderTime => TimeOfDay(hour: reminderMinutes ~/ 60, minute: reminderMinutes % 60);
  Future<void> setReminder({required bool on, TimeOfDay? time}) async {
    await _prefs.setBool('reminderOn', on);
    if (time != null) await _prefs.setInt('reminderMinutes', time.hour * 60 + time.minute);
    notifyListeners();
  }

  String? get pinHash => _prefs.getString('pinHash');
  String? get pinSalt => _prefs.getString('pinSalt');
  bool get hasPin => pinHash != null;
  Future<void> setPin(String? hash, String? salt) async {
    await _set('pinHash', hash, notify: false);
    await _set('pinSalt', salt, notify: false);
    if (hash == null) await _prefs.remove('biometric');
    notifyListeners();
  }

  bool get biometric => _prefs.getBool('biometric') ?? false;
  Future<void> setBiometric(bool v) => _set('biometric', v);

  /// null = decide from the language (Monday for Turkish, Sunday for English).
  bool weekStartsMonday(String language) => _prefs.getBool('weekMonday') ?? language != 'en';
  Future<void> setWeekStartsMonday(bool v) => _set('weekMonday', v);

  bool get adsPersonalized => _prefs.getBool('adsPersonalized') ?? false;
  Future<void> setAdsPersonalized(bool v) => _set('adsPersonalized', v);

  bool get proCache => _prefs.getBool('proCache') ?? false;
  Future<void> setProCache(bool v) => _set('proCache', v, notify: false);

  /// Dismissed state of one-off hints, keyed by name.
  bool seen(String hint) => _prefs.getBool('seen_$hint') ?? false;
  Future<void> markSeen(String hint) => _set('seen_$hint', true, notify: false);

  Future<void> _set(String key, Object? value, {bool notify = true}) async {
    switch (value) {
      case null:
        await _prefs.remove(key);
      case String v:
        await _prefs.setString(key, v);
      case bool v:
        await _prefs.setBool(key, v);
      case int v:
        await _prefs.setInt(key, v);
    }
    if (notify) notifyListeners();
  }
}
