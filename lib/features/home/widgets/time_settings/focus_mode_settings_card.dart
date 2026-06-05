import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/segmented_selector.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_card.dart';

class FocusModeSettingsCard extends StatelessWidget {
  const FocusModeSettingsCard({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final FocusMode mode;
  final ValueChanged<FocusMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return TimeSettingsCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tight = constraints.maxWidth < 340;
          final selector = SegmentedSelector<FocusMode>(
            values: const [FocusMode.pomodoro, FocusMode.stopwatch],
            selectedValue: mode,
            labelBuilder: (value) {
              return switch (value) {
                FocusMode.pomodoro => 'Pomodoro',
                FocusMode.stopwatch => 'Stopwatch',
              };
            },
            onChanged: onModeChanged,
          );

          if (tight) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Focus Mode', style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.md),
                selector,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text('Focus Mode', style: AppTextStyles.headline),
              ),
              selector,
            ],
          );
        },
      ),
    );
  }
}
