import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/services/app_rating_service.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_shadows.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/primary_button.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

Future<void> showPatsspaceReviewPrompt(
  BuildContext context, {
  required AppRatingService ratingService,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _AppReviewPromptDialog(ratingService: ratingService),
  );
}

class _AppReviewPromptDialog extends StatefulWidget {
  const _AppReviewPromptDialog({required this.ratingService});

  final AppRatingService ratingService;

  @override
  State<_AppReviewPromptDialog> createState() => _AppReviewPromptDialogState();
}

class _AppReviewPromptDialogState extends State<_AppReviewPromptDialog> {
  var _openingStore = false;

  Future<void> _openStoreReviewPage() async {
    if (_openingStore) {
      return;
    }
    AppHaptics.lightImpact();
    setState(() => _openingStore = true);
    await widget.ratingService.openStoreReviewPage();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      backgroundColor: AppColors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F4FA),
            borderRadius: BorderRadius.circular(30),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(AppAssets.appIcon, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.appReviewTitle,
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.appReviewMessage,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.grayWarm,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.star_rounded,
                      color: AppColors.accentWarm,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _openingStore ? l10n.loading : l10n.appReviewRate,
                  onPressed: _openingStore ? null : _openStoreReviewPage,
                  backgroundColor: AppColors.charcoal,
                  pressedColor: const Color(0xFF121312),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                onPressed: _openingStore
                    ? null
                    : () {
                        AppHaptics.selection();
                        Navigator.of(context).pop();
                      },
                child: Text(
                  l10n.appReviewLater,
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
