import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';

enum GardenPlantType {
  daisy,
  tulip,
  clover,
  sunflower;

  static const plantable = [
    GardenPlantType.daisy,
    GardenPlantType.tulip,
    GardenPlantType.clover,
    GardenPlantType.sunflower,
  ];

  String get displayName => switch (this) {
    GardenPlantType.daisy => 'Daisy',
    GardenPlantType.tulip => 'Tulip',
    GardenPlantType.clover => 'Clover',
    GardenPlantType.sunflower => 'Sunflower',
  };

  int get coinReward => 5;

  String get specialLabel => switch (this) {
    GardenPlantType.daisy => 'Balanced starter',
    GardenPlantType.tulip => 'Elegant bloom',
    GardenPlantType.clover => 'Lucky harvest',
    GardenPlantType.sunflower => 'Big bloom',
  };

  int waterRequiredFor(GardenGrowthStage stage) {
    return switch ((this, stage)) {
      (GardenPlantType.clover, GardenGrowthStage.sprout) => 5,
      (_, GardenGrowthStage.empty) => 0,
      (_, GardenGrowthStage.seed) => 1,
      (_, GardenGrowthStage.sprout) => 2,
      (_, GardenGrowthStage.bud) => 3,
      (_, GardenGrowthStage.bloom) => 0,
      (_, GardenGrowthStage.dry) => 1,
    };
  }

  GardenGrowthStage nextStageAfter(GardenGrowthStage stage) {
    return switch ((this, stage)) {
      (GardenPlantType.clover, GardenGrowthStage.sprout) =>
        GardenGrowthStage.bloom,
      (_, GardenGrowthStage.empty) => GardenGrowthStage.seed,
      (_, GardenGrowthStage.seed) => GardenGrowthStage.sprout,
      (_, GardenGrowthStage.sprout) => GardenGrowthStage.bud,
      (_, GardenGrowthStage.bud) => GardenGrowthStage.bloom,
      (_, GardenGrowthStage.bloom) => GardenGrowthStage.dry,
      (_, GardenGrowthStage.dry) => GardenGrowthStage.bloom,
    };
  }

  String assetFor(GardenGrowthStage stage) {
    return switch (stage) {
      GardenGrowthStage.empty => previewAsset,
      GardenGrowthStage.seed => AppAssets.gardenPlantSeed,
      GardenGrowthStage.sprout => AppAssets.gardenPlantSprout,
      GardenGrowthStage.bud => AppAssets.gardenPlantBud,
      GardenGrowthStage.bloom => bloomAsset,
      GardenGrowthStage.dry => dryAsset,
    };
  }

  String get previewAsset => bloomAsset;

  String get bloomAsset => switch (this) {
    GardenPlantType.daisy => AppAssets.gardenPlantBloom,
    GardenPlantType.tulip => AppAssets.gardenTulipBloom,
    GardenPlantType.clover => AppAssets.gardenCloverBloom,
    GardenPlantType.sunflower => AppAssets.gardenSunflowerBloom,
  };

  String get dryAsset => switch (this) {
    GardenPlantType.daisy => AppAssets.gardenPlantDry,
    GardenPlantType.tulip => AppAssets.gardenTulipDry,
    GardenPlantType.clover => AppAssets.gardenCloverDry,
    GardenPlantType.sunflower => AppAssets.gardenSunflowerDry,
  };

  static GardenPlantType? fromStoredName(Object? value) {
    if (value is! String) {
      return null;
    }

    for (final type in values) {
      if (type.name == value) {
        return type;
      }
    }

    return switch (value.toLowerCase()) {
      'daisy' => GardenPlantType.daisy,
      'tulip' => GardenPlantType.tulip,
      'clover' => GardenPlantType.clover,
      'sunflower' => GardenPlantType.sunflower,
      _ => null,
    };
  }
}
