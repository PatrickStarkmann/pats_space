import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_pot_slot.dart';
import 'package:pats_space/features/space/widgets/garden_action_bubble.dart';
import 'package:pats_space/features/space/widgets/garden_background.dart';
import 'package:pats_space/features/space/widgets/garden_character_view.dart';
import 'package:pats_space/features/space/widgets/garden_planted_pot_view.dart';

class GardenStage extends StatelessWidget {
  const GardenStage({
    super.key,
    required this.pots,
    required this.onPotSelected,
    required this.onPotAction,
  });

  final List<GardenPot> pots;
  final ValueChanged<int> onPotSelected;
  final ValueChanged<int> onPotAction;

  static const _navigationClearance = 112.0;

  static const _potSlots = [
    GardenPotSlot(alignmentX: .17, alignmentY: .88, sizeFactor: .28),
    GardenPotSlot(alignmentX: .39, alignmentY: .93, sizeFactor: .28),
    GardenPotSlot(alignmentX: .61, alignmentY: .88, sizeFactor: .28),
    GardenPotSlot(alignmentX: .83, alignmentY: .93, sizeFactor: .28),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stageSize = Size(constraints.maxWidth, constraints.maxHeight);
        final shortestSide = math.min(stageSize.width, stageSize.height);
        final usableGardenHeight =
            stageSize.height -
            MediaQuery.paddingOf(context).bottom -
            _navigationClearance;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: GardenBackground()),
            _PositionedCharacter(
              stageSize: stageSize,
              usableGardenHeight: usableGardenHeight,
              characterSize: shortestSide * .62,
            ),
            for (var index = 0; index < _potSlots.length; index += 1)
              _PositionedPot(
                slot: _potSlots[index],
                pot: pots[index],
                stageSize: stageSize,
                usableGardenHeight: usableGardenHeight,
                potSize: shortestSide * _potSlots[index].sizeFactor,
                onTap: () => onPotSelected(index),
                onActionTap: () => onPotAction(index),
              ),
          ],
        );
      },
    );
  }
}

class _PositionedCharacter extends StatelessWidget {
  const _PositionedCharacter({
    required this.stageSize,
    required this.usableGardenHeight,
    required this.characterSize,
  });

  final Size stageSize;
  final double usableGardenHeight;
  final double characterSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: stageSize.width * .56 - characterSize / 2,
      top: usableGardenHeight * .62 - characterSize / 2,
      width: characterSize,
      height: characterSize,
      child: GardenCharacterView(size: characterSize),
    );
  }
}

class _PositionedPot extends StatelessWidget {
  const _PositionedPot({
    required this.slot,
    required this.pot,
    required this.stageSize,
    required this.usableGardenHeight,
    required this.potSize,
    required this.onTap,
    required this.onActionTap,
  });

  final GardenPotSlot slot;
  final GardenPot pot;
  final Size stageSize;
  final double usableGardenHeight;
  final double potSize;
  final VoidCallback onTap;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final stage = pot.stage;
    final bubbleSize = potSize * .34;
    final bubbleTop = switch (stage) {
      GardenGrowthStage.empty || GardenGrowthStage.seed => potSize * .22,
      GardenGrowthStage.sprout => -potSize * .02,
      GardenGrowthStage.bud => -potSize * .18,
      GardenGrowthStage.bloom => -potSize * .3,
      GardenGrowthStage.dry => -potSize * .22,
    };

    return Positioned(
      left: stageSize.width * slot.alignmentX - potSize / 2,
      top: usableGardenHeight * slot.alignmentY - potSize,
      width: potSize,
      height: potSize * 1.5,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: GardenPlantedPotView(pot: pot, size: potSize),
          ),
          Positioned(
            top: bubbleTop,
            child: GardenActionBubble(
              stage: stage,
              size: bubbleSize,
              onTap: onActionTap,
            ),
          ),
        ],
      ),
    );
  }
}
