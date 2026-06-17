import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';

class GardenPot {
  const GardenPot({
    required this.stage,
    required this.plantType,
    required this.coinReward,
    required this.waterProgress,
    required this.bloomCollections,
    required this.bloomCharges,
    required this.lastBloomChargeAtMillis,
  });

  const GardenPot.empty()
    : stage = GardenGrowthStage.empty,
      plantType = GardenPlantType.daisy,
      coinReward = 5,
      waterProgress = 0,
      bloomCollections = 0,
      bloomCharges = 0,
      lastBloomChargeAtMillis = null;

  final GardenGrowthStage stage;
  final GardenPlantType plantType;
  final int coinReward;
  final int waterProgress;
  final int bloomCollections;
  final int bloomCharges;
  final int? lastBloomChargeAtMillis;

  bool get isEmpty => stage.isEmpty;
  String get plantName => plantType.displayName;
  String get plantAsset => plantType.assetFor(stage);
  int get waterRequired => plantType.waterRequiredFor(stage);
  GardenGrowthStage get nextStage => plantType.nextStageAfter(stage);
  int get remainingWater =>
      (waterRequired - waterProgress).clamp(0, waterRequired);
  bool get isReadyToGrow => stage.needsWater && remainingWater == 0;
  bool get hasCollectableCoins => stage.hasCoins && bloomCharges > 0;
  int get remainingBloomCollections => (3 - bloomCollections).clamp(0, 3);

  Duration remainingCoinDropTime(Duration interval, DateTime now) {
    if (!stage.hasCoins || hasCollectableCoins) {
      return Duration.zero;
    }

    final lastChargeAt = lastBloomChargeAtMillis;
    if (lastChargeAt == null) {
      return Duration.zero;
    }

    final elapsed = now.difference(
      DateTime.fromMillisecondsSinceEpoch(lastChargeAt),
    );
    final remaining = interval - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  GardenPot copyWith({
    GardenGrowthStage? stage,
    GardenPlantType? plantType,
    int? coinReward,
    int? waterProgress,
    int? bloomCollections,
    int? bloomCharges,
    int? lastBloomChargeAtMillis,
    bool clearLastBloomChargeAt = false,
  }) {
    final resolvedPlantType = plantType ?? this.plantType;

    return GardenPot(
      stage: stage ?? this.stage,
      plantType: resolvedPlantType,
      coinReward:
          coinReward ??
          (plantType == null ? this.coinReward : resolvedPlantType.coinReward),
      waterProgress: waterProgress ?? this.waterProgress,
      bloomCollections: bloomCollections ?? this.bloomCollections,
      bloomCharges: bloomCharges ?? this.bloomCharges,
      lastBloomChargeAtMillis: clearLastBloomChargeAt
          ? null
          : lastBloomChargeAtMillis ?? this.lastBloomChargeAtMillis,
    );
  }
}
