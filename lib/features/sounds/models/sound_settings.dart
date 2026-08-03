import 'package:pats_space/features/sounds/models/ambient_sound.dart';

class SoundSettings {
  const SoundSettings({
    this.alertSoundsEnabled = true,
    this.ambientSound = AmbientSound.none,
    this.ambientSoundsEnabled = false,
    this.ambientVolume = 0.5,
    this.lastAudibleVolume = 0.5,
    this.ambientLongPressHintShown = false,
  });

  final bool alertSoundsEnabled;
  final AmbientSound ambientSound;
  final bool ambientSoundsEnabled;
  final double ambientVolume;
  final double lastAudibleVolume;
  final bool ambientLongPressHintShown;

  SoundSettings copyWith({
    bool? alertSoundsEnabled,
    AmbientSound? ambientSound,
    bool? ambientSoundsEnabled,
    double? ambientVolume,
    double? lastAudibleVolume,
    bool? ambientLongPressHintShown,
  }) {
    return SoundSettings(
      alertSoundsEnabled: alertSoundsEnabled ?? this.alertSoundsEnabled,
      ambientSound: ambientSound ?? this.ambientSound,
      ambientSoundsEnabled: ambientSoundsEnabled ?? this.ambientSoundsEnabled,
      ambientVolume: ambientVolume ?? this.ambientVolume,
      lastAudibleVolume: lastAudibleVolume ?? this.lastAudibleVolume,
      ambientLongPressHintShown:
          ambientLongPressHintShown ?? this.ambientLongPressHintShown,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SoundSettings &&
        other.alertSoundsEnabled == alertSoundsEnabled &&
        other.ambientSound == ambientSound &&
        other.ambientSoundsEnabled == ambientSoundsEnabled &&
        other.ambientVolume == ambientVolume &&
        other.lastAudibleVolume == lastAudibleVolume &&
        other.ambientLongPressHintShown == ambientLongPressHintShown;
  }

  @override
  int get hashCode => Object.hash(
    alertSoundsEnabled,
    ambientSound,
    ambientSoundsEnabled,
    ambientVolume,
    lastAudibleVolume,
    ambientLongPressHintShown,
  );
}
