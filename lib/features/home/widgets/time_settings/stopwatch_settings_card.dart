import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_card.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

class StopwatchSettingsCard extends StatelessWidget {
  const StopwatchSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TimeSettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadii.pill),
                  ),
                ),
                child: SizedBox(width: 6, height: 28),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(l10n.stopwatch, style: AppTextStyles.headline),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.stopwatchDescription, style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}
