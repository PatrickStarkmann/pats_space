import 'package:flutter/widgets.dart';

enum AppLanguage {
  system,
  english,
  german;

  Locale? get locale {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.english => const Locale('en'),
      AppLanguage.german => const Locale('de'),
    };
  }

  static AppLanguage fromCode(String? code) {
    return switch (code) {
      'en' => AppLanguage.english,
      'de' => AppLanguage.german,
      _ => AppLanguage.system,
    };
  }

  String? get storageCode {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.english => 'en',
      AppLanguage.german => 'de',
    };
  }
}
