import 'package:flutter/material.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/looping_asset_animation.dart';
import 'package:pats_space/features/social_focus/models/social_focus_models.dart';

class SocialFocusGroupView extends StatelessWidget {
  const SocialFocusGroupView({
    super.key,
    required this.participants,
    required this.active,
    required this.running,
    required this.compact,
  });

  final List<SocialFocusParticipant> participants;
  final bool active;
  final bool running;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visibleParticipants = participants.take(4).toList();
    if (visibleParticipants.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
        final spacing = compact ? AppSpacing.xs : AppSpacing.sm;
        final participantCount = visibleParticipants.length;
        final columns = participantCount >= 4 ? 2 : participantCount;
        final runSpacing = compact ? AppSpacing.xs : AppSpacing.sm;
        final maxSlotSizeByWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final slotSize = maxSlotSizeByWidth
            .clamp(96.0, _maxSlotSizeFor(participantCount, isTablet: isTablet))
            .toDouble();
        final lift = _characterLiftFor(slotSize);
        final rows = participantCount >= 4
            ? [
                visibleParticipants.take(2).toList(),
                visibleParticipants.skip(2).take(2).toList(),
              ]
            : [visibleParticipants];

        return Align(
          alignment: Alignment.bottomCenter,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (
                        var index = 0;
                        index < rows[rowIndex].length;
                        index++
                      ) ...[
                        _SocialFocusSeat(
                          participant: rows[rowIndex][index],
                          active: active,
                          running: running,
                          size: slotSize,
                          characterLift: lift,
                        ),
                        if (index < rows[rowIndex].length - 1)
                          SizedBox(width: spacing),
                      ],
                    ],
                  ),
                  if (rowIndex < rows.length - 1) SizedBox(height: runSpacing),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  double _maxSlotSizeFor(int participantCount, {required bool isTablet}) {
    if (isTablet) {
      return switch (participantCount) {
        1 => 300,
        2 => 250,
        _ => 220,
      };
    }

    return switch (participantCount) {
      1 => compact ? 188 : 220,
      2 => compact ? 156 : 176,
      3 => compact ? 148 : 168,
      _ => compact ? 148 : 168,
    };
  }

  double get _characterLiftFactor => .43;

  double _characterLiftFor(double slotSize) => slotSize * _characterLiftFactor;
}

class SocialFocusParticipant {
  const SocialFocusParticipant({
    required this.name,
    required this.focusFrames,
    this.status = SocialFocusMemberStatus.idle,
    this.usesLocalTimer = false,
  });

  final String name;
  final List<String> focusFrames;
  final SocialFocusMemberStatus status;
  final bool usesLocalTimer;
}

class _SocialFocusSeat extends StatelessWidget {
  const _SocialFocusSeat({
    required this.participant,
    required this.active,
    required this.running,
    required this.size,
    required this.characterLift,
  });

  final SocialFocusParticipant participant;
  final bool active;
  final bool running;
  final double size;
  final double characterLift;

  @override
  Widget build(BuildContext context) {
    final resting = participant.status == SocialFocusMemberStatus.breakTime;
    final frames = resting
        ? AppAssets.socialFocusSleeping
        : participant.focusFrames;
    final activeStatus = participant.status != SocialFocusMemberStatus.idle;
    final animate = participant.usesLocalTimer
        ? activeStatus && active && running
        : activeStatus;
    final illustrationHeight = size + characterLift;

    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: illustrationHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 0,
                  child: SizedBox.square(
                    dimension: size,
                    child: Image.asset(
                      AppAssets.socialFocusDesk,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                Positioned(
                  bottom: characterLift,
                  child: SizedBox.square(
                    dimension: size,
                    child: animate
                        ? LoopingAssetAnimation(
                            frames: frames,
                            frameDuration: const Duration(milliseconds: 950),
                          )
                        : Image.asset(
                            frames.first,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          _SocialFocusNameTag(
            name: participant.name,
            status: participant.status,
          ),
        ],
      ),
    );
  }
}

class _SocialFocusNameTag extends StatelessWidget {
  const _SocialFocusNameTag({required this.name, required this.status});

  final String name;
  final SocialFocusMemberStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      SocialFocusMemberStatus.idle => name,
      SocialFocusMemberStatus.focusing => '$name · focusing',
      SocialFocusMemberStatus.breakTime => '$name · break',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.surfaceMuted),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.charcoal.withValues(alpha: .72),
          fontSize: 11,
        ),
      ),
    );
  }
}
