import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/widgets/garden_coin_icon.dart';
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

  final List<_CoinFlight> _coinFlights = [];
  int _nextCoinFlightId = 0;

  void _launchCoinFlight(Offset start, int amount, bool lucky) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _coinFlights.add(
          _CoinFlight(
            id: _nextCoinFlightId++,
            start: start,
            amount: amount,
            lucky: lucky,
          ),
        );
      });
    });
  }

  void _removeCoinFlight(int id) {
    if (!mounted) {
      return;
    }
    setState(() {
      _coinFlights.removeWhere((flight) => flight.id == id);
    });
  }

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
              pots: garden.pots,
              water: garden.water,
              coins: garden.coins,
              onPotSelected: widget.gardenController.selectPot,
              onPotAction: widget.gardenController.performPotAction,
              onCoinCollected: _launchCoinFlight,
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
                  water: garden.water,
                  unlockedPlantTypes: garden.unlockedPlantTypes,
                  onPrimaryAction:
                      widget.gardenController.performSelectedPotAction,
                  onPlantSelected: widget.gardenController.plantSelectedPot,
                  onRemovePlant: widget.gardenController.removeSelectedPlant,
                  onClose: widget.gardenController.closeSelectedPot,
                ),
              ),
            Positioned.fill(
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final target = Offset(constraints.maxWidth - 86, 48 + 25);

                    return Stack(
                      children: [
                        for (final flight in _coinFlights)
                          _FlyingCoin(
                            key: ValueKey(flight.id),
                            start: flight.start,
                            target: target,
                            amount: flight.amount,
                            lucky: flight.lucky,
                            onCompleted: () => _removeCoinFlight(flight.id),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CoinFlight {
  const _CoinFlight({
    required this.id,
    required this.start,
    required this.amount,
    required this.lucky,
  });

  final int id;
  final Offset start;
  final int amount;
  final bool lucky;
}

class _FlyingCoin extends StatefulWidget {
  const _FlyingCoin({
    super.key,
    required this.start,
    required this.target,
    required this.amount,
    required this.lucky,
    required this.onCompleted,
  });

  final Offset start;
  final Offset target;
  final int amount;
  final bool lucky;
  final VoidCallback onCompleted;

  @override
  State<_FlyingCoin> createState() => _FlyingCoinState();
}

class _FlyingCoinState extends State<_FlyingCoin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final bigDrop = widget.lucky || widget.amount >= 10;
    _controller =
        AnimationController(
            vsync: this,
            duration: Duration(milliseconds: bigDrop ? 880 : 720),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onCompleted();
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(_controller.value);
        final arc = -60 * math.sin(math.pi * t);
        final position = Offset.lerp(widget.start, widget.target, t)!;
        final bigDrop = widget.lucky || widget.amount >= 10;
        final scale = 1 + math.sin(math.pi * t) * (bigDrop ? .42 : .28);
        final opacity = _controller.value > .82
            ? (1 - _controller.value) / .18
            : 1.0;

        return Positioned(
          left: position.dx - 14,
          top: position.dy + arc - 14,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentWarm.withValues(alpha: .32),
              blurRadius: 16,
            ),
          ],
        ),
        child: _FlyingCoinBadge(amount: widget.amount, lucky: widget.lucky),
      ),
    );
  }
}

class _FlyingCoinBadge extends StatelessWidget {
  const _FlyingCoinBadge({required this.amount, required this.lucky});

  final int amount;
  final bool lucky;

  @override
  Widget build(BuildContext context) {
    final label = amount > 0 ? '+$amount' : '+';
    final bigDrop = lucky || amount >= 10;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GardenCoinIcon(size: bigDrop ? 34 : 28),
        Positioned(
          left: bigDrop ? 24 : 20,
          top: bigDrop ? -18 : -12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: .96),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.accentWarm.withValues(alpha: .7),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.charcoal.withValues(alpha: .08),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              child: Text(
                lucky ? 'Lucky $label' : label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.charcoal,
                  fontSize: bigDrop ? 12 : 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
