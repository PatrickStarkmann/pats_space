import 'package:flutter/widgets.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/widgets/garden_plant_card.dart';
import 'package:pats_space/features/space/widgets/garden_resource_counter.dart';
import 'package:pats_space/features/space/widgets/garden_stage.dart';

class SpaceScreen extends StatefulWidget {
  const SpaceScreen({super.key, required this.gardenController});

  final GardenController gardenController;

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  static const _bottomNavigationClearance = 40.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.gardenController,
      builder: (context, _) {
        final garden = widget.gardenController.state;
        final selectedPot = garden.selectedPot;

        return Stack(
          children: [
            GardenStage(
              potStages: garden.potStages,
              onPotSelected: widget.gardenController.selectPot,
              onPotAction: widget.gardenController.selectPot,
            ),
            Positioned(
              top: 48,
              right: AppSpacing.xl,
              child: GardenResourceCounter(
                water: garden.water,
                coins: garden.coins,
              ),
            ),
            if (selectedPot != null)
              Positioned(
                left: 0,
                right: 0,
                bottom:
                    MediaQuery.paddingOf(context).bottom +
                    _bottomNavigationClearance,
                child: GardenPlantCard(
                  pot: selectedPot,
                  onPrimaryAction:
                      widget.gardenController.performSelectedPotAction,
                  onClose: widget.gardenController.closeSelectedPot,
                ),
              ),
          ],
        );
      },
    );
  }
}
