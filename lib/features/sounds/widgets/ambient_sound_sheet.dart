import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/sounds/controllers/sound_controller.dart';
import 'package:pats_space/features/sounds/models/ambient_sound.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Future<void> showAmbientSoundSheet({
  required BuildContext context,
  required SoundController controller,
}) {
  final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
  if (isTablet) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.xxl),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
        child: SizedBox(
          width: 560,
          child: _AmbientSoundSheet(controller: controller, dialog: true),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => _AmbientSoundSheet(controller: controller),
  );
}

String localizedAmbientSoundName(AppLocalizations l10n, AmbientSound sound) {
  return switch (sound) {
    AmbientSound.none => l10n.noAmbientSound,
    AmbientSound.firewood => l10n.firewood,
    AmbientSound.rain => l10n.rain,
    AmbientSound.rainforest => l10n.rainforest,
  };
}

class _AmbientSoundSheet extends StatelessWidget {
  const _AmbientSoundSheet({required this.controller, this.dialog = false});

  final SoundController controller;
  final bool dialog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          mediaQuery.padding.bottom + AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: Color(0xFFF5F4FA),
          borderRadius: dialog
              ? BorderRadius.circular(34)
              : const BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.graySoft,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.ambientSounds, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.ambientSoundsDescription,
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.lg),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Column(
                    children: [
                      for (final sound in AmbientSound.values) ...[
                        _AmbientSoundRow(
                          sound: sound,
                          selected: controller.activeAmbientSound == sound,
                          label: localizedAmbientSoundName(l10n, sound),
                          onPressed: () {
                            unawaited(controller.selectAmbientSound(sound));
                          },
                        ),
                        if (sound != AmbientSound.values.last)
                          const Divider(
                            height: 1,
                            indent: AppSpacing.lg,
                            endIndent: AppSpacing.lg,
                            color: AppColors.surfaceMuted,
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.speakerLow,
                      color: AppColors.grayWarm,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(l10n.volume, style: AppTextStyles.body),
                    ),
                    Text(
                      '${(controller.ambientVolume * 100).round()}%',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                ),
                Slider(
                  value: controller.ambientVolume,
                  activeColor: AppColors.charcoal,
                  inactiveColor: AppColors.graySoft,
                  onChanged: !controller.hasAmbientSoundSelection
                      ? null
                      : (value) {
                          unawaited(controller.setAmbientVolume(value));
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AmbientSoundRow extends StatelessWidget {
  const _AmbientSoundRow({
    required this.sound,
    required this.selected,
    required this.label,
    required this.onPressed,
  });

  final AmbientSound sound;
  final bool selected;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(_icon, color: AppColors.charcoal),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: AppTextStyles.body)),
              if (selected)
                const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  color: AppColors.charcoal,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (sound) {
    AmbientSound.none => PhosphorIconsRegular.speakerSlash,
    AmbientSound.firewood => PhosphorIconsRegular.campfire,
    AmbientSound.rain => PhosphorIconsRegular.cloudRain,
    AmbientSound.rainforest => PhosphorIconsRegular.tree,
  };
}
