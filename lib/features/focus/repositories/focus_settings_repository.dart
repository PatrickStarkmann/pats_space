import 'package:pats_space/features/focus/models/focus_timer_settings.dart';

abstract class FocusSettingsRepository {
  Future<FocusTimerSettings?> loadSettings();

  Future<void> saveSettings(FocusTimerSettings settings);
}
