import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/focus_blocking/controllers/focus_blocking_controller.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_card.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

class FocusBlockingSettingsCard extends StatelessWidget {
  const FocusBlockingSettingsCard({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final FocusBlockingController controller;
  final bool enabled;
  final Future<void> Function(bool enabled) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final status = controller.status;
        final subtitle = !status.isSupported
            ? l10n.deepFocusUnavailable
            : enabled && status.isReady
            ? l10n.deepFocusReadyDescription(status.selectionCount)
            : l10n.deepFocusDescription;

        return TimeSettingsCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EFF5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.shield_lefthalf_fill,
                  color: AppColors.charcoal,
                  size: 23,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.deepFocus, style: AppTextStyles.headline),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMuted.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (controller.isBusy)
                const CupertinoActivityIndicator()
              else
                CupertinoSwitch(
                  value: enabled,
                  activeTrackColor: AppColors.charcoal,
                  onChanged: status.isSupported
                      ? (value) => onChanged(value)
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }
}
