import 'package:pats_space/features/sounds/models/sound_settings.dart';

abstract interface class SoundSettingsRepository {
  Future<SoundSettings> loadSettings();

  Future<void> saveSettings(SoundSettings settings);
}
