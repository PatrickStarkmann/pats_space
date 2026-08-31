import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/ads/services/ads_config.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

/// Presents the rewarded-water prompt using the same device-adaptive pattern
/// as the other Patsspace sheets: a draggable bottom sheet on phones and a
/// contained dialog on iPad.
Future<bool?> showRewardedWaterPrompt(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
  if (tablet) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.xxl),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: builder(dialogContext),
        ),
      ),
    );
  }

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: AppColors.transparent,
    builder: builder,
  );
}

class RewardedWaterSheet extends StatelessWidget {
  const RewardedWaterSheet({
    super.key,
    required this.remainingClaims,
    required this.ready,
    required this.loading,
    this.dialog = false,
  });

  final int remainingClaims;
  final bool ready;
  final bool loading;
  final bool dialog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4FA),
        borderRadius: dialog
            ? BorderRadius.circular(34)
            : const BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.graySoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.rewardedWaterTitle,
                      style: AppTextStyles.title,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.rewardedWaterBody(AdsConfig.rewardedWaterAmount),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.grayWarm,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.drop_fill,
                      color: Color(0xFF65A9F7),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.rewardedWaterRemaining(
                          remainingClaims,
                          AdsConfig.maxRewardedAdsPerDay,
                        ),
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CupertinoButton(
                color: AppColors.charcoal,
                borderRadius: BorderRadius.circular(AppRadii.md),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                onPressed: ready && !loading
                    ? () => Navigator.of(context).pop(true)
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIconsFill.play,
                      size: 18,
                      color: AppColors.surface,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      loading
                          ? l10n.rewardedWaterPreparing
                          : l10n.rewardedWaterWatch,
                      style: AppTextStyles.button,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.rewardedWaterLater,
                  style: AppTextStyles.body.copyWith(color: AppColors.grayWarm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
