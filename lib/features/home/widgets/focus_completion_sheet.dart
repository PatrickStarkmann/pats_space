import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/primary_button.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

class FocusCompletionSheet extends StatefulWidget {
  const FocusCompletionSheet({
    super.key,
    required this.focusDuration,
    required this.waterReward,
    required this.onContinue,
    required this.onOpenSpace,
  });

  final Duration focusDuration;
  final int waterReward;
  final VoidCallback onContinue;
  final VoidCallback onOpenSpace;

  @override
  State<FocusCompletionSheet> createState() => _FocusCompletionSheetState();
}

class _FocusCompletionSheetState extends State<FocusCompletionSheet>
    with SingleTickerProviderStateMixin {
  static const _dismissDistance = 88.0;
  static const _dismissVelocity = 520.0;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _heroAnimation;
  late final Animation<double> _titleAnimation;
  late final Animation<double> _metricsAnimation;
  late final Animation<double> _actionsAnimation;
  late final Animation<double> _countAnimation;
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 860),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, .52, curve: Curves.easeOutCubic),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0, .56, curve: Curves.easeOutCubic),
          ),
        );
    _heroAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(.08, .7, curve: Curves.elasticOut),
    );
    _titleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(.2, .58, curve: Curves.easeOutCubic),
    );
    _metricsAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(.34, .78, curve: Curves.easeOutCubic),
    );
    _actionsAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(.58, 1, curve: Curves.easeOutCubic),
    );
    _countAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(.42, 1, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _entranceController.forward();
      if (widget.waterReward > 0) {
        AppHaptics.reward();
      } else {
        AppHaptics.warning();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasReward = widget.waterReward > 0;

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
          _continue();
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: -32,
              height: 32,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.transparent,
                        AppColors.charcoal.withValues(alpha: .07),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: .92),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withValues(alpha: .05),
                    blurRadius: 18,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _continue,
                          child: SizedBox(
                            height: 28,
                            child: Center(
                              child: Container(
                                width: 44,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.graySoft,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.pill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _RewardHero(
                          hasReward: hasReward,
                          animation: _heroAnimation,
                        ),
                        _RewardEntrance(
                          animation: _titleAnimation,
                          verticalOffset: 10,
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                hasReward ? l10n.wellDone : l10n.takeABreath,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.title.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 310,
                                ),
                                child: Text(
                                  hasReward
                                      ? l10n.rewardWaterMessage
                                      : l10n.noRewardWaterMessage,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _RewardEntrance(
                          animation: _metricsAnimation,
                          verticalOffset: 14,
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: _RewardMetricCard(
                                      icon: hasReward
                                          ? CupertinoIcons.drop_fill
                                          : CupertinoIcons.drop,
                                      accentColor: const Color(0xFF65A9F7),
                                      value: hasReward
                                          ? _AnimatedRewardValue(
                                              value: widget.waterReward,
                                              animation: _countAnimation,
                                              labelBuilder: l10n.waterReward,
                                            )
                                          : Text(
                                              l10n.noWater,
                                              textAlign: TextAlign.center,
                                              style: AppTextStyles.headline
                                                  .copyWith(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: _RewardMetricCard(
                                      icon: CupertinoIcons.timer,
                                      accentColor: AppColors.charcoal,
                                      value: Text(
                                        l10n.focusedDuration(_formattedMinutes),
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.headline.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _RewardEntrance(
                          animation: _actionsAnimation,
                          verticalOffset: 12,
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.lg),
                              PrimaryButton(
                                label: l10n.continueAction,
                                onPressed: _continue,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  AppHaptics.selection();
                                  widget.onOpenSpace();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  child: Text(
                                    l10n.goToSpace,
                                    style: AppTextStyles.bodyMuted.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _formattedMinutes {
    final minutes = widget.focusDuration.inMinutes;
    if (minutes >= 1) {
      return '${minutes}m';
    }

    return '<1m';
  }

  void _continue() {
    AppHaptics.lightImpact();
    widget.onContinue();
  }
}

class _RewardEntrance extends StatelessWidget {
  const _RewardEntrance({
    required this.animation,
    required this.child,
    this.verticalOffset = 12,
  });

  final Animation<double> animation;
  final Widget child;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, verticalOffset * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }
}

class _RewardHero extends StatelessWidget {
  const _RewardHero({required this.hasReward, required this.animation});

  final bool hasReward;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value.clamp(0.0, 1.18);
        final opacity = animation.value.clamp(0.0, 1.0);
        final scale = (.82 + (.18 * progress)).clamp(.82, 1.06);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: hasReward
              ? const Color(0xFFEAF4FF)
              : AppColors.surfaceMuted.withValues(alpha: .62),
          shape: BoxShape.circle,
          border: Border.all(
            color: hasReward
                ? const Color(0xFF65A9F7).withValues(alpha: .26)
                : AppColors.graySoft,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: .06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Icon(
          hasReward ? CupertinoIcons.drop_fill : CupertinoIcons.drop,
          color: hasReward ? const Color(0xFF65A9F7) : AppColors.grayWarm,
          size: 38,
        ),
      ),
    );
  }
}

class _RewardMetricCard extends StatelessWidget {
  const _RewardMetricCard({
    required this.icon,
    required this.accentColor,
    required this.value,
  });

  final IconData icon;
  final Color accentColor;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.graySoft.withValues(alpha: .54)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: accentColor),
            const SizedBox(height: AppSpacing.xs),
            value,
          ],
        ),
      ),
    );
  }
}

class _AnimatedRewardValue extends StatelessWidget {
  const _AnimatedRewardValue({
    required this.value,
    required this.animation,
    required this.labelBuilder,
  });

  final int value;
  final Animation<double> animation;
  final String Function(int value) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final animatedValue = (value * animation.value).round().clamp(0, value);
        return Text(
          labelBuilder(animatedValue),
          textAlign: TextAlign.center,
          style: AppTextStyles.headline.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        );
      },
    );
  }
}
