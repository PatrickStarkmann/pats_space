import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/widgets/garden_coin_icon.dart';

class GardenPlantCard extends StatefulWidget {
  const GardenPlantCard({
    super.key,
    required this.pot,
    required this.onPrimaryAction,
    required this.onPlantSelected,
    required this.onRemovePlant,
    required this.onClose,
  });

  final GardenPot pot;
  final VoidCallback onPrimaryAction;
  final ValueChanged<GardenPlantType> onPlantSelected;
  final VoidCallback onRemovePlant;
  final VoidCallback onClose;

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
                    onPlantSelected: widget.onPlantSelected,
                  )
                else
                  _PlantInfoContent(
                    pot: widget.pot,
                    onPrimaryAction: widget.onPrimaryAction,
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
  const _PlantSelectionContent({required this.onPlantSelected});

  final ValueChanged<GardenPlantType> onPlantSelected;

  @override
  State<_PlantSelectionContent> createState() => _PlantSelectionContentState();
}

class _PlantSelectionContentState extends State<_PlantSelectionContent> {
  late final PageController _pageController;
  GardenPlantType _selectedPlantType = GardenPlantType.daisy;
  int _lastHapticIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: .46);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose plant', style: AppTextStyles.headline),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 208,
          child: PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: GardenPlantType.plantable.length,
            onPageChanged: (index) {
              if (index != _lastHapticIndex) {
                _lastHapticIndex = index;
                HapticFeedback.selectionClick();
              }
              setState(() {
                _selectedPlantType = GardenPlantType.plantable[index];
              });
            },
            itemBuilder: (context, index) {
              final plantType = GardenPlantType.plantable[index];

              return _PlantCarouselCard(
                controller: _pageController,
                index: index,
                plantType: plantType,
                selected: plantType == _selectedPlantType,
                onTap: () {
                  if (index != _lastHapticIndex) {
                    _lastHapticIndex = index;
                    HapticFeedback.selectionClick();
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
        _PlantPickerStats(plantType: _selectedPlantType),
        const SizedBox(height: AppSpacing.md),
        _PlantPickerPrimaryButton(
          plantType: _selectedPlantType,
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onPlantSelected(_selectedPlantType);
          },
        ),
      ],
    );
  }
}

class _PlantCarouselCard extends StatelessWidget {
  const _PlantCarouselCard({
    required this.controller,
    required this.index,
    required this.plantType,
    required this.selected,
    required this.onTap,
  });

  final PageController controller;
  final int index;
  final GardenPlantType plantType;
  final bool selected;
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
        label: plantType.displayName,
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
                  : AppColors.surfaceMuted.withValues(alpha: .56),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: selected
                    ? AppColors.sage
                    : AppColors.graySoft.withValues(alpha: .34),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
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
                    opacity: selected ? 1 : 0,
                    child: const Icon(
                      CupertinoIcons.checkmark_alt_circle_fill,
                      color: AppColors.sage,
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
                          child: Image.asset(
                            plantType.previewAsset,
                            key: ValueKey(plantType),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        plantType.displayName,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }
}

class _PlantPickerStats extends StatelessWidget {
  const _PlantPickerStats({required this.plantType});

  final GardenPlantType plantType;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: DecoratedBox(
        key: ValueKey(plantType),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted.withValues(alpha: .46),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _PickerStatItem(
                leading: const GardenCoinIcon(size: 22),
                label: '+${plantType.coinReward} coins',
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 1,
                height: 24,
                color: AppColors.graySoft.withValues(alpha: .54),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PickerStatItem(
                  leading: const Icon(
                    CupertinoIcons.sparkles,
                    size: 20,
                    color: AppColors.sage,
                  ),
                  label: plantType.specialLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerStatItem extends StatelessWidget {
  const _PickerStatItem({required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PlantPickerPrimaryButton extends StatelessWidget {
  const _PlantPickerPrimaryButton({
    required this.plantType,
    required this.onTap,
  });

  final GardenPlantType plantType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Plant ${plantType.displayName}',
      child: _PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: .18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.plus,
                size: 20,
                color: AppColors.surface,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  'Plant ${plantType.displayName}',
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

class _PlantInfoContent extends StatelessWidget {
  const _PlantInfoContent({
    required this.pot,
    required this.onPrimaryAction,
    required this.onRemovePlant,
  });

  final GardenPot pot;
  final VoidCallback onPrimaryAction;
  final VoidCallback onRemovePlant;

  @override
  Widget build(BuildContext context) {
    final stage = pot.stage;
    final caption = switch (stage) {
      GardenGrowthStage.bloom =>
        '${pot.remainingBloomCollections} collects left',
      GardenGrowthStage.dry => 'Needs water to recover',
      _ => 'Water to grow',
    };
    final buttonLabel = switch (stage) {
      GardenGrowthStage.bloom => 'Collect',
      _ => 'Water',
    };
    final buttonIcon = switch (stage) {
      GardenGrowthStage.bloom => null,
      _ => CupertinoIcons.drop,
    };
    final buttonLeading = stage.hasCoins
        ? const GardenCoinIcon(size: 20)
        : null;

    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _PlantPreview(assetPath: pot.plantAsset),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pot.plantName, style: AppTextStyles.headline),
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
                            stage.statusLabel,
                            style: AppTextStyles.bodyMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (stage.hasCoins)
                      _CoinRewardProgress(pot: pot)
                    else
                      _WaterProgress(
                        count: pot.waterProgress,
                        total: pot.waterRequired,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(caption, style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.md),
                    _GardenCardButton(
                      label: buttonLabel,
                      icon: buttonIcon,
                      leading: buttonLeading,
                      onTap: onPrimaryAction,
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
          child: _RemovePlantButton(onTap: onRemovePlant),
        ),
      ],
    );
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

class _WaterProgress extends StatelessWidget {
  const _WaterProgress({required this.count, required this.total});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final visibleTotal = total == 0 ? 3 : total;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(visibleTotal, (index) {
            final filled = index < count;
            final isLast = index == visibleTotal - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.xxs),
              child: Icon(
                CupertinoIcons.drop,
                size: 20,
                color: filled ? const Color(0xFF6FAAF7) : AppColors.graySoft,
              ),
            );
          }),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text('$count/$visibleTotal', style: AppTextStyles.caption),
      ],
    );
  }
}

class _CoinRewardProgress extends StatelessWidget {
  const _CoinRewardProgress({required this.pot});

  final GardenPot pot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const GardenCoinIcon(size: 24),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '+${pot.coinReward}',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
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
    return Semantics(
      button: true,
      label: 'Remove plant',
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
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFEAF7FF),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null)
                leading!
              else if (icon != null)
                Icon(icon, size: 20, color: const Color(0xFF5D9EEA)),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
