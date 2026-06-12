import 'package:flutter/widgets.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/widgets/garden_pot_view.dart';

class GardenPlantedPotView extends StatelessWidget {
  const GardenPlantedPotView({
    super.key,
    required this.stage,
    required this.size,
  });

  final GardenGrowthStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          GardenPotView(size: size),
          if (!stage.isEmpty) _PlantStageImage(stage: stage, size: size),
        ],
      ),
    );
  }
}

class _PlantStageImage extends StatelessWidget {
  const _PlantStageImage({required this.stage, required this.size});

  final GardenGrowthStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final plantSize = switch (stage) {
      GardenGrowthStage.seed => size * .24,
      GardenGrowthStage.sprout => size * .58,
      GardenGrowthStage.bud => size * .7,
      GardenGrowthStage.bloom => size * .82,
      GardenGrowthStage.dry => size * .72,
      GardenGrowthStage.empty => 0.0,
    };
    final bottomOffset = switch (stage) {
      GardenGrowthStage.seed => size * .58,
      GardenGrowthStage.sprout => size * .58,
      GardenGrowthStage.bud => size * .6,
      GardenGrowthStage.bloom => size * .62,
      GardenGrowthStage.dry => size * .6,
      GardenGrowthStage.empty => 0.0,
    };

    return Positioned(
      bottom: bottomOffset,
      width: plantSize,
      height: plantSize,
      child: Image.asset(
        stage.plantAsset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
