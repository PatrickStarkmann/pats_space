import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/features/sounds/controllers/sound_controller.dart';
import 'package:pats_space/features/sounds/models/ambient_sound.dart';
import 'package:pats_space/features/sounds/models/sound_settings.dart';
import 'package:pats_space/features/sounds/repositories/sound_settings_repository.dart';
import 'package:pats_space/features/sounds/services/app_sound_player.dart';

void main() {
  group('SoundController', () {
    late _MemorySoundSettingsRepository repository;
    late _FakeSoundPlayer player;
    late SoundController controller;

    setUp(() {
      repository = _MemorySoundSettingsRepository();
      player = _FakeSoundPlayer();
      controller = SoundController(
        initialSettings: const SoundSettings(),
        repository: repository,
        player: player,
      );
    });

    tearDown(() => controller.dispose());

    test(
      'starts selected ambience only while focus playback is requested',
      () async {
        await controller.selectAmbientSound(AmbientSound.rain);

        expect(player.startedAmbience, isEmpty);

        await controller.syncFocusPlayback(shouldPlay: true);

        expect(player.startedAmbience, [AppAssets.ambienceRain]);
        expect(player.volume, 0.5);

        await controller.syncFocusPlayback(shouldPlay: false);
        expect(player.pauseCount, 1);

        await controller.syncFocusPlayback(shouldPlay: true);
        expect(player.resumeCount, 1);
        expect(player.startedAmbience, hasLength(1));
      },
    );

    test('switches ambience immediately during an active focus', () async {
      await controller.selectAmbientSound(AmbientSound.rain);
      await controller.syncFocusPlayback(shouldPlay: true);

      await controller.selectAmbientSound(AmbientSound.firewood);

      expect(player.startedAmbience, [
        AppAssets.ambienceRain,
        AppAssets.ambienceFirewood,
      ]);
      expect(repository.savedSettings.last.ambientSound, AmbientSound.firewood);
    });

    test('toggles the last selected ambience without losing it', () async {
      await controller.selectAmbientSound(AmbientSound.rainforest);
      await controller.syncFocusPlayback(shouldPlay: true);

      await controller.setAmbientSoundsEnabled(false);

      expect(controller.activeAmbientSound, AmbientSound.none);
      expect(controller.ambientSound, AmbientSound.rainforest);
      expect(player.stopCount, 2);

      await controller.setAmbientSoundsEnabled(true);

      expect(controller.activeAmbientSound, AmbientSound.rainforest);
      expect(player.startedAmbience.last, AppAssets.ambienceRainforest);
    });

    test('respects alert setting', () async {
      await controller.playFocusOrBreakEnd();
      await controller.playRoundEnd();

      expect(player.alerts, [AppAssets.alertBell, AppAssets.alertFinish]);

      await controller.setAlertSoundsEnabled(false);
      await controller.playFocusOrBreakEnd();

      expect(player.alerts, hasLength(2));
      expect(repository.savedSettings.last.alertSoundsEnabled, isFalse);
    });

    test('updates ambience volume and persists it', () async {
      await controller.setAmbientVolume(0.72);

      expect(controller.ambientVolume, 0.72);
      expect(player.volume, 0.72);
      expect(repository.savedSettings.last.ambientVolume, 0.72);
    });

    test(
      'turning volume to zero disables ambience but keeps selection',
      () async {
        await controller.selectAmbientSound(AmbientSound.rain);
        await controller.setAmbientVolume(0);

        expect(controller.ambientSoundsEnabled, isFalse);
        expect(controller.ambientSound, AmbientSound.rain);
        expect(controller.activeAmbientSound, AmbientSound.none);
      },
    );

    test(
      'restores the last audible volume when selecting after mute',
      () async {
        await controller.selectAmbientSound(AmbientSound.rain);
        await controller.setAmbientVolume(0.28);
        await controller.setAmbientVolume(0);

        expect(controller.lastAudibleVolume, 0.28);
        await controller.selectAmbientSound(AmbientSound.firewood);

        expect(controller.ambientVolume, 0.28);
        expect(controller.ambientSoundsEnabled, isTrue);
      },
    );

    test('persists the one-time long press hint', () async {
      await controller.markAmbientLongPressHintShown();

      expect(controller.ambientLongPressHintShown, isTrue);
      expect(repository.savedSettings.last.ambientLongPressHintShown, isTrue);
    });
  });
}

class _MemorySoundSettingsRepository implements SoundSettingsRepository {
  final List<SoundSettings> savedSettings = [];

  @override
  Future<SoundSettings> loadSettings() async => const SoundSettings();

  @override
  Future<void> saveSettings(SoundSettings settings) async {
    savedSettings.add(settings);
  }
}

class _FakeSoundPlayer implements AppSoundPlayer {
  final List<String> alerts = [];
  final List<String> startedAmbience = [];
  int pauseCount = 0;
  int resumeCount = 0;
  int stopCount = 0;
  double? volume;

  @override
  Future<void> playAlert(String assetPath) async {
    alerts.add(assetPath);
  }

  @override
  Future<void> startAmbience(String assetPath, {required double volume}) async {
    startedAmbience.add(assetPath);
    this.volume = volume;
  }

  @override
  Future<void> pauseAmbience() async {
    pauseCount += 1;
  }

  @override
  Future<void> resumeAmbience() async {
    resumeCount += 1;
  }

  @override
  Future<void> stopAmbience() async {
    stopCount += 1;
  }

  @override
  Future<void> setAmbienceVolume(double volume) async {
    this.volume = volume;
  }

  @override
  Future<void> dispose() async {}
}
