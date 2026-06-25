import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/models/garden_area.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_decoration_placement.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/shop/shop_screen.dart';
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
  final List<_PlantUnlockReveal> _plantUnlockReveals = [];
  late Set<GardenPlantType> _knownUnlockedPlantTypes;
  int _nextCoinFlightId = 0;
  int _nextPlantUnlockRevealId = 0;
  bool _arrangingDecorations = false;
  GardenDecoration? _selectedDecoration;
  int? _selectedArrangedPotIndex;
  double _areaDragDx = 0;
  final Map<int, GardenDecorationPlacement> _draftPotPlacements = {};

  @override
  void initState() {
    super.initState();
    _knownUnlockedPlantTypes = {
      ...widget.gardenController.state.unlockedPlantTypes,
    };
    widget.gardenController.addListener(_handleGardenChanged);
  }

  @override
  void didUpdateWidget(covariant SpaceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gardenController == widget.gardenController) {
      return;
    }

    oldWidget.gardenController.removeListener(_handleGardenChanged);
    _knownUnlockedPlantTypes = {
      ...widget.gardenController.state.unlockedPlantTypes,
    };
    widget.gardenController.addListener(_handleGardenChanged);
  }

  @override
  void dispose() {
    widget.gardenController.removeListener(_handleGardenChanged);
    super.dispose();
  }

  void _handleGardenChanged() {
    _handleDecorationArrangementRequest();

    final unlockedPlantTypes = widget.gardenController.state.unlockedPlantTypes;
    final newlyUnlocked = GardenPlantType.plantable
        .where(
          (plantType) =>
              unlockedPlantTypes.contains(plantType) &&
              !_knownUnlockedPlantTypes.contains(plantType),
        )
        .toList();

    _knownUnlockedPlantTypes = {...unlockedPlantTypes};

    if (newlyUnlocked.isEmpty || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      HapticFeedback.mediumImpact();
      setState(() {
        for (final plantType in newlyUnlocked) {
          _plantUnlockReveals.add(
            _PlantUnlockReveal(
              id: _nextPlantUnlockRevealId++,
              plantType: plantType,
            ),
          );
        }
      });
    });
  }

  void _handleDecorationArrangementRequest() {
    final decoration = widget.gardenController
        .consumeDecorationArrangementRequest();
    if (decoration == null || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !widget.gardenController.state.placedDecorations.contains(
            decoration,
          )) {
        return;
      }

      setState(() {
        _arrangingDecorations = true;
        _selectedDecoration = decoration;
        _selectedArrangedPotIndex = null;
        _draftPotPlacements.clear();
      });
    });
  }

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

  void _removePlantUnlockReveal(int id) {
    if (!mounted) {
      return;
    }
    setState(() {
      _plantUnlockReveals.removeWhere((reveal) => reveal.id == id);
    });
  }

  Future<void> _confirmCleanUpGarden() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Clean up garden?'),
          content: const Text(
            'This stores placed decor back in your inventory and moves pots to their default spots. Your plants stay planted.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clean up'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    HapticFeedback.mediumImpact();
    widget.gardenController.cleanUpGarden();
    setState(() {
      _selectedDecoration = null;
      _selectedArrangedPotIndex = null;
      _draftPotPlacements.clear();
    });
  }

  void _selectArea(GardenArea selectedArea) {
    if (selectedArea == widget.gardenController.state.activeArea) {
      return;
    }

    HapticFeedback.selectionClick();
    widget.gardenController.selectArea(selectedArea);
    setState(() {
      _arrangingDecorations = false;
      _selectedDecoration = null;
      _selectedArrangedPotIndex = null;
      _draftPotPlacements.clear();
    });
  }

  void _selectAdjacentArea(int direction) {
    final areas = GardenArea.values;
    final currentIndex = areas.indexOf(
      widget.gardenController.state.activeArea,
    );
    if (currentIndex < 0 || areas.length < 2) {
      return;
    }

    final nextIndex = (currentIndex + direction) % areas.length;
    _selectArea(areas[nextIndex < 0 ? nextIndex + areas.length : nextIndex]);
  }

  void _handleAreaSwipeEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldChange = _areaDragDx.abs() > 84 || velocity.abs() > 560;
    if (!shouldChange) {
      _areaDragDx = 0;
      return;
    }

    _selectAdjacentArea(_areaDragDx < 0 || velocity < -560 ? 1 : -1);
    _areaDragDx = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.gardenController,
      builder: (context, _) {
        final garden = widget.gardenController.state;
        final selectedPot = garden.selectedPot;
        final visiblePotPlacements = {
          ...garden.potPlacements,
          ..._draftPotPlacements,
        };
        final swipeEnabled = !_arrangingDecorations && selectedPot == null;

        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: swipeEnabled
                  ? (_) {
                      _areaDragDx = 0;
                    }
                  : null,
              onHorizontalDragUpdate: swipeEnabled
                  ? (details) {
                      _areaDragDx += details.delta.dx;
                    }
                  : null,
              onHorizontalDragEnd: swipeEnabled ? _handleAreaSwipeEnd : null,
              onHorizontalDragCancel: swipeEnabled
                  ? () {
                      _areaDragDx = 0;
                    }
                  : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 170),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: GardenStage(
                  key: ValueKey(garden.activeArea),
                  pots: garden.pots,
                  area: garden.activeArea,
                  backgroundAssetPath: garden.activeArea.assetPath,
                  water: garden.water,
                  coins: garden.coins,
                  decorations: garden.placedDecorations,
                  decorationPlacements: garden.decorationPlacements,
                  potPlacements: visiblePotPlacements,
                  arrangingDecorations: _arrangingDecorations,
                  selectedDecoration: _selectedDecoration,
                  selectedArrangedPotIndex: _selectedArrangedPotIndex,
                  onPotSelected: widget.gardenController.selectPot,
                  onPotAction: widget.gardenController.performPotAction,
                  onCoinCollected: _launchCoinFlight,
                  onDecorationSelected: (decoration) {
                    setState(() {
                      _selectedDecoration = decoration;
                      _selectedArrangedPotIndex = null;
                    });
                  },
                  onDecorationPlacementChanged: (decoration, placement) {
                    widget.gardenController.updateDecorationPlacement(
                      decoration,
                      alignmentX: placement.alignmentX,
                      alignmentY: placement.alignmentY,
                      scale: placement.scale,
                      inFront: placement.inFront,
                    );
                  },
                  onPotArrangeSelected: (index) {
                    setState(() {
                      _selectedArrangedPotIndex = index;
                      _selectedDecoration = null;
                    });
                  },
                  onPotMoved: (index, alignmentX, alignmentY) {
                    setState(() {
                      _draftPotPlacements[index] = GardenDecorationPlacement(
                        alignmentX: alignmentX.clamp(.08, .92).toDouble(),
                        alignmentY: alignmentY.clamp(.55, .98).toDouble(),
                      );
                    });
                  },
                  onPotMoveEnded: (index, alignmentX, alignmentY) {
                    setState(() {
                      _draftPotPlacements.remove(index);
                    });
                    widget.gardenController.movePot(
                      index,
                      alignmentX: alignmentX,
                      alignmentY: alignmentY,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 48,
              left: AppSpacing.xl,
              child: Row(
                children: [
                  if (garden.ownedDecorations.isNotEmpty ||
                      garden.pots.isNotEmpty) ...[
                    _ArrangeDecorButton(
                      arranging: _arrangingDecorations,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _arrangingDecorations = !_arrangingDecorations;
                          if (!_arrangingDecorations) {
                            _selectedDecoration = null;
                            _selectedArrangedPotIndex = null;
                            _draftPotPlacements.clear();
                          }
                        });
                      },
                    ),
                    if (_arrangingDecorations) ...[
                      const SizedBox(width: AppSpacing.xs),
                      _CleanUpGardenButton(onTap: _confirmCleanUpGarden),
                    ],
                  ],
                  if (!_arrangingDecorations) ...[
                    if (garden.ownedDecorations.isNotEmpty ||
                        garden.pots.isNotEmpty)
                      const SizedBox(width: AppSpacing.xs),
                    _SpaceShopButton(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        showShopSheet(
                          context: context,
                          gardenController: widget.gardenController,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 88,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: _GardenAreaIndicator(activeArea: garden.activeArea),
              ),
            ),
            if (_arrangingDecorations && _selectedDecoration != null)
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom:
                    MediaQuery.paddingOf(context).bottom +
                    _bottomNavigationClearance +
                    AppSpacing.sm,
                child: _DecorationArrangePanel(
                  maxScale: 1.75,
                  placement:
                      garden.decorationPlacements[_selectedDecoration!] ??
                      const GardenDecorationPlacement(
                        alignmentX: .5,
                        alignmentY: .7,
                      ),
                  onScaleChanged: (scale) {
                    final decoration = _selectedDecoration;
                    if (decoration == null) {
                      return;
                    }
                    widget.gardenController.updateDecorationPlacement(
                      decoration,
                      scale: scale,
                    );
                  },
                  onLayerTap: () {
                    final decoration = _selectedDecoration;
                    if (decoration == null) {
                      return;
                    }
                    final current = garden.decorationPlacements[decoration];
                    HapticFeedback.selectionClick();
                    widget.gardenController.updateDecorationPlacement(
                      decoration,
                      inFront: !(current?.inFront ?? false),
                    );
                  },
                  onRemoveTap: () {
                    final decoration = _selectedDecoration;
                    if (decoration == null) {
                      return;
                    }
                    HapticFeedback.mediumImpact();
                    widget.gardenController.removeDecoration(decoration);
                    setState(() {
                      _selectedDecoration = null;
                    });
                  },
                ),
              ),
            if (_arrangingDecorations && _selectedArrangedPotIndex != null)
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom:
                    MediaQuery.paddingOf(context).bottom +
                    _bottomNavigationClearance +
                    AppSpacing.xl,
                child: const _PotArrangeHint(),
              ),
            if (selectedPot != null && !_arrangingDecorations)
              Positioned(
                left: 0,
                right: 0,
                bottom:
                    MediaQuery.paddingOf(context).bottom +
                    _bottomNavigationClearance,
                child: GardenPlantCard(
                  pot: selectedPot,
                  isHangingPot: garden.activeArea.isHangingPotSlot(
                    garden.selectedPotIndex ?? -1,
                  ),
                  water: garden.water,
                  unlockedPlantTypes: garden.unlockedPlantTypes,
                  ownedPotStyles: garden.ownedPotStyles,
                  onPrimaryAction:
                      widget.gardenController.performSelectedPotAction,
                  onPlantSelected: widget.gardenController.plantSelectedPot,
                  onPotStyleSelected: widget.gardenController.styleSelectedPot,
                  onRemovePlant: widget.gardenController.removeSelectedPlant,
                  onClose: widget.gardenController.closeSelectedPot,
                ),
              ),
            Positioned(
              top: 48,
              right: AppSpacing.xl,
              child: GardenResourceCounter(
                water: garden.water,
                coins: garden.coins,
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
            for (final reveal in _plantUnlockReveals)
              Positioned.fill(
                child: _PlantUnlockRevealOverlay(
                  key: ValueKey(reveal.id),
                  plantType: reveal.plantType,
                  onCompleted: () => _removePlantUnlockReveal(reveal.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DecorationArrangePanel extends StatelessWidget {
  const _DecorationArrangePanel({
    required this.maxScale,
    required this.placement,
    required this.onScaleChanged,
    required this.onLayerTap,
    required this.onRemoveTap,
  });

  final double maxScale;
  final GardenDecorationPlacement placement;
  final ValueChanged<double> onScaleChanged;
  final VoidCallback onLayerTap;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.graySoft.withValues(alpha: .5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.resize, size: 19, color: AppColors.sage),
            Expanded(
              child: CupertinoSlider(
                value: placement.scale.clamp(.65, maxScale).toDouble(),
                min: .65,
                max: maxScale,
                activeColor: AppColors.sage,
                thumbColor: AppColors.surface,
                onChanged: onScaleChanged,
              ),
            ),
            _PanelIconButton(
              icon: placement.inFront
                  ? CupertinoIcons.square_stack_3d_up_fill
                  : CupertinoIcons.square_stack_3d_down_right,
              label: placement.inFront ? 'Front' : 'Back',
              onTap: onLayerTap,
            ),
            const SizedBox(width: AppSpacing.xs),
            _PanelIconButton(
              icon: CupertinoIcons.archivebox,
              label: 'Store',
              destructive: true,
              onTap: onRemoveTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _PotArrangeHint extends StatelessWidget {
  const _PotArrangeHint();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.graySoft.withValues(alpha: .46)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: .06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.move, size: 17),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Drag pot to place it',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GardenAreaIndicator extends StatelessWidget {
  const _GardenAreaIndicator({required this.activeArea});

  final GardenArea activeArea;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .58),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.graySoft.withValues(alpha: .26)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final area in GardenArea.values) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: area == activeArea ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: area == activeArea
                        ? AppColors.charcoal
                        : AppColors.grayWarm.withValues(alpha: .36),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
                if (area != GardenArea.values.last)
                  const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelIconButton extends StatelessWidget {
  const _PanelIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    const destructiveColor = Color(0xFFD76A5D);
    final color = destructive ? destructiveColor : AppColors.charcoal;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: destructive
              ? destructiveColor.withValues(alpha: .08)
              : AppColors.graySoft.withValues(alpha: .28),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrangeDecorButton extends StatelessWidget {
  const _ArrangeDecorButton({required this.arranging, required this.onTap});

  final bool arranging;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.graySoft.withValues(alpha: .46)),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: .06),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(
            arranging ? CupertinoIcons.checkmark_alt : CupertinoIcons.move,
            size: 19,
            color: AppColors.charcoal,
          ),
        ),
      ),
    );
  }
}

class _SpaceShopButton extends StatelessWidget {
  const _SpaceShopButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.graySoft.withValues(alpha: .46)),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: .06),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: const Icon(
            CupertinoIcons.bag,
            size: 19,
            color: AppColors.charcoal,
          ),
        ),
      ),
    );
  }
}

