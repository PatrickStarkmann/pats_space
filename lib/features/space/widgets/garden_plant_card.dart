import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/widgets/garden_coin_icon.dart';

class GardenPlantCard extends StatefulWidget {
  const GardenPlantCard({
    super.key,
    required this.pot,
    required this.onPrimaryAction,
    required this.onRemovePlant,
    required this.onClose,
  });

  final GardenPot pot;
  final VoidCallback onPrimaryAction;
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
                    plantName: widget.pot.plantName,
                    onPlant: widget.onPrimaryAction,
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

class _PlantSelectionContent extends StatelessWidget {
  const _PlantSelectionContent({
    required this.plantName,
    required this.onPlant,
  });

  final String plantName;
  final VoidCallback onPlant;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _PlantPreview(assetPath: AppAssets.gardenPlantBloom),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose plant', style: AppTextStyles.headline),
              const SizedBox(height: AppSpacing.xs),
              Text(plantName, style: AppTextStyles.bodyMuted),
              const SizedBox(height: AppSpacing.md),
              _GardenCardButton(
                label: 'Plant',
                icon: CupertinoIcons.plus,
                onTap: onPlant,
              ),
            ],
          ),
        ),
      ],
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
            _PlantPreview(assetPath: stage.plantAsset),
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
      children: [
        Row(
          children: List.generate(visibleTotal, (index) {
            final filled = index < count;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xxs),
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
