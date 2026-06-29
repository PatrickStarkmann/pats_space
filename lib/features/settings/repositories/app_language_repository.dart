import 'package:pats_space/features/settings/models/app_language.dart';

abstract class AppLanguageRepository {
  Future<AppLanguage> loadLanguage();

  Future<void> saveLanguage(AppLanguage language);
}
