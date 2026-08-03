import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/sounds/models/ambient_sound.dart';
import 'package:pats_space/features/sounds/models/sound_settings.dart';
import 'package:pats_space/features/sounds/repositories/shared_preferences_sound_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists sound settings', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesSoundSettingsRepository(preferences);
    const settings = SoundSettings(
      alertSoundsEnabled: false,
      ambientSound: AmbientSound.rainforest,
      ambientSoundsEnabled: true,
      ambientVolume: 0.64,
      lastAudibleVolume: 0.64,
      ambientLongPressHintShown: true,
    );

    await repository.saveSettings(settings);

    expect(await repository.loadSettings(), settings);
  });

  test('keeps migrated ambient selections enabled', () async {
    SharedPreferences.setMockInitialValues({
      'sound_settings.ambient_sound.v1': AmbientSound.rain.name,
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesSoundSettingsRepository(preferences);

    final settings = await repository.loadSettings();

    expect(settings.ambientSound, AmbientSound.rain);
    expect(settings.ambientSoundsEnabled, isTrue);
  });

  test('uses quiet defaults for ambience and enabled timer signals', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesSoundSettingsRepository(preferences);

    expect(await repository.loadSettings(), const SoundSettings());
  });
}
