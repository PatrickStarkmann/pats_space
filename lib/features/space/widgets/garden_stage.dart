import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/models/garden_area.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_decoration_placement.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_pot_slot.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';
import 'package:pats_space/features/space/widgets/garden_action_bubble.dart';
import 'package:pats_space/features/space/widgets/garden_background.dart';
import 'package:pats_space/features/space/widgets/garden_character_view.dart';
import 'package:pats_space/features/space/widgets/garden_planted_pot_view.dart';

typedef CoinCollectedCallback =
    void Function(Offset start, int amount, bool lucky);

class GardenStage extends StatelessWidget {
  const GardenStage({
    super.key,
    required this.pots,
    required this.area,
    required this.backgroundAssetPath,
    required this.water,
    required this.coins,
    required this.decorations,
    required this.decorationPlacements,
    required this.potPlacements,
    required this.arrangingDecorations,
    required this.selectedDecoration,
    required this.selectedArrangedPotIndex,
    this.tutorialHighlightedPotIndex,
    this.tutorialInteractivePotIndex,
    required this.onPotSelected,
    required this.onPotAction,
    required this.onWaterEmpty,
    required this.onCoinCollected,
    required this.onDecorationSelected,
    required this.onDecorationPlacementChanged,
    required this.onPotArrangeSelected,
    required this.onPotMoved,
    required this.onPotMoveEnded,
  });

  final List<GardenPot> pots;
  final GardenArea area;
  final String backgroundAssetPath;
  final int water;
  final int coins;
  final Set<GardenDecoration> decorations;
  final Map<GardenDecoration, GardenDecorationPlacement> decorationPlacements;
  final Map<int, GardenDecorationPlacement> potPlacements;
  final bool arrangingDecorations;
  final GardenDecoration? selectedDecoration;
  final int? selectedArrangedPotIndex;
  final int? tutorialHighlightedPotIndex;
  final int? tutorialInteractivePotIndex;
  final ValueChanged<int> onPotSelected;
  final ValueChanged<int> onPotAction;
  final VoidCallback onWaterEmpty;
  final CoinCollectedCallback onCoinCollected;
  final ValueChanged<GardenDecoration> onDecorationSelected;
  final void Function(
    GardenDecoration decoration,
    GardenDecorationPlacement placement,
  )
  onDecorationPlacementChanged;
  final ValueChanged<int> onPotArrangeSelected;
  final void Function(int index, double alignmentX, double alignmentY)
  onPotMoved;
  final void Function(int index, double alignmentX, double alignmentY)
  onPotMoveEnded;

  static const _navigationClearance = 112.0;

  static const _mainPotSlots = [
    GardenPotSlot(alignmentX: .16, alignmentY: .9, sizeFactor: .28),
    GardenPotSlot(alignmentX: .38, alignmentY: .96, sizeFactor: .28),
    GardenPotSlot(alignmentX: .62, alignmentY: .9, sizeFactor: .28),
    GardenPotSlot(alignmentX: .84, alignmentY: .96, sizeFactor: .28),
  ];

  static const _secondPotSlots = [
    GardenPotSlot(
      alignmentX: .29,
      alignmentY: .38,
      sizeFactor: .285,
      potStyleOverride: GardenPotStyle.hanging,
    ),
    GardenPotSlot(
      alignmentX: .5,
      alignmentY: .38,
      sizeFactor: .285,
      potStyleOverride: GardenPotStyle.hanging,
    ),
    GardenPotSlot(
      alignmentX: .71,
      alignmentY: .38,
      sizeFactor: .285,
      potStyleOverride: GardenPotStyle.hanging,
    ),
    GardenPotSlot(
      alignmentX: .118,
      alignmentY: .622,
      sizeFactor: .155,
      useNoShadowPot: true,
    ),
    GardenPotSlot(
      alignmentX: .255,
      alignmentY: .616,
      sizeFactor: .155,
      useNoShadowPot: true,
    ),
    GardenPotSlot(alignmentX: .15, alignmentY: .84, sizeFactor: .25),
    GardenPotSlot(alignmentX: .26, alignmentY: .94, sizeFactor: .25),
    GardenPotSlot(alignmentX: .66, alignmentY: .88, sizeFactor: .25),
    GardenPotSlot(alignmentX: .88, alignmentY: .88, sizeFactor: .25),
  ];

