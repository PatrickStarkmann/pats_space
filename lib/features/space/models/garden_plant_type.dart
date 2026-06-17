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

  static const initiallyUnlocked = {GardenPlantType.daisy};

  String get displayName => switch (this) {
    GardenPlantType.daisy => 'Daisy',
    GardenPlantType.tulip => 'Tulip',
    GardenPlantType.clover => 'Clover',
    GardenPlantType.sunflower => 'Sunflower',
  };

  GardenPlantType? get nextUnlock => switch (this) {
    GardenPlantType.daisy => GardenPlantType.tulip,
    GardenPlantType.tulip => GardenPlantType.clover,
    GardenPlantType.clover => GardenPlantType.sunflower,
    GardenPlantType.sunflower => null,
  };

  GardenPlantType? get unlockRequirement => switch (this) {
    GardenPlantType.daisy => null,
    GardenPlantType.tulip => GardenPlantType.daisy,
    GardenPlantType.clover => GardenPlantType.tulip,
    GardenPlantType.sunflower => GardenPlantType.clover,
  };

  String get unlockRequirementLabel {
    final requirement = unlockRequirement;
    if (requirement == null) {
      return 'Unlocked';
    }

    return 'Bloom ${requirement.displayName}';
  }

  GardenPlantBalance get balance => switch (this) {
    GardenPlantType.daisy => const GardenPlantBalance(
      coinReward: 5,
      coinDropInterval: Duration(hours: 8),
      plantCost: 1,
      seedWater: 3,
      sproutWater: 5,
      budWater: 8,
      dryWater: 4,
    ),
    GardenPlantType.tulip => const GardenPlantBalance(
      coinReward: 8,
      coinDropInterval: Duration(hours: 10),
      plantCost: 2,
      seedWater: 5,
      sproutWater: 8,
      budWater: 13,
      dryWater: 5,
    ),
    GardenPlantType.clover => const GardenPlantBalance(
      coinReward: 5,
      coinDropInterval: Duration(hours: 8),
      plantCost: 2,
      seedWater: 6,
      sproutWater: 12,
      dryWater: 6,
    ),
    GardenPlantType.sunflower => const GardenPlantBalance(
      coinReward: 14,
      coinDropInterval: Duration(hours: 12),
      plantCost: 3,
      seedWater: 7,
      sproutWater: 12,
      budWater: 18,
      dryWater: 7,
    ),
  };

  int get coinReward => balance.coinReward;

  Duration get coinDropInterval => balance.coinDropInterval;

  String get coinDropIntervalLabel => switch (this) {
    GardenPlantType.daisy => '8h',
    GardenPlantType.tulip => '10h',
    GardenPlantType.clover => '8h',
    GardenPlantType.sunflower => '12h',
  };

  int get plantCost => balance.plantCost;

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
    return balance.waterRequiredFor(stage);
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

class GardenPlantBalance {
  const GardenPlantBalance({
    required this.coinReward,
    required this.coinDropInterval,
    required this.plantCost,
    required this.seedWater,
    required this.sproutWater,
    this.budWater = 0,
    required this.dryWater,
  });

  final int coinReward;
  final Duration coinDropInterval;
  final int plantCost;
  final int seedWater;
  final int sproutWater;
  final int budWater;
  final int dryWater;

  int get waterToBloom => seedWater + sproutWater + budWater;
  int get totalWaterToFirstBloom => plantCost + waterToBloom;

  int waterRequiredFor(GardenGrowthStage stage) {
    return switch (stage) {
      GardenGrowthStage.seed => seedWater,
      GardenGrowthStage.sprout => sproutWater,
      GardenGrowthStage.bud => budWater,
      GardenGrowthStage.dry => dryWater,
      GardenGrowthStage.empty || GardenGrowthStage.bloom => 0,
    };
  }
}
