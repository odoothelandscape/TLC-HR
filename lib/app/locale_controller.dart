import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/gen/app_localizations.dart';

/// App-wide locale state. Persisted in SharedPreferences ('app_locale').
/// null = follow device language (AR/EN supported, otherwise English).
class LocaleController {
  LocaleController._();

  static const supported = [Locale('en'), Locale('ar')];

  /// null means "not chosen yet — follow device".
  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static Future<void> load() async {
    final pref = await SharedPreferences.getInstance();
    final code = pref.getString('app_locale');
    if (code == 'ar' || code == 'en') {
      locale.value = Locale(code!);
    }
  }

  static Future<void> set(Locale newLocale) async {
    locale.value = newLocale;
    final pref = await SharedPreferences.getInstance();
    await pref.setString('app_locale', newLocale.languageCode);
  }

  static Future<void> toggle(BuildContext context) async {
    final current = currentCode(context);
    await set(Locale(current == 'ar' ? 'en' : 'ar'));
  }

  /// Effective language code right now ('en' or 'ar').
  static String currentCode(BuildContext context) {
    return locale.value?.languageCode ??
        Localizations.localeOf(context).languageCode;
  }

  static bool isArabic(BuildContext context) => currentCode(context) == 'ar';

  /// Odoo lang code for API calls, based on the persisted choice
  /// (usable outside the widget tree).
  static Future<String> odooLang() async {
    final pref = await SharedPreferences.getInstance();
    return (pref.getString('app_locale') ?? 'en') == 'ar' ? 'ar_001' : 'en_US';
  }
}

/// Shorthand: context.l10n.someKey
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
