import 'package:pats_space/features/sounds/models/ambient_sound.dart';
import 'package:pats_space/features/sounds/models/sound_settings.dart';
import 'package:pats_space/features/sounds/repositories/sound_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSoundSettingsRepository
    implements SoundSettingsRepository {
  const SharedPreferencesSoundSettingsRepository(this._preferences);

  static const _alertSoundsEnabledKey =
      'sound_settings.alert_sounds_enabled.v1';
  static const _ambientSoundKey = 'sound_settings.ambient_sound.v1';
  static const _ambientSoundsEnabledKey =
      'sound_settings.ambient_sounds_enabled.v1';
  static const _ambientVolumeKey = 'sound_settings.ambient_volume.v1';
  static const _lastAudibleVolumeKey = 'sound_settings.last_audible_volume.v1';
  static const _ambientLongPressHintShownKey =
      'sound_settings.ambient_long_press_hint_shown.v1';

  final SharedPreferences _preferences;

  @override
  Future<SoundSettings> loadSettings() async {
    final ambientSound = AmbientSound.fromStoredName(
      _preferences.getString(_ambientSoundKey),
    );
    final ambientVolume = (_preferences.getDouble(_ambientVolumeKey) ?? 0.5)
        .clamp(0.0, 1.0);
    final lastAudibleVolume =
        (_preferences.getDouble(_lastAudibleVolumeKey) ??
                (ambientVolume > 0 ? ambientVolume : 0.5))
            .clamp(0.01, 1.0);
    return SoundSettings(
      alertSoundsEnabled: _preferences.getBool(_alertSoundsEnabledKey) ?? true,
      ambientSound: ambientSound,
      ambientSoundsEnabled:
          _preferences.getBool(_ambientSoundsEnabledKey) ??
          (ambientSound != AmbientSound.none && ambientVolume > 0),
      ambientVolume: ambientVolume,
      lastAudibleVolume: lastAudibleVolume,
      ambientLongPressHintShown:
          _preferences.getBool(_ambientLongPressHintShownKey) ?? false,
    );
  }

  @override
  Future<void> saveSettings(SoundSettings settings) async {
    await Future.wait([
      _preferences.setBool(_alertSoundsEnabledKey, settings.alertSoundsEnabled),
      _preferences.setString(_ambientSoundKey, settings.ambientSound.name),
      _preferences.setBool(
        _ambientSoundsEnabledKey,
        settings.ambientSoundsEnabled,
      ),
      _preferences.setDouble(_ambientVolumeKey, settings.ambientVolume),
      _preferences.setDouble(_lastAudibleVolumeKey, settings.lastAudibleVolume),
      _preferences.setBool(
        _ambientLongPressHintShownKey,
        settings.ambientLongPressHintShown,
      ),
    ]);
  }
}
