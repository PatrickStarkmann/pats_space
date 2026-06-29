import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

class TimeSettingsGrabber extends StatelessWidget {
  const TimeSettingsGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.graySoft,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: SizedBox(width: 44, height: 7),
    );
  }
}

class TimeSettingsHeader extends StatelessWidget {
  const TimeSettingsHeader({
    super.key,
    required this.compact,
    required this.onCancel,
    required this.onDone,
  });

  final bool compact;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: compact ? 58 : 72,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              AppHaptics.selection();
              onCancel();
            },
            icon: const Icon(CupertinoIcons.xmark, size: 30),
          ),
          Expanded(
            child: Text(
              l10n.timeSettings,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(fontSize: compact ? 24 : 28),
            ),
          ),
          IconButton(
            onPressed: () {
              AppHaptics.lightImpact();
              onDone();
            },
            icon: const Icon(CupertinoIcons.checkmark, size: 32),
          ),
        ],
      ),
    );
  }
}

class TimeSettingsBackHeader extends StatelessWidget {
  const TimeSettingsBackHeader({
    super.key,
    required this.compact,
    required this.title,
    required this.onBack,
  });

  final bool compact;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 58 : 72,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              AppHaptics.selection();
              onBack();
            },
            icon: const Icon(CupertinoIcons.chevron_left, size: 32),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(fontSize: compact ? 24 : 28),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
