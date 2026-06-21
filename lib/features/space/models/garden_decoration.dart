import 'package:pats_space/core/assets/app_assets.dart';

enum GardenDecoration {
  bench,
  hangingPlantFrame,
  hangingPot,
  lantern,
  wateringCan;

  static const shopDecorations = [
    GardenDecoration.bench,
    GardenDecoration.lantern,
    GardenDecoration.wateringCan,
  ];

  String get displayName => switch (this) {
    GardenDecoration.bench => 'Garden bench',
    GardenDecoration.hangingPlantFrame => 'Plant frame',
    GardenDecoration.hangingPot => 'Hanging pot',
    GardenDecoration.lantern => 'Lantern',
    GardenDecoration.wateringCan => 'Watering can',
  };

  int get cost => switch (this) {
    GardenDecoration.bench => 180,
    GardenDecoration.hangingPlantFrame => 240,
    GardenDecoration.hangingPot => 220,
    GardenDecoration.lantern => 140,
    GardenDecoration.wateringCan => 120,
  };

  String get assetPath => switch (this) {
    GardenDecoration.bench => AppAssets.gardenDecorBench,
    GardenDecoration.hangingPlantFrame =>
      AppAssets.gardenDecorHangingPlantFrame,
    GardenDecoration.hangingPot => AppAssets.gardenPotHanging,
    GardenDecoration.lantern => AppAssets.gardenDecorLantern,
    GardenDecoration.wateringCan => AppAssets.gardenDecorWateringCan,
  };

  GardenDecoration? get requirement => switch (this) {
    GardenDecoration.hangingPot => GardenDecoration.hangingPlantFrame,
    _ => null,
  };

  static GardenDecoration? fromStoredName(Object? value) {
    if (value is! String) {
      return null;
    }

    for (final decoration in values) {
      if (decoration.name == value) {
        return decoration;
      }
    }
    return null;
  }
}
