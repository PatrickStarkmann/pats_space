import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/focus/focus_animation_catalog.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

class AnimationPairSettingsCard extends StatelessWidget {
  const AnimationPairSettingsCard({
    super.key,
    required this.selectedPair,
    required this.onChanged,
    this.hasPro = false,
    this.onProRequested,
  });

  final FocusAnimationPair selectedPair;
  final ValueChanged<FocusAnimationPair> onChanged;
  final bool hasPro;
  final VoidCallback? onProRequested;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openPicker(context),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.animations,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headline,
                  ),
                ),
                _PairPill(label: selectedPair.label),
                const SizedBox(width: AppSpacing.xs),
                _SmallActionButton(
                  icon: CupertinoIcons.shuffle,
                  onPressed: () => onChanged(
                    selectedPair == FocusAnimationPair.shuffle
                        ? FocusAnimationPair.standard
                        : FocusAnimationPair.shuffle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _SmallActionButton(
                  icon: CupertinoIcons.restart,
                  muted: selectedPair == FocusAnimationPair.standard,
                  onPressed: selectedPair == FocusAnimationPair.standard
                      ? null
                      : () => onChanged(FocusAnimationPair.standard),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showCupertinoDialog<FocusAnimationPair>(
      context: context,
      builder: (context) {
        return _AnimationPairPickerDialog(
          initialPair: selectedPair.isPro && !hasPro
              ? FocusAnimationPair.standard
              : selectedPair,
          hasPro: hasPro,
          onProRequested: onProRequested,
        );
      },
    );

    if (picked != null) {
      onChanged(picked);
    }
  }
}

class _PairPill extends StatelessWidget {
  const _PairPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.graySoft),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: _noDecoration(
            AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.onPressed,
    this.muted = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          icon,
          size: 24,
          color: muted ? AppColors.grayWarm : AppColors.charcoal,
        ),
      ),
    );
  }
}

class _AnimationPairPickerDialog extends StatefulWidget {
  const _AnimationPairPickerDialog({
    required this.initialPair,
    required this.hasPro,
    this.onProRequested,
  });

  final FocusAnimationPair initialPair;
  final bool hasPro;
  final VoidCallback? onProRequested;

  @override
  State<_AnimationPairPickerDialog> createState() =>
      _AnimationPairPickerDialogState();
}

class _AnimationPairPickerDialogState
    extends State<_AnimationPairPickerDialog> {
  late FocusAnimationPair _pair = widget.initialPair;
  late bool _shuffle = widget.initialPair == FocusAnimationPair.shuffle;
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (mounted) {
        setState(() => _tick++);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final assetPath in FocusAnimationCatalog.allFrames) {
      precacheImage(AssetImage(assetPath), context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showingBreak = (_tick ~/ 4).isOdd;
    final previewPair = _shuffle ? FocusAnimationPair.standard : _pair;
    final proLocked = _pair.isPro && !widget.hasPro;
    final pairDescription = _shuffle
        ? 'Shuffle'
        : '${_pair.label} · ${showingBreak ? l10n.breakLabel : l10n.focus}';
    final spec = showingBreak
        ? FocusAnimationCatalog.breakSpec(previewPair)
        : FocusAnimationCatalog.focusSpec(previewPair);
    final assetPath = spec.frames[_tick % spec.frames.length];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.animations,
                  style: _noDecoration(AppTextStyles.title),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        pairDescription,
                        overflow: TextOverflow.ellipsis,
                        style: _noDecoration(AppTextStyles.bodyMuted),
                      ),
                    ),
                    if (proLocked) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        CupertinoIcons.lock_fill,
                        size: 16,
                        color: AppColors.grayWarm,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    _PickerArrow(
                      icon: CupertinoIcons.chevron_left,
                      onPressed: _previousPair,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 260,
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                    _PickerArrow(
                      icon: CupertinoIcons.chevron_right,
                      onPressed: _nextPair,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: l10n.select,
                        onPressed: () {
                          if (proLocked) {
                            Navigator.of(context).pop();
                            widget.onProRequested?.call();
                            return;
                          }
                          Navigator.of(
                            context,
                          ).pop(_shuffle ? FocusAnimationPair.shuffle : _pair);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _DialogButton(
                        label: l10n.cancel,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _previousPair() {
    final values = FocusAnimationPair.values
        .where((pair) => pair != FocusAnimationPair.shuffle)
        .toList();
    final index = values.indexOf(_pair);
    setState(() {
      _shuffle = false;
      _pair = values[(index - 1 + values.length) % values.length];
      _tick = 0;
    });
  }

  void _nextPair() {
    final values = FocusAnimationPair.values
        .where((pair) => pair != FocusAnimationPair.shuffle)
        .toList();
    final index = values.indexOf(_pair);
    setState(() {
      _shuffle = false;
      _pair = values[(index + 1) % values.length];
      _tick = 0;
    });
  }
}

class _PickerArrow extends StatelessWidget {
  const _PickerArrow({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: 42,
        height: 72,
        child: Icon(icon, color: AppColors.charcoal, size: 34),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.graySoft, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: _noDecoration(
                AppTextStyles.headline.copyWith(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _noDecoration(TextStyle style) {
  return style.copyWith(decoration: TextDecoration.none);
}
