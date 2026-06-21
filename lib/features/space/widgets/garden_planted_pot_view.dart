import 'package:flutter/widgets.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/widgets/garden_pot_view.dart';

class GardenPlantedPotView extends StatelessWidget {
  const GardenPlantedPotView({
    super.key,
    required this.pot,
    required this.size,
  });

  final GardenPot pot;
  final double size;

  @override
  Widget build(BuildContext context) {
    final stage = pot.stage;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          GardenPotView(size: size, assetPath: pot.potStyle.assetPath),
          if (!stage.isEmpty) _PlantStageImage(pot: pot, size: size),
        ],
      ),
    );
  }
}

class _PlantStageImage extends StatelessWidget {
  const _PlantStageImage({required this.pot, required this.size});

  final GardenPot pot;
  final double size;

  @override
  Widget build(BuildContext context) {
    final stage = pot.stage;
    final plantSize = size * pot.potStyle.plantSizeFactorFor(stage);
    final bottomOffset = size * pot.potStyle.plantBottomFactorFor(stage);

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
}
