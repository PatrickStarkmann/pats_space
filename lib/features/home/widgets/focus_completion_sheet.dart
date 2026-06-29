import 'package:flutter/cupertino.dart';
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

class _FocusCompletionSheetState extends State<FocusCompletionSheet> {
  static const _dismissDistance = 88.0;
  static const _dismissVelocity = 520.0;

  double _dragOffset = 0;
  bool _isDragging = false;

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
          widget.onContinue();
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
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onContinue,
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
                    Text(
                      hasReward ? l10n.wellDone : l10n.takeABreath,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        hasReward
                            ? l10n.rewardWaterMessage
                            : l10n.noRewardWaterMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _RewardPill(
                          icon: hasReward
                              ? CupertinoIcons.drop_fill
                              : CupertinoIcons.drop,
                          label: hasReward
                              ? l10n.waterReward(widget.waterReward)
                              : l10n.noWater,
                        ),
                        _RewardPill(
                          icon: CupertinoIcons.timer,
                          label: l10n.focusedDuration(_formattedMinutes),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: l10n.continueAction,
                      onPressed: widget.onContinue,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onOpenSpace,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          l10n.goToSpace,
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                    ),
                  ],
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
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF65A9F7)),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
