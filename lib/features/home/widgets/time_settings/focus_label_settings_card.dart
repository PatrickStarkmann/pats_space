import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';

class FocusLabelSettingsCard extends StatelessWidget {
  const FocusLabelSettingsCard({
    super.key,
    required this.settings,
    required this.onLabelChanged,
    required this.onAccentColorChanged,
    required this.onBadgeIconChanged,
  });

  final FocusTimerSettings settings;
  final ValueChanged<String> onLabelChanged;
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
              Expanded(
                child: _LabelEditorButton(
                  label: settings.focusLabel,
                  onPressed: () => _openLabelEditor(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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

  Future<void> _openLabelEditor(BuildContext context) async {
    final controller = TextEditingController(text: settings.focusLabel);
    final updatedLabel = await showCupertinoDialog<String>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Tag bearbeiten'),
          content: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: CupertinoTextField(
              controller: controller,
              autofocus: true,
              clearButtonMode: OverlayVisibilityMode.editing,
              maxLength: 24,
              placeholder: 'z. B. Mathe',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    final trimmedLabel = updatedLabel?.trim();
    if (trimmedLabel == null || trimmedLabel.isEmpty) {
      return;
    }

    onLabelChanged(trimmedLabel);
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

class _LabelEditorButton extends StatelessWidget {
  const _LabelEditorButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headline,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            CupertinoIcons.pencil_circle_fill,
            color: AppColors.charcoal,
            size: 28,
          ),
        ],
      ),
    );
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
        color: badgeIcon == FocusBadgeIcon.none
            ? AppColors.transparent
            : accentColor.color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.graySoft, width: 1.5),
      ),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(child: _BadgeIconImage(badgeIcon: badgeIcon)),
      ),
    );
  }
}

class _BadgeIconImage extends StatelessWidget {
  const _BadgeIconImage({required this.badgeIcon});

  final FocusBadgeIcon badgeIcon;

  @override
  Widget build(BuildContext context) {
    final assetPath = badgeIcon.assetPath;
    if (assetPath != null) {
      return ClipOval(
        child: SizedBox(
          width: 28,
          height: 28,
          child: Transform.translate(
            offset: const Offset(0, 3),
            child: Image.asset(
              assetPath,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      );
    }

    return const _NoBadgeMark();
  }
}

class _NoBadgeMark extends StatelessWidget {
  const _NoBadgeMark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(22),
      painter: _NoBadgeMarkPainter(),
    );
  }
}

class _NoBadgeMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.charcoal.withValues(alpha: .66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    canvas.drawCircle(center, radius, paint);
    canvas.drawLine(
      Offset(size.width * .28, size.height * .72),
      Offset(size.width * .72, size.height * .28),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NoBadgeMarkPainter oldDelegate) => false;
}
