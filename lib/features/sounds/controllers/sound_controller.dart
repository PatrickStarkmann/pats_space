import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/features/sounds/models/ambient_sound.dart';
import 'package:pats_space/features/sounds/models/sound_settings.dart';
import 'package:pats_space/features/sounds/repositories/sound_settings_repository.dart';
import 'package:pats_space/features/sounds/services/app_sound_player.dart';

class SoundController extends ChangeNotifier {
  SoundController({
    required SoundSettings initialSettings,
    required SoundSettingsRepository repository,
    required AppSoundPlayer player,
  }) : _settings = initialSettings,
       _repository = repository,
       _player = player;

  final SoundSettingsRepository _repository;
  final AppSoundPlayer _player;

  SoundSettings _settings;
  bool _focusPlaybackRequested = false;
  String? _loadedAmbienceAsset;
  bool _ambiencePaused = false;
  int _playbackRevision = 0;

  SoundSettings get settings => _settings;
  bool get alertSoundsEnabled => _settings.alertSoundsEnabled;
  AmbientSound get ambientSound => _settings.ambientSound;
  AmbientSound get activeAmbientSound =>
      ambientSoundsEnabled ? ambientSound : AmbientSound.none;
  bool get ambientSoundsEnabled =>
      _settings.ambientSoundsEnabled &&
      ambientSound != AmbientSound.none &&
      ambientVolume > 0;
  bool get hasAmbientSoundSelection => ambientSound != AmbientSound.none;
  double get ambientVolume => _settings.ambientVolume;
  double get lastAudibleVolume => _settings.lastAudibleVolume;
  bool get ambientLongPressHintShown => _settings.ambientLongPressHintShown;
  bool get hasAnySoundEnabled => alertSoundsEnabled || ambientSoundsEnabled;

  Future<void> setAlertSoundsEnabled(bool enabled) async {
    if (_settings.alertSoundsEnabled == enabled) {
      return;
    }
    _settings = _settings.copyWith(alertSoundsEnabled: enabled);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> selectAmbientSound(AmbientSound sound) async {
    if (activeAmbientSound == sound) {
      return;
    }
    _settings = sound == AmbientSound.none
        ? _settings.copyWith(ambientSoundsEnabled: false)
        : _settings.copyWith(
            ambientSound: sound,
            ambientSoundsEnabled: true,
            ambientVolume: _audibleVolume,
          );
    notifyListeners();
    await Future.wait([_saveSettings(), _syncAmbience(forceRestart: true)]);
  }

  Future<void> setAmbientSoundsEnabled(bool enabled) async {
    final nextEnabled = enabled && hasAmbientSoundSelection;
    final nextSettings = _settings.copyWith(
      ambientSoundsEnabled: nextEnabled,
      ambientVolume: nextEnabled ? _audibleVolume : _settings.ambientVolume,
    );
    if (_settings == nextSettings) {
      return;
    }
    _settings = nextSettings;
    notifyListeners();
    await Future.wait([_saveSettings(), _syncAmbience(forceRestart: true)]);
  }

  Future<void> markAmbientLongPressHintShown() async {
    if (_settings.ambientLongPressHintShown) {
      return;
    }
    _settings = _settings.copyWith(ambientLongPressHintShown: true);
    await _saveSettings();
  }

  Future<void> setAmbientVolume(double volume) async {
    final normalizedVolume = volume.clamp(0.0, 1.0);
    final nextSettings = _settings.copyWith(
      ambientVolume: normalizedVolume,
      lastAudibleVolume: normalizedVolume > 0
          ? normalizedVolume
          : _settings.lastAudibleVolume,
      ambientSoundsEnabled: normalizedVolume == 0
          ? false
          : (hasAmbientSoundSelection ? true : _settings.ambientSoundsEnabled),
    );
    if (_settings == nextSettings) {
      return;
    }
    _settings = nextSettings;
    notifyListeners();
    await Future.wait([
      _saveSettings(),
      _syncAmbience(forceRestart: normalizedVolume == 0),
      _guardPlayerAction(() => _player.setAmbienceVolume(normalizedVolume)),
    ]);
  }

  double get _audibleVolume {
    final previousVolume = _settings.lastAudibleVolume;
    return previousVolume > 0 ? previousVolume : 0.5;
  }

  Future<void> syncFocusPlayback({required bool shouldPlay}) async {
    if (_focusPlaybackRequested == shouldPlay) {
      return;
    }
    _focusPlaybackRequested = shouldPlay;
    await _syncAmbience();
  }

  Future<void> playFocusOrBreakEnd() {
    return _playAlert(AppAssets.alertBell);
  }

  Future<void> playRoundEnd() {
    return _playAlert(AppAssets.alertFinish);
  }

  @override
  void dispose() {
    _playbackRevision += 1;
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _syncAmbience({bool forceRestart = false}) async {
    final revision = ++_playbackRevision;
    final assetPath = activeAmbientSound.assetPath;

    if (!_focusPlaybackRequested || assetPath == null) {
      if (assetPath == null || forceRestart) {
        _loadedAmbienceAsset = null;
        _ambiencePaused = false;
        await _guardPlayerAction(_player.stopAmbience);
      } else if (!_ambiencePaused) {
        _ambiencePaused = true;
        await _guardPlayerAction(_player.pauseAmbience);
      }
      return;
    }

    if (!forceRestart && _loadedAmbienceAsset == assetPath && _ambiencePaused) {
      _ambiencePaused = false;
      await _guardPlayerAction(_player.resumeAmbience);
      return;
    }

    if (!forceRestart &&
        _loadedAmbienceAsset == assetPath &&
        !_ambiencePaused) {
      return;
    }

    await _guardPlayerAction(
      () => _player.startAmbience(assetPath, volume: _settings.ambientVolume),
    );
    if (revision != _playbackRevision) {
      return;
    }
    _loadedAmbienceAsset = assetPath;
    _ambiencePaused = false;
  }

  Future<void> _playAlert(String assetPath) async {
    if (!_settings.alertSoundsEnabled) {
      return;
    }
    await _guardPlayerAction(() => _player.playAlert(assetPath));
  }

  Future<void> _saveSettings() async {
    try {
      await _repository.saveSettings(_settings);
    } catch (_) {
      // Audio preferences should never interrupt an active focus session.
    }
  }

  Future<void> _guardPlayerAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Missing audio output or a transient platform error should fail quietly.
    }
  }
}
