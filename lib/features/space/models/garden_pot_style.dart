import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';

enum GardenPotStyle {
  classic,
  blue,
  colorful,
  hanging,
  round,
  white;

  static const shopStyles = [
    GardenPotStyle.blue,
    GardenPotStyle.colorful,
    GardenPotStyle.round,
    GardenPotStyle.white,
  ];

  static const initiallyOwned = {GardenPotStyle.classic};

  String get displayName => switch (this) {
    GardenPotStyle.classic => 'Classic',
    GardenPotStyle.blue => 'Blue pot',
    GardenPotStyle.colorful => 'Colorful pot',
    GardenPotStyle.hanging => 'Hanging pot',
    GardenPotStyle.round => 'Round pot',
    GardenPotStyle.white => 'White pot',
  };

  int get cost => switch (this) {
    GardenPotStyle.classic => 0,
    GardenPotStyle.blue => 120,
    GardenPotStyle.colorful => 180,
    GardenPotStyle.hanging => 220,
    GardenPotStyle.round => 150,
    GardenPotStyle.white => 160,
  };

  String get assetPath => switch (this) {
    GardenPotStyle.classic => AppAssets.gardenPotDefault,
    GardenPotStyle.blue => AppAssets.gardenPotBlue,
    GardenPotStyle.colorful => AppAssets.gardenPotColorful,
    GardenPotStyle.hanging => AppAssets.gardenPotHanging,
    GardenPotStyle.round => AppAssets.gardenPotRound,
    GardenPotStyle.white => AppAssets.gardenPotWhite,
  };

  String get noShadowAssetPath => switch (this) {
    GardenPotStyle.classic => AppAssets.gardenPotDefaultNoShadow,
    GardenPotStyle.blue => AppAssets.gardenPotBlueNoShadow,
    GardenPotStyle.colorful => AppAssets.gardenPotColorfulNoShadow,
    GardenPotStyle.hanging => AppAssets.gardenPotHanging,
    GardenPotStyle.round => AppAssets.gardenPotRoundNoShadow,
    GardenPotStyle.white => AppAssets.gardenPotWhiteNoShadow,
  };

  double get renderOffsetYFactor => switch (this) {
    GardenPotStyle.round => .08,
    _ => 0,
  };

  double plantSizeFactorFor(GardenGrowthStage stage) {
    final base = switch (stage) {
      GardenGrowthStage.seed => .24,
      GardenGrowthStage.sprout => .58,
      GardenGrowthStage.bud => .7,
      GardenGrowthStage.bloom => .82,
      GardenGrowthStage.dry => .72,
      GardenGrowthStage.empty => 0.0,
    };

    return switch (this) {
      GardenPotStyle.round => base * .94,
      GardenPotStyle.colorful => base * .96,
      GardenPotStyle.hanging => base * .73,
      _ => base,
    };
  }

  double plantBottomFactorFor(GardenGrowthStage stage) {
    final base = switch (stage) {
      GardenGrowthStage.seed => .58,
      GardenGrowthStage.sprout => .58,
      GardenGrowthStage.bud => .6,
      GardenGrowthStage.bloom => .62,
      GardenGrowthStage.dry => .6,
      GardenGrowthStage.empty => 0.0,
    };

    return switch (this) {
      GardenPotStyle.round => base - .13,
      GardenPotStyle.hanging => base - .28,
      GardenPotStyle.colorful => base - .04,
      GardenPotStyle.blue => base - .02,
      GardenPotStyle.white => base - .02,
      _ => base,
    };
  }

  static GardenPotStyle? fromStoredName(Object? value) {
    if (value is! String) {
      return null;
    }

    for (final style in values) {
      if (style.name == value) {
        return style;
      }
    }
    return null;
  }
}
