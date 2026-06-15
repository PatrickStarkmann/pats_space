import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';

class GardenPot {
  const GardenPot({
    required this.stage,
    required this.plantType,
    required this.coinReward,
    required this.waterProgress,
    required this.bloomCollections,
  });

  const GardenPot.empty()
    : stage = GardenGrowthStage.empty,
      plantType = GardenPlantType.daisy,
      coinReward = 5,
      waterProgress = 0,
      bloomCollections = 0;

  final GardenGrowthStage stage;
  final GardenPlantType plantType;
  final int coinReward;
  final int waterProgress;
  final int bloomCollections;

  bool get isEmpty => stage.isEmpty;
  String get plantName => plantType.displayName;
  String get plantAsset => plantType.assetFor(stage);
  int get waterRequired => plantType.waterRequiredFor(stage);
  GardenGrowthStage get nextStage => plantType.nextStageAfter(stage);
  int get remainingWater =>
      (waterRequired - waterProgress).clamp(0, waterRequired);
  bool get isReadyToGrow => stage.needsWater && remainingWater == 0;
  int get remainingBloomCollections => (3 - bloomCollections).clamp(0, 3);

  GardenPot copyWith({
    GardenGrowthStage? stage,
    GardenPlantType? plantType,
    int? coinReward,
    int? waterProgress,
    int? bloomCollections,
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
    );
  }
}
