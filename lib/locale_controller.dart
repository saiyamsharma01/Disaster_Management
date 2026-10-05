import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends InheritedWidget {
  const LocaleController({super.key, required super.child});

  static final ValueNotifier<Locale?> _notifier = ValueNotifier<Locale?>(null);

  static LocaleController of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<LocaleController>();
    assert(widget != null, 'LocaleController not found in context');
    return widget!;
  }

  static ValueListenable<Locale?> get notifier => _notifier;

  Locale? get locale => _notifier.value;

  void setLocale(Locale? locale) {
    _notifier.value = locale;
    _persistLocale(locale);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static const String _prefsKey = 'app_locale_code';

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.isEmpty) {
      _notifier.value = null;
      return;
    }
    _notifier.value = Locale(code);
  }

  Future<void> _persistLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}

