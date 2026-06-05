import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';

class AppearanceSettingsCard extends StatelessWidget {
  const AppearanceSettingsCard({
    super.key,
    required this.settings,
    required this.onAccentColorChanged,
    required this.onBadgeIconChanged,
  });

  final FocusTimerSettings settings;
  final ValueChanged<FocusAccentColor> onAccentColorChanged;
  final ValueChanged<FocusBadgeIcon> onBadgeIconChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(child: Text('Stamp', style: AppTextStyles.headline)),
              _StampTile(
                onTap: () => onAccentColorChanged(_nextAccentColor),
                child: _ColorStamp(color: settings.accentColor.color),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StampTile(
                onTap: () => onBadgeIconChanged(_nextBadgeIcon),
                child: _IconStamp(
                  accentColor: settings.accentColor,
                  badgeIcon: settings.badgeIcon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FocusAccentColor get _nextAccentColor {
    final values = FocusAccentColor.values;
    final index = values.indexOf(settings.accentColor);
    return values[(index + 1) % values.length];
  }

  FocusBadgeIcon get _nextBadgeIcon {
    final values = FocusBadgeIcon.values;
    final index = values.indexOf(settings.badgeIcon);
    return values[(index + 1) % values.length];
  }
}

class _StampTile extends StatelessWidget {
  const _StampTile({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.graySoft, width: 0.8),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.sm)),
        ),
        child: SizedBox(width: 46, height: 46, child: Center(child: child)),
      ),
    );
  }
}

class _ColorStamp extends StatelessWidget {
  const _ColorStamp({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const SizedBox(width: 27, height: 27),
    );
  }
}

class _IconStamp extends StatelessWidget {
  const _IconStamp({required this.accentColor, required this.badgeIcon});

  final FocusAccentColor accentColor;
  final FocusBadgeIcon badgeIcon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.graySoft, width: 1.5),
      ),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: Icon(badgeIcon.icon, color: AppColors.charcoal, size: 18),
        ),
      ),
    );
  }
}
