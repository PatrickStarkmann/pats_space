import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/notifications/models/notification_settings.dart';
import 'package:pats_space/features/notifications/repositories/shared_preferences_notification_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists notification settings', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesNotificationSettingsRepository(
      preferences,
    );
    const settings = NotificationSettings(
      enabled: true,
      focusEndEnabled: false,
      breakEndEnabled: true,
    );

    await repository.saveSettings(settings);

    expect(await repository.loadSettings(), settings);
  });

  test('uses opt-in defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesNotificationSettingsRepository(
      preferences,
    );

    expect(await repository.loadSettings(), const NotificationSettings());
  });
}