class _CleanUpGardenButton extends StatelessWidget {
  const _CleanUpGardenButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.graySoft.withValues(alpha: .46)),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: .06),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: const Icon(
            CupertinoIcons.sparkles,
            size: 19,
            color: AppColors.charcoal,
          ),
        ),
      ),
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

class _PlantUnlockReveal {
  const _PlantUnlockReveal({required this.id, required this.plantType});

  final int id;
  final GardenPlantType plantType;
}

class _PlantUnlockRevealOverlay extends StatefulWidget {
  const _PlantUnlockRevealOverlay({
    super.key,
    required this.plantType,
    required this.onCompleted,
  });

  final GardenPlantType plantType;
  final VoidCallback onCompleted;

  @override
  State<_PlantUnlockRevealOverlay> createState() =>
      _PlantUnlockRevealOverlayState();
}

class _PlantUnlockRevealOverlayState extends State<_PlantUnlockRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _complete() {
    if (_completed) {
      return;
    }

    _completed = true;
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final entrance = Curves.easeOutBack.transform(
          (value / .72).clamp(0, 1),
        );
        final reveal = Curves.easeOutCubic.transform(
          ((value - .28) / .44).clamp(0, 1),
        );
        final y = 22 - entrance * 22;
        final scale = .88 + entrance * .12;

        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _complete,
                  child: ColoredBox(
                    color: AppColors.charcoal.withValues(alpha: .12 * value),
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: Offset(0, y),
                  child: Transform.scale(
                    scale: scale,
                    child: _PlantUnlockCard(
                      plantType: widget.plantType,
                      reveal: reveal,
                      onTap: _complete,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlantUnlockCard extends StatelessWidget {
  const _PlantUnlockCard({
    required this.plantType,
    required this.reveal,
    required this.onTap,
  });

  final GardenPlantType plantType;
  final double reveal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: .98),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: AppColors.sage.withValues(alpha: .22)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: .14),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _UnlockEyebrow(reveal: reveal),
                const SizedBox(height: AppSpacing.sm),
                _PlantRevealIcon(plantType: plantType, reveal: reveal),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  plantType.displayName,
                  style: AppTextStyles.headline.copyWith(fontSize: 34),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ready to plant',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grayWarm,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _UnlockDetailChip(
                        leading: const GardenCoinIcon(size: 22),
                        title: '+${plantType.coinReward}',
                        caption: plantType.coinDropIntervalLabel,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _UnlockDetailChip(
                        leading: const Icon(
                          CupertinoIcons.leaf_arrow_circlepath,
                          color: AppColors.sage,
                          size: 21,
                        ),
                        title: plantType.specialLabel,
                        caption: _unlockBenefitCaption(plantType),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Tap anywhere to continue',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grayWarm.withValues(alpha: .78),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _unlockBenefitCaption(GardenPlantType plantType) {
  return switch (plantType) {
    GardenPlantType.daisy => 'starter',
    GardenPlantType.tulip => 'bigger drops',
    GardenPlantType.clover => 'double chance',
    GardenPlantType.sunflower => 'big payout',
    GardenPlantType.hangingFlower => 'hanging pot',
  };
}

class _UnlockEyebrow extends StatelessWidget {
  const _UnlockEyebrow({required this.reveal});

  final double reveal;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.sageSoft.withValues(alpha: .72 + reveal * .18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.sage.withValues(alpha: .2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          'Seed unlocked',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.sagePressed,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _PlantRevealIcon extends StatelessWidget {
  const _PlantRevealIcon({required this.plantType, required this.reveal});

  final GardenPlantType plantType;
  final double reveal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 132,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.sageSoft.withValues(alpha: .9),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sage.withValues(alpha: .18)),
            ),
            child: const SizedBox.square(dimension: 118),
          ),
          Transform.scale(
            scale: .9 + reveal * .16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              child: reveal < .45
                  ? const _RevealQuestionMark(key: ValueKey('question'))
                  : Image.asset(
                      plantType.previewAsset,
                      key: ValueKey(plantType),
                      width: 108,
                      height: 108,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevealQuestionMark extends StatelessWidget {
  const _RevealQuestionMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '?',
      style: AppTextStyles.headline.copyWith(
        color: AppColors.grayWarm,
        fontSize: 62,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _UnlockDetailChip extends StatelessWidget {
  const _UnlockDetailChip({
    required this.leading,
    required this.title,
    required this.caption,
  });

  final Widget leading;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: .54),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.graySoft.withValues(alpha: .46)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grayWarm,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
