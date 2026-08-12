import 'package:pats_space/features/notifications/models/notification_settings.dart';
import 'package:pats_space/features/notifications/repositories/notification_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesNotificationSettingsRepository
    implements NotificationSettingsRepository {
  const SharedPreferencesNotificationSettingsRepository(this._preferences);

  static const _enabledKey = 'notification_settings.enabled.v1';
  static const _focusEndEnabledKey =
      'notification_settings.focus_end_enabled.v1';
  static const _breakEndEnabledKey =
      'notification_settings.break_end_enabled.v1';

  final SharedPreferences _preferences;

  @override
  Future<NotificationSettings> loadSettings() async {
    return NotificationSettings(
      enabled: _preferences.getBool(_enabledKey) ?? false,
      focusEndEnabled: _preferences.getBool(_focusEndEnabledKey) ?? true,
      breakEndEnabled: _preferences.getBool(_breakEndEnabledKey) ?? true,
    );
  }

  @override
  Future<void> saveSettings(NotificationSettings settings) async {
    await Future.wait([
      _preferences.setBool(_enabledKey, settings.enabled),
      _preferences.setBool(_focusEndEnabledKey, settings.focusEndEnabled),
      _preferences.setBool(_breakEndEnabledKey, settings.breakEndEnabled),
    ]);
  }
}