  static const _secondAreaFixedPotSlots = {0, 1, 2, 3, 4};

  List<GardenPotSlot> get _potSlots => switch (area) {
    GardenArea.main => _mainPotSlots,
    GardenArea.second => _secondPotSlots,
  };

  bool _isFixedPotSlot(int index) {
    return area == GardenArea.second &&
        _secondAreaFixedPotSlots.contains(index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stageSize = Size(constraints.maxWidth, constraints.maxHeight);
        final shortestSide = math.min(stageSize.width, stageSize.height);
        final visualSize = MediaQuery.sizeOf(context).shortestSide >= 600
            ? math.min(shortestSide, 650.0)
            : shortestSide;
        final usableGardenHeight =
            stageSize.height -
            MediaQuery.paddingOf(context).bottom -
            _navigationClearance;
        final potSlots = _potSlots;
        final potRenderOrder = List<int>.generate(
          math.min(pots.length, potSlots.length),
          (index) => index,
        );
        if (!arrangingDecorations) {
          potRenderOrder.sort((a, b) {
            final aSlot = potSlots[a];
            final bSlot = potSlots[b];
            final aY = potPlacements[a]?.alignmentY ?? aSlot.alignmentY;
            final bY = potPlacements[b]?.alignmentY ?? bSlot.alignmentY;
            final yCompare = aY.compareTo(bY);
            if (yCompare != 0) {
              return yCompare;
            }

            return aSlot.sizeFactor.compareTo(bSlot.sizeFactor);
          });
        }
        if (arrangingDecorations && selectedArrangedPotIndex != null) {
          potRenderOrder
            ..remove(selectedArrangedPotIndex)
            ..add(selectedArrangedPotIndex!);
        }

        final decorationRenderOrder = decorations.toList()
          ..sort((a, b) => a.index.compareTo(b.index));
        final visibleDecorationRenderOrder = decorationRenderOrder
            .where(
              (decoration) =>
                  decoration != GardenDecoration.hangingPlantFrame &&
                  decoration != GardenDecoration.hangingPot,
            )
            .toList();
        final backDecorations = visibleDecorationRenderOrder.where((
          decoration,
        ) {
          return !(decorationPlacements[decoration]?.inFront ?? false);
        });
        final frontDecorations = visibleDecorationRenderOrder.where((
          decoration,
        ) {
          return decorationPlacements[decoration]?.inFront ?? false;
        });

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GardenBackground(assetPath: backgroundAssetPath),
            ),
            for (final decoration in backDecorations)
              _PositionedDecoration(
                decoration: decoration,
                placement: decorationPlacements[decoration],
                stageSize: stageSize,
                usableGardenHeight: usableGardenHeight,
                interactive: false,
                selected: false,
                showImage: true,
                onSelected: () => onDecorationSelected(decoration),
                onPlacementChanged: (placement) =>
                    onDecorationPlacementChanged(decoration, placement),
              ),
            _PositionedCharacter(
              stageSize: stageSize,
              usableGardenHeight: usableGardenHeight,
              characterSize: visualSize * .56,
            ),
            for (final decoration in frontDecorations)
              _PositionedDecoration(
                decoration: decoration,
                placement: decorationPlacements[decoration],
                stageSize: stageSize,
                usableGardenHeight: usableGardenHeight,
                interactive: false,
                selected: false,
                showImage: true,
                onSelected: () => onDecorationSelected(decoration),
                onPlacementChanged: (placement) =>
                    onDecorationPlacementChanged(decoration, placement),
              ),
            for (final index in potRenderOrder)
              _PositionedPot(
                key: ValueKey('garden-pot-$index'),
                slot: potSlots[index],
                placement: _isFixedPotSlot(index) ? null : potPlacements[index],
                pot: pots[index],
                water: water,
                coins: coins,
                stageSize: stageSize,
                usableGardenHeight: usableGardenHeight,
                potSize: visualSize * potSlots[index].sizeFactor,
                arranging: arrangingDecorations,
                movable: !_isFixedPotSlot(index),
                selected: selectedArrangedPotIndex == index,
                tutorialHighlighted:
                    !arrangingDecorations &&
                    tutorialHighlightedPotIndex == index,
                tutorialLocked:
                    !arrangingDecorations &&
                    tutorialInteractivePotIndex != null &&
                    tutorialInteractivePotIndex != index,
                onTap: () => arrangingDecorations
                    ? onPotArrangeSelected(index)
                    : onPotSelected(index),
                onMoved: (alignmentX, alignmentY) =>
                    onPotMoved(index, alignmentX, alignmentY),
                onMoveEnded: (alignmentX, alignmentY) =>
                    onPotMoveEnded(index, alignmentX, alignmentY),
                onActionTap: () => onPotAction(index),
                onWaterEmpty: onWaterEmpty,
                onCoinCollected: onCoinCollected,
              ),
            if (arrangingDecorations)
              for (final decoration in visibleDecorationRenderOrder)
                _PositionedDecoration(
                  decoration: decoration,
                  placement: decorationPlacements[decoration],
                  stageSize: stageSize,
                  usableGardenHeight: usableGardenHeight,
                  interactive: true,
                  selected: selectedDecoration == decoration,
                  showImage: false,
                  onSelected: () => onDecorationSelected(decoration),
                  onPlacementChanged: (placement) =>
                      onDecorationPlacementChanged(decoration, placement),
                ),
          ],
        );
      },
    );
  }
}

