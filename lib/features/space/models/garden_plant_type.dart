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

  int get coinReward => switch (this) {
    GardenPlantType.daisy => 5,
    GardenPlantType.tulip => 8,
    GardenPlantType.clover => 5,
    GardenPlantType.sunflower => 14,
  };

  Duration get coinDropInterval => switch (this) {
    GardenPlantType.daisy => const Duration(hours: 8),
    GardenPlantType.tulip => const Duration(hours: 10),
    GardenPlantType.clover => const Duration(hours: 8),
    GardenPlantType.sunflower => const Duration(hours: 12),
  };

  String get coinDropIntervalLabel => switch (this) {
    GardenPlantType.daisy => '8h',
    GardenPlantType.tulip => '10h',
    GardenPlantType.clover => '8h',
    GardenPlantType.sunflower => '12h',
  };

  int get plantCost => switch (this) {
    GardenPlantType.daisy => 1,
    GardenPlantType.tulip => 2,
    GardenPlantType.clover => 2,
    GardenPlantType.sunflower => 3,
  };

  String get specialLabel => switch (this) {
    GardenPlantType.daisy => 'Starter',
    GardenPlantType.tulip => 'Bonus',
    GardenPlantType.clover => 'Lucky',
    GardenPlantType.sunflower => 'Jackpot',
  };

  String get specialDescription => switch (this) {
    GardenPlantType.daisy => '',
    GardenPlantType.tulip => 'More coins, slower drops',
    GardenPlantType.clover => '20% chance for double coins',
    GardenPlantType.sunflower => 'Biggest payout, slowest drop',
  };

  int waterRequiredFor(GardenGrowthStage stage) {
    return switch ((this, stage)) {
      (_, GardenGrowthStage.empty) => 0,
      (GardenPlantType.daisy, GardenGrowthStage.seed) => 5,
      (GardenPlantType.daisy, GardenGrowthStage.sprout) => 8,
      (GardenPlantType.daisy, GardenGrowthStage.bud) => 12,
      (GardenPlantType.daisy, GardenGrowthStage.dry) => 5,
      (GardenPlantType.tulip, GardenGrowthStage.seed) => 6,
      (GardenPlantType.tulip, GardenGrowthStage.sprout) => 10,
      (GardenPlantType.tulip, GardenGrowthStage.bud) => 15,
      (GardenPlantType.tulip, GardenGrowthStage.dry) => 6,
      (GardenPlantType.clover, GardenGrowthStage.seed) => 7,
      (GardenPlantType.clover, GardenGrowthStage.sprout) => 14,
      (GardenPlantType.clover, GardenGrowthStage.dry) => 7,
      (GardenPlantType.sunflower, GardenGrowthStage.seed) => 8,
      (GardenPlantType.sunflower, GardenGrowthStage.sprout) => 14,
      (GardenPlantType.sunflower, GardenGrowthStage.bud) => 20,
      (GardenPlantType.sunflower, GardenGrowthStage.dry) => 8,
      (_, GardenGrowthStage.bloom) => 0,
      (_, _) => 0,
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
