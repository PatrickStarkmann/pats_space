import 'package:flutter/material.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_shadows.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.pressedColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? pressedColor;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = !_enabled
        ? AppColors.graySoft
        : _pressed
        ? (widget.pressedColor ?? AppColors.sagePressed)
        : (widget.backgroundColor ?? AppColors.sage);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: _enabled
          ? (_) {
              setState(() => _pressed = false);
              AppHaptics.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: _enabled ? AppShadows.button : AppShadows.none,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.button,
          ),
        ),
      ),
    );
  }
}