class _PositionedDecoration extends StatefulWidget {
  const _PositionedDecoration({
    required this.decoration,
    required this.placement,
    required this.stageSize,
    required this.usableGardenHeight,
    required this.interactive,
    required this.selected,
    required this.showImage,
    required this.onSelected,
    required this.onPlacementChanged,
  });

  final GardenDecoration decoration;
  final GardenDecorationPlacement? placement;
  final Size stageSize;
  final double usableGardenHeight;
  final bool interactive;
  final bool selected;
  final bool showImage;
  final VoidCallback onSelected;
  final ValueChanged<GardenDecorationPlacement> onPlacementChanged;

  @override
  State<_PositionedDecoration> createState() => _PositionedDecorationState();
}

class _PositionedDecorationState extends State<_PositionedDecoration> {
  GardenDecorationPlacement? _dragStartPlacement;
  Offset _dragDelta = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final shortestSide = math.min(
      widget.stageSize.width,
      widget.stageSize.height,
    );
    final visualSize = MediaQuery.sizeOf(context).shortestSide >= 600
        ? math.min(shortestSide, 650.0)
        : shortestSide;
    final spec = switch (widget.decoration) {
      GardenDecoration.bench => const _DecorationSpec(
        alignmentX: .16,
        alignmentY: .69,
        sizeFactor: .18,
      ),
      GardenDecoration.fountain => const _DecorationSpec(
        alignmentX: .84,
        alignmentY: .72,
        sizeFactor: .2,
      ),
      GardenDecoration.lantern => const _DecorationSpec(
        alignmentX: .9,
        alignmentY: .66,
        sizeFactor: .12,
      ),
      GardenDecoration.stonePath => const _DecorationSpec(
        alignmentX: .5,
        alignmentY: .84,
        sizeFactor: .3,
      ),
      GardenDecoration.wateringCan => const _DecorationSpec(
        alignmentX: .48,
        alignmentY: .76,
        sizeFactor: .11,
      ),
      GardenDecoration.hangingPlantFrame => const _DecorationSpec(
        alignmentX: .5,
        alignmentY: .48,
        sizeFactor: .92,
      ),
      GardenDecoration.hangingPot => const _DecorationSpec(
        alignmentX: .5,
        alignmentY: .53,
        sizeFactor: .14,
      ),
    };
    final resolvedPlacement =
        widget.placement ??
        GardenDecorationPlacement(
          alignmentX: spec.alignmentX,
          alignmentY: spec.alignmentY,
        );
    final size = visualSize * spec.sizeFactor * resolvedPlacement.scale;

