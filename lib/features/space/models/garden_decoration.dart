import 'package:pats_space/core/assets/app_assets.dart';

enum GardenDecoration {
  bench,
  fountain,
  hangingPlantFrame,
  hangingPot,
  lantern,
  stonePath,
  wateringCan;

  static const shopDecorations = [
    GardenDecoration.bench,
    GardenDecoration.lantern,
    GardenDecoration.wateringCan,
    GardenDecoration.fountain,
    GardenDecoration.stonePath,
  ];

  String get displayName => switch (this) {
    GardenDecoration.bench => 'Garden bench',
    GardenDecoration.fountain => 'Fountain',
    GardenDecoration.hangingPlantFrame => 'Plant frame',
    GardenDecoration.hangingPot => 'Hanging pot',
    GardenDecoration.lantern => 'Lantern',
    GardenDecoration.stonePath => 'Stone path',
    GardenDecoration.wateringCan => 'Watering can',
  };

  int get cost => switch (this) {
    GardenDecoration.bench => 180,
    GardenDecoration.fountain => 260,
    GardenDecoration.hangingPlantFrame => 240,
    GardenDecoration.hangingPot => 220,
    GardenDecoration.lantern => 140,
    GardenDecoration.stonePath => 90,
    GardenDecoration.wateringCan => 120,
  };

  String get assetPath => switch (this) {
    GardenDecoration.bench => AppAssets.gardenDecorBench,
    GardenDecoration.fountain => AppAssets.gardenDecorFountain,
    GardenDecoration.hangingPlantFrame =>
      AppAssets.gardenDecorHangingPlantFrame,
    GardenDecoration.hangingPot => AppAssets.gardenPotHanging,
    GardenDecoration.lantern => AppAssets.gardenDecorLantern,
    GardenDecoration.stonePath => AppAssets.gardenDecorStonePath,
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
