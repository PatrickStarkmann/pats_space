import 'package:pats_space/core/assets/app_assets.dart';

enum AmbientSound {
  none,
  firewood,
  rain,
  rainforest;

  String? get assetPath => switch (this) {
    AmbientSound.none => null,
    AmbientSound.firewood => AppAssets.ambienceFirewood,
    AmbientSound.rain => AppAssets.ambienceRain,
    AmbientSound.rainforest => AppAssets.ambienceRainforest,
  };

  static AmbientSound fromStoredName(String? name) {
    return AmbientSound.values
            .where((sound) => sound.name == name)
            .firstOrNull ??
        AmbientSound.none;
  }
}
