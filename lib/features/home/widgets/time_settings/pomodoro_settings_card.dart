import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_card.dart';

class PomodoroSettingsCard extends StatelessWidget {
  const PomodoroSettingsCard({
    super.key,
    required this.compact,
    required this.focusMinutes,
    required this.onChanged,
  });

  final bool compact;
  final int focusMinutes;
  final ValueChanged<int> onChanged;

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
              Text('Pomodoro', style: AppTextStyles.headline),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              '${focusMinutes}m',
              style: AppTextStyles.timer.copyWith(fontSize: compact ? 56 : 68),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.graySoft,
              inactiveTrackColor: AppColors.graySoft,
              thumbColor: const Color(0xFFF16C72),
              trackHeight: 0,
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
              activeTickMarkColor: AppColors.charcoal,
              inactiveTickMarkColor: AppColors.charcoal,
            ),
            child: Slider(
              value: focusMinutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              onChanged: (value) => onChanged(value.round()),
            ),
          ),
        ],
      ),
    );
  }
}
