import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';
import 'package:pats_space/features/space/widgets/garden_coin_icon.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

String _plantName(AppLocalizations l10n, GardenPlantType plantType) {
  return switch (plantType) {
    GardenPlantType.daisy => l10n.plantDaisy,
    GardenPlantType.tulip => l10n.plantTulip,
    GardenPlantType.clover => l10n.plantClover,
    GardenPlantType.sunflower => l10n.plantSunflower,
    GardenPlantType.hangingFlower => l10n.plantHangingFlower,
    GardenPlantType.cherryBlossom => l10n.plantCherryBlossom,
    GardenPlantType.strawberry => l10n.plantStrawberry,
  };
}

String _plantCardName(AppLocalizations l10n, GardenPlantType plantType) {
  final name = _plantName(l10n, plantType);
  return switch (plantType) {
    GardenPlantType.daisy => name.replaceFirst('Gänse', 'Gänse\u200B'),
    GardenPlantType.sunflower => name.replaceFirst('Sonnen', 'Sonnen\u200B'),
    GardenPlantType.hangingFlower => name.replaceFirst('Hänge', 'Hänge\u200B'),
    _ => name,
  };
}

String _plantSpecialLabel(AppLocalizations l10n, GardenPlantType plantType) {
  return switch (plantType) {
    GardenPlantType.daisy => l10n.plantSpecialStarter,
    GardenPlantType.tulip => l10n.plantSpecialBonus,
    GardenPlantType.clover => l10n.plantSpecialLucky,
    GardenPlantType.sunflower => l10n.plantSpecialJackpot,
    GardenPlantType.hangingFlower => l10n.plantSpecialHanging,
    GardenPlantType.cherryBlossom => l10n.plantSpecialPetalRain,
    GardenPlantType.strawberry => l10n.plantSpecialStoredHarvest,
  };
}

String _plantSpecialDescription(
  AppLocalizations l10n,
  GardenPlantType plantType,
) {
  return switch (plantType) {
    GardenPlantType.daisy => '',
    GardenPlantType.tulip => l10n.plantDescriptionBonus,
    GardenPlantType.clover => l10n.plantDescriptionLucky,
    GardenPlantType.sunflower => l10n.plantDescriptionJackpot,
    GardenPlantType.hangingFlower => l10n.plantDescriptionHanging,
    GardenPlantType.cherryBlossom => l10n.plantDescriptionPetalRain,
    GardenPlantType.strawberry => l10n.plantDescriptionStoredHarvest,
  };
}

String _potStyleName(AppLocalizations l10n, GardenPotStyle style) {
  return switch (style) {
    GardenPotStyle.classic => l10n.potClassic,
    GardenPotStyle.blue => l10n.potBlue,
    GardenPotStyle.colorful => l10n.potColorful,
    GardenPotStyle.hanging => l10n.potHanging,
    GardenPotStyle.round => l10n.potRound,
    GardenPotStyle.white => l10n.potWhite,
    GardenPotStyle.frog => l10n.potFrog,
    GardenPotStyle.cloud => l10n.potCloud,
  };
}

String _growthStageStatus(AppLocalizations l10n, GardenGrowthStage stage) {
  return switch (stage) {
    GardenGrowthStage.empty => l10n.growthStageEmpty,
    GardenGrowthStage.seed => l10n.growthStageSeed,
    GardenGrowthStage.sprout => l10n.growthStageSprout,
    GardenGrowthStage.bud => l10n.growthStageBud,
    GardenGrowthStage.bloom => l10n.growthStageBloom,
    GardenGrowthStage.dry => l10n.growthStageDry,
  };
}

class GardenPlantCard extends StatefulWidget {
  const GardenPlantCard({
    super.key,
    required this.pot,
    required this.isHangingPot,
    required this.water,
    required this.unlockedPlantTypes,
    required this.ownedPotStyles,
    required this.hasPro,
    required this.onPrimaryAction,
    required this.onWaterEmpty,
    required this.onPlantSelected,
    required this.onPotStyleSelected,
    required this.onRemovePlant,
    required this.onClose,
    required this.onProRequested,
  });

