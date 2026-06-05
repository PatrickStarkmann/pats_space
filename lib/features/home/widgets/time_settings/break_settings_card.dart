import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_card.dart';

class BreakSettingsCard extends StatelessWidget {
  const BreakSettingsCard({
    super.key,
    required this.settings,
    required this.onSessionsPressed,
    required this.onLongBreakIntervalPressed,
    required this.onShortBreakPressed,
    required this.onLongBreakPressed,
  });

  final FocusTimerSettings settings;
  final VoidCallback onSessionsPressed;
  final VoidCallback onLongBreakIntervalPressed;
  final VoidCallback onShortBreakPressed;
  final VoidCallback onLongBreakPressed;

  @override
  Widget build(BuildContext context) {
    return TimeSettingsCard(
      child: Column(
        children: [
          _SettingsRow(
            label: 'Sessions',
            value: '${settings.sessionsPerRound}',
            onTap: onSessionsPressed,
          ),
          const Divider(color: AppColors.graySoft),
          _SettingsRow(
            label: 'Long Break Interval',
            value: '${settings.longBreakInterval}',
            onTap: onLongBreakIntervalPressed,
          ),
          const Divider(color: AppColors.graySoft),
          _SettingsRow(
            label: 'Short Break',
            value: '${settings.shortBreakMinutes}m',
            onTap: onShortBreakPressed,
          ),
          const Divider(color: AppColors.graySoft),
          _SettingsRow(
            label: 'Long Break',
            value: '${settings.longBreakMinutes}m',
            onTap: onLongBreakPressed,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headline,
              ),
            ),
            Text(value, style: AppTextStyles.bodyMuted),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.charcoal,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
