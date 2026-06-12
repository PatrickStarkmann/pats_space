import 'package:pats_space/features/space/models/garden_growth_stage.dart';

class GardenPot {
  const GardenPot({
    required this.stage,
    required this.plantName,
    required this.coinReward,
  });

  const GardenPot.empty()
    : stage = GardenGrowthStage.empty,
      plantName = 'Daisy',
      coinReward = 5;

  final GardenGrowthStage stage;
  final String plantName;
  final int coinReward;

  bool get isEmpty => stage.isEmpty;

  GardenPot copyWith({
    GardenGrowthStage? stage,
    String? plantName,
    int? coinReward,
  }) {
    return GardenPot(
      stage: stage ?? this.stage,
      plantName: plantName ?? this.plantName,
      coinReward: coinReward ?? this.coinReward,
    );
  }
}
