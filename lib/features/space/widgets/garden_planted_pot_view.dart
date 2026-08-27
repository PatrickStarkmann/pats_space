import 'package:flutter/widgets.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';
import 'package:pats_space/features/space/widgets/garden_pot_view.dart';

class GardenPlantedPotView extends StatelessWidget {
  const GardenPlantedPotView({
    super.key,
    required this.pot,
    required this.size,
    this.useNoShadowPot = false,
    this.potStyleOverride,
  });

  final GardenPot pot;
  final double size;
  final bool useNoShadowPot;
  final GardenPotStyle? potStyleOverride;

  @override
  Widget build(BuildContext context) {
    final stage = pot.stage;
    final potStyle = potStyleOverride ?? pot.potStyle;
    final renderOffsetY = size * potStyle.renderOffsetYFactor;

    return Transform.translate(
      offset: Offset(0, renderOffsetY),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            GardenPotView(
              size: size,
              assetPath: useNoShadowPot
                  ? potStyle.noShadowAssetPath
                  : potStyle.assetPath,
            ),
            if (!stage.isEmpty)
              _PlantStageImage(pot: pot, potStyle: potStyle, size: size),
          ],
        ),
      ),
    );
  }
}

class _PlantStageImage extends StatelessWidget {
  const _PlantStageImage({
    required this.pot,
    required this.potStyle,
    required this.size,
  });

  final GardenPot pot;
  final GardenPotStyle potStyle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final plantSize = size * _plantSizeFactor;
    final bottomOffset = size * _plantBottomFactor;

    return Positioned(
      bottom: bottomOffset,
      width: plantSize,
      height: plantSize,
      child: Image.asset(
        pot.plantAsset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  double get _plantSizeFactor {
    final base = potStyle.plantSizeFactorFor(pot.stage);
    if (pot.plantType == GardenPlantType.cherryBlossom &&
        (pot.stage == GardenGrowthStage.bloom ||
            pot.stage == GardenGrowthStage.dry)) {
      return base * 1.14;
    }

    if (potStyle != GardenPotStyle.hanging ||
        pot.plantType != GardenPlantType.hangingFlower) {
      return base;
    }

    return switch (pot.stage) {
      GardenGrowthStage.seed => base * .88,
      GardenGrowthStage.sprout => base * .92,
      GardenGrowthStage.bloom => base * 1.24,
      GardenGrowthStage.dry => base * 1.24,
      _ => base,
    };
  }

  double get _plantBottomFactor {
    final base = potStyle.plantBottomFactorFor(pot.stage);
    if (pot.plantType == GardenPlantType.strawberry) {
      return switch (pot.stage) {
        GardenGrowthStage.bloom => base - .06,
        GardenGrowthStage.dry => base - .04,
        _ => base,
      };
    }

    if (potStyle != GardenPotStyle.hanging ||
        pot.plantType != GardenPlantType.hangingFlower) {
      return base;
    }

    return switch (pot.stage) {
      GardenGrowthStage.seed => base + .02,
      GardenGrowthStage.sprout => base + .02,
      GardenGrowthStage.bloom => base - .36,
      GardenGrowthStage.dry => base - .32,
      _ => base,
    };
  }
}
