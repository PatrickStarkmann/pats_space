import 'package:flutter/material.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';

enum AppIconButtonHaptic { none, selection, light, medium }

class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    this.semanticLabel,
    this.haptic = AppIconButtonHaptic.light,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool selected;
  final String? semanticLabel;
  final AppIconButtonHaptic haptic;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? AppColors.charcoal : AppColors.grayWarm;
    final background = widget.selected
        ? AppColors.sageSoft
        : AppColors.transparent;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: _enabled
            ? (_) {
                setState(() => _pressed = false);
                _triggerHaptic();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            alignment: Alignment.center,
            child: Icon(widget.icon, color: color, size: 38),
          ),
        ),
      ),
    );
  }

  void _triggerHaptic() {
    switch (widget.haptic) {
      case AppIconButtonHaptic.none:
        return;
      case AppIconButtonHaptic.selection:
        AppHaptics.selection();
        return;
      case AppIconButtonHaptic.light:
        AppHaptics.lightImpact();
        return;
      case AppIconButtonHaptic.medium:
        AppHaptics.mediumImpact();
        return;
    }
  }
}
