import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/segmented_selector.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_card.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return TimeSettingsCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tight = constraints.maxWidth < 340;
          final selector = SegmentedSelector<FocusMode>(
            values: const [FocusMode.pomodoro, FocusMode.stopwatch],
            selectedValue: mode,
            labelBuilder: (value) {
              return switch (value) {
                FocusMode.pomodoro => l10n.pomodoro,
                FocusMode.stopwatch => l10n.stopwatch,
              };
            },
            onChanged: onModeChanged,
          );

          if (tight) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.focusMode, style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.md),
                selector,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text(l10n.focusMode, style: AppTextStyles.headline),
              ),
              selector,
            ],
          );
        },
      ),
    );
  }
}
