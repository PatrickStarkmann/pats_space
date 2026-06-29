import 'package:pats_space/features/settings/models/app_language.dart';
import 'package:pats_space/features/settings/repositories/app_language_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAppLanguageRepository implements AppLanguageRepository {
  const SharedPreferencesAppLanguageRepository(this._preferences);

  static const _languageKey = 'app_language';

  final SharedPreferences _preferences;

  @override
  Future<AppLanguage> loadLanguage() async {
    return AppLanguage.fromCode(_preferences.getString(_languageKey));
  }

  @override
  Future<void> saveLanguage(AppLanguage language) {
    final storageCode = language.storageCode;
    if (storageCode == null) {
      return _preferences.remove(_languageKey);
    }

    return _preferences.setString(_languageKey, storageCode);
  }
}
