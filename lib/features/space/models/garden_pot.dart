import 'package:pats_space/features/space/models/garden_growth_stage.dart';

class GardenPot {
  const GardenPot({
    required this.stage,
    required this.plantName,
    required this.coinReward,
    required this.waterProgress,
    required this.bloomCollections,
  });

  const GardenPot.empty()
    : stage = GardenGrowthStage.empty,
      plantName = 'Daisy',
      coinReward = 5,
      waterProgress = 0,
      bloomCollections = 0;

  final GardenGrowthStage stage;
  final String plantName;
  final int coinReward;
  final int waterProgress;
  final int bloomCollections;

  bool get isEmpty => stage.isEmpty;
  int get waterRequired => stage.waterRequired;
  int get remainingWater =>
      (waterRequired - waterProgress).clamp(0, waterRequired);
  bool get isReadyToGrow => stage.needsWater && remainingWater == 0;
  int get remainingBloomCollections => (3 - bloomCollections).clamp(0, 3);

  GardenPot copyWith({
    GardenGrowthStage? stage,
    String? plantName,
    int? coinReward,
    int? waterProgress,
    int? bloomCollections,
  }) {
    return GardenPot(
      stage: stage ?? this.stage,
      plantName: plantName ?? this.plantName,
      coinReward: coinReward ?? this.coinReward,
      waterProgress: waterProgress ?? this.waterProgress,
      bloomCollections: bloomCollections ?? this.bloomCollections,
    );
  }
}