    return Positioned(
      left: widget.stageSize.width * resolvedPlacement.alignmentX - size / 2,
      top: widget.usableGardenHeight * resolvedPlacement.alignmentY - size / 2,
      width: size,
      height: size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.interactive
            ? () {
                widget.onSelected();
                widget.onPlacementChanged(resolvedPlacement);
              }
            : null,
        onPanStart: widget.interactive
            ? (_) {
                widget.onSelected();
                widget.onPlacementChanged(resolvedPlacement);
                _dragStartPlacement = resolvedPlacement;
                _dragDelta = Offset.zero;
              }
            : null,
        onPanUpdate: widget.interactive
            ? (details) {
                final start = _dragStartPlacement ?? resolvedPlacement;
                _dragDelta += details.delta;
                final nextX =
                    start.alignmentX + _dragDelta.dx / widget.stageSize.width;
                final nextY =
                    start.alignmentY +
                    _dragDelta.dy / widget.usableGardenHeight;

                widget.onPlacementChanged(
                  start.copyWith(alignmentX: nextX, alignmentY: nextY),
                );
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          padding: widget.interactive
              ? const EdgeInsets.all(3)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: widget.interactive && widget.selected
                ? AppColors.sageSoft.withValues(alpha: .18)
                : AppColors.transparent,
            border: widget.interactive
                ? Border.all(
                    color: widget.selected
                        ? AppColors.sage
                        : AppColors.sage.withValues(alpha: .34),
                    width: widget.selected ? 1.8 : 1,
                  )
                : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: widget.showImage
              ? Image.asset(
                  widget.decoration.assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                )
              : const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _DecorationSpec {
  const _DecorationSpec({
    required this.alignmentX,
    required this.alignmentY,
    required this.sizeFactor,
  });

  final double alignmentX;
  final double alignmentY;
  final double sizeFactor;
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

class _PositionedPot extends StatefulWidget {
  const _PositionedPot({
    super.key,
    required this.slot,
    required this.placement,
    required this.pot,
    required this.water,
    required this.coins,
    required this.stageSize,
    required this.usableGardenHeight,
    required this.potSize,
    required this.arranging,
    required this.movable,
    required this.selected,
    required this.tutorialHighlighted,
    required this.tutorialLocked,
    required this.onTap,
    required this.onMoved,
    required this.onMoveEnded,
    required this.onActionTap,
    required this.onWaterEmpty,
    required this.onCoinCollected,
  });

  final GardenPotSlot slot;
  final GardenDecorationPlacement? placement;
  final GardenPot pot;
  final int water;
  final int coins;
  final Size stageSize;
  final double usableGardenHeight;
  final double potSize;
  final bool arranging;
  final bool movable;
  final bool selected;
  final bool tutorialHighlighted;
  final bool tutorialLocked;
  final VoidCallback onTap;
  final void Function(double alignmentX, double alignmentY) onMoved;
  final void Function(double alignmentX, double alignmentY) onMoveEnded;
  final VoidCallback onActionTap;
  final VoidCallback onWaterEmpty;
  final CoinCollectedCallback onCoinCollected;

  @override
  State<_PositionedPot> createState() => _PositionedPotState();
}

class _PositionedPotState extends State<_PositionedPot>
    with TickerProviderStateMixin {
  late final AnimationController _feedbackController;
  late final AnimationController _readyController;
  late final AnimationController _shakeController;
  late final AnimationController _tutorialController;
  Timer? _wateringTimer;
  _PotFeedbackKind _feedbackKind = _PotFeedbackKind.water;
  String? _bubbleProgressText;
  GardenDecorationPlacement? _dragStartPlacement;
  GardenDecorationPlacement? _lastDragPlacement;
  Offset _dragDelta = Offset.zero;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _readyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1550),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _tutorialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _syncReadyPulse();
    _syncTutorialPulse();
  }

  @override
  void didUpdateWidget(covariant _PositionedPot oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPot = oldWidget.pot;
    final pot = widget.pot;
    final changed =
        oldPot.stage != pot.stage ||
        oldPot.waterProgress != pot.waterProgress ||
        oldPot.bloomCollections != pot.bloomCollections;

    if (!changed) {
      _syncReadyPulse();
      _syncTutorialPulse();
      return;
    }

    final collectedCoins =
        oldPot.hasCollectableCoins &&
        (oldPot.bloomCharges > pot.bloomCharges || pot.stage.isDry);
    final grew = oldPot.stage != pot.stage;
    _feedbackKind = collectedCoins
        ? _PotFeedbackKind.coin
        : grew
        ? _PotFeedbackKind.growth
        : _PotFeedbackKind.water;
    _bubbleProgressText = oldPot.stage.needsWater
        ? '${math.min(oldPot.waterProgress + 1, oldPot.waterRequired)}/${oldPot.waterRequired}'
        : null;
    if (collectedCoins) {
      final rewardAmount = math.max(0, widget.coins - oldWidget.coins);
      final resolvedX = widget.placement?.alignmentX ?? widget.slot.alignmentX;
      final resolvedY = widget.placement?.alignmentY ?? widget.slot.alignmentY;
      widget.onCoinCollected(
        Offset(
          widget.stageSize.width * resolvedX,
          widget.usableGardenHeight * resolvedY - widget.potSize,
        ),
        rewardAmount,
        rewardAmount > oldPot.plantType.coinReward,
      );
    }
    _syncReadyPulse();
    _syncTutorialPulse();
    _feedbackController.forward(from: 0);
  }

  @override
  void dispose() {
    _wateringTimer?.cancel();
    _feedbackController.dispose();
    _readyController.dispose();
    _shakeController.dispose();
    _tutorialController.dispose();
    super.dispose();
  }

  void _syncReadyPulse() {
    if (widget.pot.hasCollectableCoins) {
      if (!_readyController.isAnimating) {
        _readyController.repeat(reverse: true);
      }
      return;
    }

    if (_readyController.isAnimating) {
      _readyController.stop();
    }
    _readyController.value = 0;
  }

  void _syncTutorialPulse() {
    if (widget.tutorialHighlighted) {
      if (!_tutorialController.isAnimating) {
        _tutorialController.repeat();
      }
      return;
    }

    if (_tutorialController.isAnimating) {
      _tutorialController.stop();
    }
    _tutorialController.value = 0;
  }

  bool get _canWaterCurrentPot {
    final pot = widget.pot;
    return pot.stage.needsWater && widget.water > 0;
  }

  void _handleActionTap() {
    final pot = widget.pot;
    if (pot.stage.isEmpty) {
      widget.onActionTap();
      return;
    }

    if (pot.stage.needsWater && widget.water <= 0) {
      AppHaptics.error();
      _triggerUnavailableShake();
      widget.onWaterEmpty();
      return;
    }

    if (pot.stage.hasCoins && !pot.hasCollectableCoins) {
      AppHaptics.error();
      widget.onTap();
      return;
    }

    if (pot.stage.hasCoins) {
      AppHaptics.reward();
    } else if (pot.isReadyToGrow) {
      AppHaptics.mediumImpact();
    } else {
      AppHaptics.lightImpact();
    }
    widget.onActionTap();
  }

  void _startWateringStream() {
    if (!_canWaterCurrentPot) {
      return;
    }

    AppHaptics.selection();
    _handleActionTap();
    _wateringTimer?.cancel();
    _wateringTimer = Timer.periodic(const Duration(milliseconds: 360), (_) {
      if (!mounted || !_canWaterCurrentPot) {
        _stopWateringStream();
        return;
      }
      _handleActionTap();
    });
  }

  void _stopWateringStream() {
    _wateringTimer?.cancel();
    _wateringTimer = null;
  }

  void _triggerUnavailableShake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final pot = widget.pot;
    final stage = pot.stage;
    final potSize = widget.potSize;
    final resolvedX = widget.placement?.alignmentX ?? widget.slot.alignmentX;
    final resolvedY = widget.placement?.alignmentY ?? widget.slot.alignmentY;
    final bubbleSize = potSize * .34;
    final hitAreaTopInset = potSize * .55;
    final isHangingSlot =
        widget.slot.potStyleOverride == GardenPotStyle.hanging;
    final bubbleTop = isHangingSlot
        ? potSize * .02
        : switch (stage) {
            GardenGrowthStage.empty || GardenGrowthStage.seed => potSize * .22,
            GardenGrowthStage.sprout => -potSize * .02,
            GardenGrowthStage.bud => -potSize * .18,
            GardenGrowthStage.bloom => -potSize * .3,
            GardenGrowthStage.dry => -potSize * .22,
          };
    final actionEnabled = stage.hasCoins
        ? pot.hasCollectableCoins
        : !stage.needsWater || widget.water > 0;
    final canMove = widget.arranging && widget.movable;
    final showActionBubble =
        !widget.arranging &&
        !widget.tutorialLocked &&
        (!stage.hasCoins || pot.hasCollectableCoins);
    final isReadyForCoins = pot.hasCollectableCoins;

    return Positioned(
      left: widget.stageSize.width * resolvedX - potSize / 2,
      top: widget.usableGardenHeight * resolvedY - potSize - hitAreaTopInset,
      width: potSize,
      height: potSize * 1.5 + hitAreaTopInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            width: potSize,
            height: potSize,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.tutorialLocked ? null : widget.onTap,
              onPanStart: canMove
                  ? (_) {
                      widget.onTap();
                      _dragStartPlacement = GardenDecorationPlacement(
                        alignmentX: resolvedX,
                        alignmentY: resolvedY,
                      );
                      _lastDragPlacement = _dragStartPlacement;
                      _dragDelta = Offset.zero;
                    }
                  : null,
              onPanUpdate: canMove
                  ? (details) {
                      final start =
                          _dragStartPlacement ??
                          GardenDecorationPlacement(
                            alignmentX: resolvedX,
                            alignmentY: resolvedY,
                          );
                      _dragDelta += details.delta;
                      final nextX =
                          start.alignmentX +
                          _dragDelta.dx / widget.stageSize.width;
                      final nextY =
                          start.alignmentY +
                          _dragDelta.dy / widget.usableGardenHeight;
                      _lastDragPlacement = GardenDecorationPlacement(
                        alignmentX: nextX,
                        alignmentY: nextY,
                      );
                      widget.onMoved(nextX, nextY);
                    }
                  : null,
              onPanEnd: canMove
                  ? (_) {
                      final placement = _lastDragPlacement;
                      if (placement == null) {
                        return;
                      }
                      widget.onMoveEnded(
                        placement.alignmentX,
                        placement.alignmentY,
                      );
                      _dragStartPlacement = null;
                      _lastDragPlacement = null;
                      _dragDelta = Offset.zero;
                    }
                  : null,
              onPanCancel: canMove
                  ? () {
                      _dragStartPlacement = null;
                      _lastDragPlacement = null;
                      _dragDelta = Offset.zero;
                    }
                  : null,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _feedbackController,
                  _shakeController,
                ]),
                builder: (context, child) {
                  final value = _feedbackController.value;
                  final bounce = value < .5 ? value / .5 : (1 - value) / .5;
                  final shake = _shakeOffset(potSize);
                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: Transform.scale(
                      scale: widget.arranging ? 1 : 1 + bounce * .06,
                      child: child,
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.tutorialHighlighted)
                      _TutorialPotPulse(
                        controller: _tutorialController,
                        potSize: potSize,
                      ),
                    GardenPlantedPotView(
                      pot: pot,
                      size: potSize,
                      useNoShadowPot: widget.slot.useNoShadowPot,
                      potStyleOverride: widget.slot.potStyleOverride,
                    ),
                    if (widget.arranging)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: widget.selected
                                  ? AppColors.sageSoft.withValues(alpha: .16)
                                  : AppColors.transparent,
                              border: Border.all(
                                color: widget.selected
                                    ? AppColors.sage
                                    : AppColors.sage.withValues(alpha: .32),
                                width: widget.selected ? 1.8 : 1,
                              ),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (!widget.arranging)
            _PotFeedbackBurst(
              controller: _feedbackController,
              kind: _feedbackKind,
              potSize: potSize,
              topInset: hitAreaTopInset,
            ),
          if (showActionBubble)
            Positioned(
              top: hitAreaTopInset + bubbleTop - bubbleSize * .28,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _readyController,
                  _shakeController,
                ]),
                builder: (context, child) {
                  final readyPulse = isReadyForCoins
                      ? Curves.easeInOut.transform(_readyController.value)
                      : 0.0;
                  final scale = 1 + readyPulse * .045;
                  final shake = _shakeOffset(potSize);

                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: GardenActionBubble(
                  pot: pot,
                  enabled: actionEnabled,
                  size: bubbleSize,
                  onTap: _handleActionTap,
                  onLongPressStart: _startWateringStream,
                  onLongPressEnd: _stopWateringStream,
                ),
              ),
            ),
          if (!widget.arranging)
            _BubbleProgressToast(
              controller: _feedbackController,
              text: _bubbleProgressText,
              top: hitAreaTopInset + bubbleTop - bubbleSize * .52,
            ),
        ],
      ),
    );
  }

  double _shakeOffset(double potSize) {
    final value = _shakeController.value;
    if (value == 0) {
      return 0;
    }

    return math.sin(value * math.pi * 5) * potSize * .035 * (1 - value);
  }
}

