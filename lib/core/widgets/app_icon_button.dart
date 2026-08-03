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
    this.onLongPress,
    this.selected = false,
    this.showSelectedBackground = true,
    this.buttonSize = 58,
    this.iconSize = 38,
    this.semanticLabel,
    this.haptic = AppIconButtonHaptic.light,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool showSelectedBackground;
  final double buttonSize;
  final double iconSize;
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
    final background = widget.selected && widget.showSelectedBackground
        ? AppColors.sageSoft
        : AppColors.transparent;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: _enabled
            ? () {
                _triggerHaptic();
                widget.onPressed?.call();
              }
            : null,
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                setState(() => _pressed = false);
                AppHaptics.mediumImpact();
                widget.onLongPress?.call();
              },
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.buttonSize,
            height: widget.buttonSize,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            alignment: Alignment.center,
            child: Icon(widget.icon, color: color, size: widget.iconSize),
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
