import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_card.dart';

class StopwatchSettingsCard extends StatelessWidget {
  const StopwatchSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
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
              Text('Stopwatch', style: AppTextStyles.headline),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Start an open-ended focus session when you do not know how long you need. Pause when you step away, then finish to save the exact time.',
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }
}