enum _PotFeedbackKind { water, growth, coin }

class _TutorialPotPulse extends StatelessWidget {
  const _TutorialPotPulse({required this.controller, required this.potSize});

  final Animation<double> controller;
  final double potSize;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final wave = Curves.easeOutCubic.transform(controller.value);
            final scale = 1.02 + wave * .22;
            final opacity = (1 - wave).clamp(0.0, 1.0);

            return Center(
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: potSize * 1.08,
                  height: potSize * 1.08,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.charcoal.withValues(
                        alpha: .26 * opacity,
                      ),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.charcoal.withValues(
                          alpha: .06 * opacity,
                        ),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BubbleProgressToast extends StatelessWidget {
  const _BubbleProgressToast({
    required this.controller,
    required this.text,
    required this.top,
  });

  final Animation<double> controller;
  final String? text;
  final double top;

  @override
  Widget build(BuildContext context) {
    final text = this.text;
    if (text == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        if (progress == 0) {
          return const SizedBox.shrink();
        }

        final opacity = progress < .18
            ? progress / .18
            : (1 - progress).clamp(0.0, 1.0);
        final y = -14 * Curves.easeOutCubic.transform(progress);

        return Positioned(
          top: top + y,
          child: IgnorePointer(
            child: Opacity(opacity: opacity, child: child),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .96),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: .08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.drop_fill,
                size: 12,
                color: Color(0xFF6FAAF7),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                text,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PotFeedbackBurst extends StatelessWidget {
  const _PotFeedbackBurst({
    required this.controller,
    required this.kind,
    required this.potSize,
    required this.topInset,
  });

  final Animation<double> controller;
  final _PotFeedbackKind kind;
  final double potSize;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        if (progress == 0 || kind == _PotFeedbackKind.coin) {
          return const SizedBox.shrink();
        }

        final showGrowthBurst = kind == _PotFeedbackKind.growth;
        final opacity = progress < .2
            ? progress / .2
            : (1 - progress).clamp(0.0, 1.0);
        final y = -potSize * .36 * Curves.easeOutCubic.transform(progress);

        return Positioned(
          top: topInset + potSize * .38,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _FloatingFeedbackIcon(
                    icon: showGrowthBurst
                        ? CupertinoIcons.sparkles
                        : CupertinoIcons.drop_fill,
                    color: showGrowthBurst
                        ? AppColors.accentWarm
                        : const Color(0xFF6FAAF7),
                    offset: Offset(-potSize * .16, y),
                    size: potSize * .18,
                  ),
                  _FloatingFeedbackIcon(
                    icon: showGrowthBurst
                        ? CupertinoIcons.sparkles
                        : CupertinoIcons.drop_fill,
                    color: showGrowthBurst
                        ? AppColors.sage
                        : const Color(0xFF8BC5FF),
                    offset: Offset(potSize * .18, y + 10),
                    size: potSize * .14,
                  ),
                  _FloatingFeedbackIcon(
                    icon: showGrowthBurst
                        ? CupertinoIcons.sparkles
                        : CupertinoIcons.drop_fill,
                    color: showGrowthBurst
                        ? AppColors.accentWarm
                        : const Color(0xFFB9DFFF),
                    offset: Offset(0, y - 12),
                    size: potSize * .12,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingFeedbackIcon extends StatelessWidget {
  const _FloatingFeedbackIcon({
    required this.icon,
    required this.color,
    required this.offset,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final Offset offset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Icon(icon, color: color, size: size),
    );
  }
}
