import 'package:flutter/cupertino.dart';

enum GardenGrowthStage {
  empty,
  seed,
  sprout,
  bud,
  bloom,
  dry;

  bool get isEmpty => this == GardenGrowthStage.empty;

  bool get isDry => this == GardenGrowthStage.dry;

  bool get needsWater =>
      this == GardenGrowthStage.seed ||
      this == GardenGrowthStage.sprout ||
      this == GardenGrowthStage.bud ||
      this == GardenGrowthStage.dry;

  bool get hasCoins => this == GardenGrowthStage.bloom;

  int get waterRequired => switch (this) {
    GardenGrowthStage.empty => 0,
    GardenGrowthStage.seed => 1,
    GardenGrowthStage.sprout => 2,
    GardenGrowthStage.bud => 3,
    GardenGrowthStage.bloom => 0,
    GardenGrowthStage.dry => 1,
  };

  String get statusLabel => switch (this) {
    GardenGrowthStage.empty => 'Empty pot',
    GardenGrowthStage.seed => 'Seed planted',
    GardenGrowthStage.sprout => 'Needs water',
    GardenGrowthStage.bud => 'Growing',
    GardenGrowthStage.bloom => 'Blooming',
    GardenGrowthStage.dry => 'Dried out',
  };

  IconData get actionIcon => switch (this) {
    GardenGrowthStage.empty => CupertinoIcons.plus,
    GardenGrowthStage.seed ||
    GardenGrowthStage.sprout ||
    GardenGrowthStage.bud ||
    GardenGrowthStage.dry => CupertinoIcons.drop,
    GardenGrowthStage.bloom => CupertinoIcons.bitcoin_circle,
  };

  GardenGrowthStage get next => switch (this) {
    GardenGrowthStage.empty => GardenGrowthStage.seed,
    GardenGrowthStage.seed => GardenGrowthStage.sprout,
    GardenGrowthStage.sprout => GardenGrowthStage.bud,
    GardenGrowthStage.bud => GardenGrowthStage.bloom,
    GardenGrowthStage.bloom => GardenGrowthStage.dry,
    GardenGrowthStage.dry => GardenGrowthStage.bloom,
  };
}