  final GardenPot pot;
  final bool isHangingPot;
  final int water;
  final Set<GardenPlantType> unlockedPlantTypes;
  final Set<GardenPotStyle> ownedPotStyles;
  final bool hasPro;
  final VoidCallback onPrimaryAction;
  final VoidCallback onWaterEmpty;
  final ValueChanged<GardenPlantType> onPlantSelected;
  final ValueChanged<GardenPotStyle> onPotStyleSelected;
  final VoidCallback onRemovePlant;
  final VoidCallback onClose;
  final VoidCallback onProRequested;

  @override
  State<GardenPlantCard> createState() => _GardenPlantCardState();
}

class _GardenPlantCardState extends State<GardenPlantCard> {
  static const _dismissDistance = 96.0;
  static const _dismissVelocity = 520.0;

  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void didUpdateWidget(covariant GardenPlantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pot.stage != widget.pot.stage) {
      _dragOffset = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset + details.delta.dy).clamp(0, 260);
        });
      },
      onVerticalDragEnd: (details) {
        _isDragging = false;
        final velocity = details.primaryVelocity ?? 0;
        if (_dragOffset > _dismissDistance || velocity > _dismissVelocity) {
          widget.onClose();
          return;
        }

        setState(() {
          _dragOffset = 0;
        });
      },
      onVerticalDragCancel: () {
        setState(() {
          _isDragging = false;
          _dragOffset = 0;
        });
      },
      child: AnimatedContainer(
        duration: _isDragging
            ? Duration.zero
            : const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _dragOffset, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: .92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: .08),
                blurRadius: 28,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32,
                  child: Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onClose,
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.graySoft,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (widget.pot.isEmpty)
                  _PlantSelectionContent(
                    pot: widget.pot,
                    isHangingPot: widget.isHangingPot,
                    water: widget.water,
                    unlockedPlantTypes: widget.unlockedPlantTypes,
                    ownedPotStyles: widget.ownedPotStyles,
                    hasPro: widget.hasPro,
                    onPlantSelected: widget.onPlantSelected,
                    onWaterEmpty: widget.onWaterEmpty,
                    onPotStyleSelected: widget.onPotStyleSelected,
                    onProRequested: widget.onProRequested,
                  )
                else
                  _PlantInfoContent(
                    pot: widget.pot,
                    isHangingPot: widget.isHangingPot,
                    ownedPotStyles: widget.ownedPotStyles,
                    onPrimaryAction: widget.onPrimaryAction,
                    onPotStyleSelected: widget.onPotStyleSelected,
                    onRemovePlant: widget.onRemovePlant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantSelectionContent extends StatefulWidget {
  const _PlantSelectionContent({
    required this.pot,
    required this.isHangingPot,
    required this.water,
    required this.unlockedPlantTypes,
    required this.ownedPotStyles,
    required this.hasPro,
    required this.onPlantSelected,
    required this.onWaterEmpty,
    required this.onPotStyleSelected,
    required this.onProRequested,
  });

  final GardenPot pot;
  final bool isHangingPot;
  final int water;
  final Set<GardenPlantType> unlockedPlantTypes;
  final Set<GardenPotStyle> ownedPotStyles;
  final bool hasPro;
  final ValueChanged<GardenPlantType> onPlantSelected;
  final VoidCallback onWaterEmpty;
  final ValueChanged<GardenPotStyle> onPotStyleSelected;
  final VoidCallback onProRequested;

  @override
  State<_PlantSelectionContent> createState() => _PlantSelectionContentState();
}

class _PlantSelectionContentState extends State<_PlantSelectionContent> {
  late final PageController _pageController;
  GardenPlantType _selectedPlantType = GardenPlantType.daisy;
  int _lastHapticIndex = 0;

  List<GardenPlantType> get _availablePlantTypes => widget.isHangingPot
      ? GardenPlantType.hangingPlantable
      : GardenPlantType.groundPlantable;

  @override
  void initState() {
    super.initState();
    _selectedPlantType = _availablePlantTypes.first;
    _pageController = PageController(viewportFraction: .46);
  }

  @override
  void didUpdateWidget(covariant _PlantSelectionContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_availablePlantTypes.contains(_selectedPlantType)) {
      return;
    }

    _selectedPlantType = _availablePlantTypes.first;
    _lastHapticIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plantTypes = _availablePlantTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.choosePlant, style: AppTextStyles.headline),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 208,
          child: PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: plantTypes.length,
            onPageChanged: (index) {
              if (index != _lastHapticIndex) {
                _lastHapticIndex = index;
                AppHaptics.selection();
              }
              setState(() {
                _selectedPlantType = plantTypes[index];
              });
            },
            itemBuilder: (context, index) {
              final plantType = plantTypes[index];
              final unlocked = _isPlantAvailable(plantType);

              return _PlantCarouselCard(
                controller: _pageController,
                index: index,
                plantType: plantType,
                selected: plantType == _selectedPlantType,
                unlocked: unlocked,
                isProLocked: _isProLocked(plantType),
                onTap: () {
                  if (index != _lastHapticIndex) {
                    _lastHapticIndex = index;
                    AppHaptics.selection();
                  }
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _PlantPickerStats(
          plantType: _selectedPlantType,
          unlocked: _isPlantAvailable(_selectedPlantType),
          isProLocked: _isProLocked(_selectedPlantType),
        ),
        if (!widget.isHangingPot) ...[
          const SizedBox(height: AppSpacing.md),
          _PotStyleSelector(
            selectedStyle: widget.pot.potStyle,
            ownedStyles: widget.ownedPotStyles,
            onStyleSelected: widget.onPotStyleSelected,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _PlantPickerPrimaryButton(
          plantType: _selectedPlantType,
          unlocked: _isPlantAvailable(_selectedPlantType),
          enabled:
              _isProLocked(_selectedPlantType) ||
              (_isPlantAvailable(_selectedPlantType) &&
                  widget.water >= _selectedPlantType.plantCost),
          onTap: () {
            AppHaptics.lightImpact();
            if (_isProLocked(_selectedPlantType)) {
              widget.onProRequested();
              return;
            }
            widget.onPlantSelected(_selectedPlantType);
          },
          onWaterEmpty: _isPlantAvailable(_selectedPlantType)
              ? widget.onWaterEmpty
              : null,
          isProLocked: _isProLocked(_selectedPlantType),
        ),
      ],
    );
  }

  bool _isPlantAvailable(GardenPlantType plantType) =>
      !plantType.isPro ||
      widget.hasPro ||
      widget.unlockedPlantTypes.contains(plantType);

  bool _isProLocked(GardenPlantType plantType) =>
      plantType.isPro &&
      !widget.hasPro &&
      !widget.unlockedPlantTypes.contains(plantType);
}

class _PlantCarouselCard extends StatelessWidget {
  const _PlantCarouselCard({
    required this.controller,
    required this.index,
    required this.plantType,
    required this.selected,
    required this.unlocked,
    this.isProLocked = false,
    required this.onTap,
  });

  final PageController controller;
  final int index;
  final GardenPlantType plantType;
  final bool selected;
  final bool unlocked;
  final bool isProLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final page = controller.hasClients && controller.page != null
            ? controller.page!
            : controller.initialPage.toDouble();
        final distance = (page - index).abs().clamp(0.0, 1.0);
        final scale = 1 - distance * .08;
        final lift = distance * 10;

        return Transform.translate(
          offset: Offset(0, lift),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Semantics(
        button: true,
        selected: selected,
        label: unlocked
            ? _plantName(AppLocalizations.of(context), plantType)
            : AppLocalizations.of(context).mysteryPlant,
        child: _PressableScale(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.surface
                  : unlocked
                  ? AppColors.surfaceMuted.withValues(alpha: .56)
                  : AppColors.surfaceMuted.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: !unlocked
                    ? AppColors.graySoft.withValues(alpha: .7)
                    : selected
                    ? AppColors.sage
                    : AppColors.graySoft.withValues(alpha: .34),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected && unlocked
                  ? [
                      BoxShadow(
                        color: AppColors.charcoal.withValues(alpha: .08),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                      BoxShadow(
                        color: AppColors.sage.withValues(alpha: .18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: selected || !unlocked ? 1 : 0,
                    child: Icon(
                      isProLocked
                          ? CupertinoIcons.lock_fill
                          : unlocked
                          ? CupertinoIcons.checkmark_alt_circle_fill
                          : CupertinoIcons.lock_fill,
                      color: unlocked ? AppColors.sage : AppColors.grayWarm,
                      size: 22,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutBack,
                          child: unlocked
                              ? Image.asset(
                                  plantType.previewAsset,
                                  key: ValueKey(plantType),
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                )
                              : const _MysteryPlantMark(
                                  key: ValueKey('mystery-plant'),
                                ),
                        ),
                      ),
                      if (unlocked) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _plantCardName(
                            AppLocalizations.of(context),
                            plantType,
                          ),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
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

class _MysteryPlantMark extends StatelessWidget {
  const _MysteryPlantMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .78),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.graySoft.withValues(alpha: .7),
            width: 1.4,
          ),
        ),
        child: SizedBox.square(
          dimension: 78,
          child: Center(
            child: Text(
              '?',
              style: AppTextStyles.headline.copyWith(
                color: AppColors.grayWarm,
                fontSize: 44,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantPickerStats extends StatelessWidget {
  const _PlantPickerStats({
    required this.plantType,
    required this.unlocked,
    this.isProLocked = false,
  });

  final GardenPlantType plantType;
  final bool unlocked;
  final bool isProLocked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Row(
        key: ValueKey((plantType, unlocked)),
        children: [
          if (unlocked) ...[
            _PickerStatChip(
              leading: const GardenCoinIcon(size: 22),
              label: '+${plantType.coinReward}',
            ),
            const SizedBox(width: AppSpacing.xs),
            _PickerStatChip(
              leading: const Icon(
                CupertinoIcons.timer,
                size: 18,
                color: AppColors.grayWarm,
              ),
              label: '/${plantType.coinDropIntervalLabel}',
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _PickerStatChip(
                leading: const Icon(
                  CupertinoIcons.sparkles,
                  size: 18,
                  color: AppColors.sage,
                ),
                label: _plantSpecialLabel(l10n, plantType),
              ),
            ),
          ] else if (isProLocked)
            const Expanded(
              child: _UnlockHint(
                leading: Icon(
                  CupertinoIcons.lock_fill,
                  size: 18,
                  color: AppColors.grayWarm,
                ),
                label: 'Pats Space Pro',
              ),
            )
          else
            Expanded(
              child: _UnlockHint(
                leading: const Icon(
                  CupertinoIcons.lock_fill,
                  size: 18,
                  color: AppColors.grayWarm,
                ),
                label: plantType.unlockRequirement == null
                    ? l10n.plantUnlocked
                    : l10n.plantBloomRequirement(
                        _plantName(l10n, plantType.unlockRequirement!),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnlockHint extends StatelessWidget {
  const _UnlockHint({required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.graySoft.withValues(alpha: .42)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerStatChip extends StatelessWidget {
  const _PickerStatChip({required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: AppColors.graySoft.withValues(alpha: .58),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: .06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantPickerPrimaryButton extends StatelessWidget {
  const _PlantPickerPrimaryButton({
    required this.plantType,
    required this.unlocked,
    required this.enabled,
    required this.onTap,
    this.isProLocked = false,
    this.onWaterEmpty,
  });

  final GardenPlantType plantType;
  final bool unlocked;
  final bool enabled;
  final VoidCallback onTap;
  final bool isProLocked;
  final VoidCallback? onWaterEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final proLabel = Localizations.localeOf(context).languageCode == 'de'
        ? 'Pats Space Pro freischalten'
        : 'Unlock Pats Space Pro';
    return Semantics(
      button: true,
      enabled: enabled,
      label: isProLocked
          ? proLabel
          : l10n.plantAction(_plantName(l10n, plantType)),
      child: _PressableScale(
        onTap: enabled
            ? onTap
            : () {
                AppHaptics.error();
                onWaterEmpty?.call();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          decoration: BoxDecoration(
            color: enabled ? AppColors.charcoal : AppColors.graySoft,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.charcoal.withValues(alpha: .18),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isProLocked
                    ? CupertinoIcons.lock_fill
                    : unlocked
                    ? enabled
                          ? CupertinoIcons.drop_fill
                          : CupertinoIcons.drop
                    : CupertinoIcons.lock_fill,
                size: 20,
                color: AppColors.surface,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  isProLocked
                      ? proLabel
                      : unlocked
                      ? enabled
                            ? l10n.plantActionWithCost(plantType.plantCost)
                            : l10n.plantNeedWater(plantType.plantCost)
                      : l10n.plantLocked,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PotStyleSelector extends StatelessWidget {
  const _PotStyleSelector({
    required this.selectedStyle,
    required this.ownedStyles,
    required this.onStyleSelected,
  });

  final GardenPotStyle selectedStyle;
  final Set<GardenPotStyle> ownedStyles;
  final ValueChanged<GardenPotStyle> onStyleSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final styles = [
      GardenPotStyle.classic,
      ...GardenPotStyle.shopStyles.where(ownedStyles.contains),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.potSkin,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.grayWarm,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 62,
          child: ListView.separated(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: styles.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              final style = styles[index];
              return _PotStyleChip(
                style: style,
                selected: style == selectedStyle,
                onTap: () {
                  AppHaptics.selection();
                  onStyleSelected(style);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PotStyleChip extends StatelessWidget {
  const _PotStyleChip({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final GardenPotStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: _potStyleName(AppLocalizations.of(context), style),
      child: _PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 58,
          decoration: BoxDecoration(
            color: selected ? AppColors.sageSoft : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: selected
                  ? AppColors.sage
                  : AppColors.graySoft.withValues(alpha: .5),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.sage.withValues(alpha: .16),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(7),
          child: Image.asset(
            style.assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _PlantInfoContent extends StatefulWidget {
  const _PlantInfoContent({
    required this.pot,
    required this.isHangingPot,
    required this.ownedPotStyles,
    required this.onPrimaryAction,
    required this.onPotStyleSelected,
    required this.onRemovePlant,
  });

  final GardenPot pot;
  final bool isHangingPot;
  final Set<GardenPotStyle> ownedPotStyles;
  final VoidCallback onPrimaryAction;
  final ValueChanged<GardenPotStyle> onPotStyleSelected;
  final VoidCallback onRemovePlant;

  @override
  State<_PlantInfoContent> createState() => _PlantInfoContentState();
}

class _PlantInfoContentState extends State<_PlantInfoContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _actionFeedbackController;
  Timer? _cooldownTimer;
  bool _showGrowthBurst = false;

  @override
  void initState() {
    super.initState();
    _actionFeedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _syncCooldownTimer();
  }

  @override
  void didUpdateWidget(covariant _PlantInfoContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPot = oldWidget.pot;
    final pot = widget.pot;
    final changed =
        oldPot.stage != pot.stage ||
        oldPot.waterProgress != pot.waterProgress ||
        oldPot.bloomCollections != pot.bloomCollections;

    if (!changed) {
      _syncCooldownTimer();
      return;
    }

    _showGrowthBurst = oldPot.stage != pot.stage || pot.stage.hasCoins;
    _syncCooldownTimer();
    _actionFeedbackController.forward(from: 0);
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _actionFeedbackController.dispose();
    super.dispose();
  }

  void _syncCooldownTimer() {
    final needsCountdown =
        widget.pot.stage.hasCoins && !widget.pot.hasCollectableCoins;
    if (!needsCountdown) {
      _cooldownTimer?.cancel();
      _cooldownTimer = null;
      return;
    }

    if (_cooldownTimer != null) {
      return;
    }

    _cooldownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _performPrimaryAction() {
    final pot = widget.pot;
    if (pot.stage.hasCoins && !pot.hasCollectableCoins) {
      AppHaptics.error();
      return;
    }

    if (pot.stage.hasCoins) {
      AppHaptics.reward();
    } else if (pot.isReadyToGrow) {
      AppHaptics.mediumImpact();
    } else {
      AppHaptics.lightImpact();
    }
    widget.onPrimaryAction();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pot = widget.pot;
    final stage = pot.stage;
    final nextDropLabel = _nextDropLabel(l10n, pot);
    final caption = switch (stage) {
      GardenGrowthStage.bloom =>
        pot.hasCollectableCoins
            ? l10n.readyToHarvest(pot.remainingBloomCollections)
            : l10n.nextDropIn(nextDropLabel),
      GardenGrowthStage.dry => l10n.needsWaterToRecover,
      _ => l10n.waterToGrow,
    };
    final buttonLabel = switch (stage) {
      GardenGrowthStage.bloom =>
        pot.hasCollectableCoins ? l10n.collect : l10n.waiting,
      _ => l10n.water,
    };
    final buttonIcon = switch (stage) {
      GardenGrowthStage.bloom =>
        pot.hasCollectableCoins ? null : CupertinoIcons.clock,
      _ => CupertinoIcons.drop,
    };
    final buttonLeading = stage.hasCoins && pot.hasCollectableCoins
        ? const GardenCoinIcon(size: 20)
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ReactivePlantPreview(
                  assetPath: pot.plantAsset,
                  controller: _actionFeedbackController,
                  showGrowthBurst: _showGrowthBurst,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _plantCardName(l10n, pot.plantType),
                          style: AppTextStyles.headline,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.sage,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                _growthStageStatus(l10n, stage),
                                style: AppTextStyles.bodyMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (stage.hasCoins)
                          _BloomInfoBlock(pot: pot)
                        else
                          _ProgressBlock(
                            label: stage.isDry
                                ? l10n.recoveryProgress
                                : l10n.growthProgress,
                            child: _WaterProgress(
                              count: pot.waterProgress,
                              total: pot.waterRequired,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(caption, style: AppTextStyles.caption),
                        const SizedBox(height: AppSpacing.sm),
                        _GardenCardButton(
                          label: buttonLabel,
                          icon: buttonIcon,
                          leading: buttonLeading,
                          secondary: true,
                          onTap: _performPrimaryAction,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _RemovePlantButton(onTap: widget.onRemovePlant),
            ),
          ],
        ),
        if (!widget.isHangingPot) ...[
          const SizedBox(height: AppSpacing.md),
          _PotStyleSelector(
            selectedStyle: pot.potStyle,
            ownedStyles: widget.ownedPotStyles,
            onStyleSelected: widget.onPotStyleSelected,
          ),
        ],
      ],
    );
  }

  String _nextDropLabel(AppLocalizations l10n, GardenPot pot) {
    final remaining = pot.remainingCoinDropTime(
      pot.plantType.coinDropInterval,
      DateTime.now(),
    );
    if (remaining == Duration.zero) {
      return l10n.soon;
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    if (hours > 0) {
      return l10n.hoursMinutesShort(hours, minutes);
    }

    return l10n.minutesShort(math.max(1, minutes));
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _PlantPreview extends StatelessWidget {
  const _PlantPreview({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 116,
      decoration: const BoxDecoration(
        color: AppColors.sageSoft,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _ReactivePlantPreview extends StatelessWidget {
  const _ReactivePlantPreview({
    required this.assetPath,
    required this.controller,
    required this.showGrowthBurst,
  });

  final String assetPath;
  final Animation<double> controller;
  final bool showGrowthBurst;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = controller.value;
        final bounce = value < .5 ? value / .5 : (1 - value) / .5;
        final scale = 1 + bounce * .08;

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Transform.scale(scale: scale, child: child),
            if (value > 0)
              _ActionFeedbackBurst(
                progress: value,
                showGrowthBurst: showGrowthBurst,
              ),
          ],
        );
      },
      child: _PlantPreview(assetPath: assetPath),
    );
  }
}

class _ActionFeedbackBurst extends StatelessWidget {
  const _ActionFeedbackBurst({
    required this.progress,
    required this.showGrowthBurst,
  });

  final double progress;
  final bool showGrowthBurst;

  @override
  Widget build(BuildContext context) {
    final opacity = progress < .2
        ? progress / .2
        : (1 - progress).clamp(0.0, 1.0);
    final y = -28 * Curves.easeOutCubic.transform(progress);

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _BurstIcon(
              icon: showGrowthBurst
                  ? CupertinoIcons.sparkles
                  : CupertinoIcons.drop_fill,
              color: showGrowthBurst
                  ? AppColors.accentWarm
                  : const Color(0xFF6FAAF7),
              offset: Offset(-34, y - 18),
              size: showGrowthBurst ? 24 : 20,
            ),
            _BurstIcon(
              icon: showGrowthBurst
                  ? CupertinoIcons.sparkles
                  : CupertinoIcons.drop_fill,
              color: showGrowthBurst ? AppColors.sage : const Color(0xFF8BC5FF),
              offset: Offset(32, y - 6),
              size: showGrowthBurst ? 18 : 16,
            ),
            _BurstIcon(
              icon: showGrowthBurst
                  ? CupertinoIcons.sparkles
                  : CupertinoIcons.drop_fill,
              color: showGrowthBurst
                  ? AppColors.accentWarm
                  : const Color(0xFFB9DFFF),
              offset: Offset(4, y - 36),
              size: showGrowthBurst ? 14 : 13,
            ),
          ],
        ),
      ),
    );
  }
}

class _BurstIcon extends StatelessWidget {
  const _BurstIcon({
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

class _WaterProgress extends StatelessWidget {
  const _WaterProgress({required this.count, required this.total});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final visibleTotal = total == 0 ? 3 : total;
    final progress = visibleTotal == 0
        ? 0.0
        : (count / visibleTotal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.drop_fill,
              size: 18,
              color: Color(0xFF6FAAF7),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('$count/$visibleTotal', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: SizedBox(
            height: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.graySoft.withValues(alpha: .42),
                      ),
                      child: const SizedBox.expand(),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: progress),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: constraints.maxWidth * value,
                            child: child,
                          ),
                        );
                      },
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFF6FAAF7)),
                        child: SizedBox.expand(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.grayWarm.withValues(alpha: .78),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _BloomInfoBlock extends StatelessWidget {
  const _BloomInfoBlock({required this.pot});

  final GardenPot pot;

  @override
  Widget build(BuildContext context) {
    final plantType = pot.plantType;
    final l10n = AppLocalizations.of(context);
    final specialDescription = _plantSpecialDescription(l10n, plantType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BloomInfoRow(
          leading: const GardenCoinIcon(size: 22),
          text: l10n.coinsEvery(
            plantType.coinReward,
            plantType.coinDropIntervalLabel,
          ),
          emphasis: true,
        ),
        if (specialDescription.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          _BloomInfoRow(
            leading: const Icon(
              CupertinoIcons.sparkles,
              size: 17,
              color: AppColors.sage,
            ),
            text: specialDescription,
          ),
        ],
      ],
    );
  }
}

class _BloomInfoRow extends StatelessWidget {
  const _BloomInfoRow({
    required this.leading,
    required this.text,
    this.emphasis = false,
  });

  final Widget leading;
  final String text;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: emphasis ? AppColors.charcoal : AppColors.grayWarm,
              fontWeight: emphasis ? FontWeight.w800 : FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _RemovePlantButton extends StatelessWidget {
  const _RemovePlantButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.removePlant,
      child: _PressableScale(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted.withValues(alpha: .72),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.delete,
            size: 18,
            color: AppColors.grayWarm.withValues(alpha: .82),
          ),
        ),
      ),
    );
  }
}

class _GardenCardButton extends StatelessWidget {
  const _GardenCardButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.leading,
    this.secondary = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? leading;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final iconColor = secondary ? AppColors.grayWarm : const Color(0xFF5D9EEA);
    final background = secondary
        ? AppColors.surfaceMuted.withValues(alpha: .58)
        : const Color(0xFFEAF7FF);
    final textStyle = secondary
        ? AppTextStyles.caption.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          )
        : AppTextStyles.body;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: secondary ? AppSpacing.md : AppSpacing.lg,
            vertical: secondary ? AppSpacing.xs : AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null)
                leading!
              else if (icon != null)
                Icon(icon, size: secondary ? 17 : 20, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
