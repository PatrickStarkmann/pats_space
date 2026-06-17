import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_pot_slot.dart';
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
    required this.water,
    required this.coins,
    required this.onPotSelected,
    required this.onPotAction,
    required this.onCoinCollected,
  });

  final List<GardenPot> pots;
  final int water;
  final int coins;
  final ValueChanged<int> onPotSelected;
  final ValueChanged<int> onPotAction;
  final CoinCollectedCallback onCoinCollected;

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
                water: water,
                coins: coins,
                stageSize: stageSize,
                usableGardenHeight: usableGardenHeight,
                potSize: shortestSide * _potSlots[index].sizeFactor,
                onTap: () => onPotSelected(index),
                onActionTap: () => onPotAction(index),
                onCoinCollected: onCoinCollected,
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

class _PositionedPot extends StatefulWidget {
  const _PositionedPot({
    required this.slot,
    required this.pot,
    required this.water,
    required this.coins,
    required this.stageSize,
    required this.usableGardenHeight,
    required this.potSize,
    required this.onTap,
    required this.onActionTap,
    required this.onCoinCollected,
  });

  final GardenPotSlot slot;
  final GardenPot pot;
  final int water;
  final int coins;
  final Size stageSize;
  final double usableGardenHeight;
  final double potSize;
  final VoidCallback onTap;
  final VoidCallback onActionTap;
  final CoinCollectedCallback onCoinCollected;

  @override
  State<_PositionedPot> createState() => _PositionedPotState();
}

class _PositionedPotState extends State<_PositionedPot>
    with TickerProviderStateMixin {
  late final AnimationController _feedbackController;
  late final AnimationController _readyController;
  late final AnimationController _shakeController;
  Timer? _wateringTimer;
  _PotFeedbackKind _feedbackKind = _PotFeedbackKind.water;
  String? _bubbleProgressText;

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
    _syncReadyPulse();
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
      widget.onCoinCollected(
        Offset(
          widget.stageSize.width * widget.slot.alignmentX,
          widget.usableGardenHeight * widget.slot.alignmentY - widget.potSize,
        ),
        rewardAmount,
        rewardAmount > oldPot.plantType.coinReward,
      );
    }
    _syncReadyPulse();
    _feedbackController.forward(from: 0);
  }

  @override
  void dispose() {
    _wateringTimer?.cancel();
    _feedbackController.dispose();
    _readyController.dispose();
    _shakeController.dispose();
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
      HapticFeedback.selectionClick();
      _triggerUnavailableShake();
      widget.onTap();
      return;
    }

    if (pot.stage.hasCoins && !pot.hasCollectableCoins) {
      HapticFeedback.selectionClick();
      widget.onTap();
      return;
    }

    if (pot.stage.hasCoins || pot.isReadyToGrow) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    widget.onActionTap();
  }

  void _startWateringStream() {
    if (!_canWaterCurrentPot) {
      return;
    }

    HapticFeedback.selectionClick();
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
    final bubbleSize = potSize * .34;
    final hitAreaTopInset = potSize * .55;
    final bubbleTop = switch (stage) {
      GardenGrowthStage.empty || GardenGrowthStage.seed => potSize * .22,
      GardenGrowthStage.sprout => -potSize * .02,
      GardenGrowthStage.bud => -potSize * .18,
      GardenGrowthStage.bloom => -potSize * .3,
      GardenGrowthStage.dry => -potSize * .22,
    };
    final actionEnabled = stage.hasCoins
        ? pot.hasCollectableCoins
        : !stage.needsWater || widget.water > 0;
    final showActionBubble = !stage.hasCoins || pot.hasCollectableCoins;
    final isReadyForCoins = pot.hasCollectableCoins;

    return Positioned(
      left: widget.stageSize.width * widget.slot.alignmentX - potSize / 2,
      top:
          widget.usableGardenHeight * widget.slot.alignmentY -
          potSize -
          hitAreaTopInset,
      width: potSize,
      height: potSize * 1.5 + hitAreaTopInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
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
                  child: Transform.scale(scale: 1 + bounce * .06, child: child),
                );
              },
              child: GardenPlantedPotView(pot: pot, size: potSize),
            ),
          ),
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
