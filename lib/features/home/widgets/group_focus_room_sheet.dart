import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_header.dart';
import 'package:pats_space/features/social_focus/models/social_focus_models.dart';

Future<bool> showGroupFocusRoomSheet({
  required BuildContext context,
  required SocialFocusRoom room,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => GroupFocusRoomSheet(room: room),
  );

  return result ?? false;
}

class GroupFocusRoomSheet extends StatelessWidget {
  const GroupFocusRoomSheet({super.key, required this.room});

  final SocialFocusRoom room;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final compact = mediaQuery.size.height < 760;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.82),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            mediaQuery.viewInsets.bottom + AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F4FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Column(
            children: [
              const TimeSettingsGrabber(),
              _RoomHeader(
                compact: compact,
                title: '${room.hostName}\'s room',
                onClose: () => Navigator.of(context).pop(false),
              ),
              _RoomSummary(room: room),
              const SizedBox(height: AppSpacing.lg),
              _ListGroup(
                children: [
                  for (var index = 0; index < room.members.length; index++)
                    _MemberRow(
                      member: room.members[index],
                      showDivider: index < room.members.length - 1,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _LeaveRow(onPressed: () => Navigator.of(context).pop(true)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({
    required this.compact,
    required this.title,
    required this.onClose,
  });

  final bool compact;
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 58 : 72,
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(CupertinoIcons.xmark, size: 30),
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

class _RoomSummary extends StatelessWidget {
  const _RoomSummary({required this.room});

  final SocialFocusRoom room;

  @override
  Widget build(BuildContext context) {
    final focusingCount = room.members
        .where((member) => member.status == SocialFocusMemberStatus.focusing)
        .length;
    final breakCount = room.members
        .where((member) => member.status == SocialFocusMemberStatus.breakTime)
        .length;
    final parts = [
      if (focusingCount > 0) '$focusingCount focusing',
      if (breakCount > 0) '$breakCount break',
      room.seatsLabel,
    ];

    return Text(
      parts.join(' · '),
      textAlign: TextAlign.center,
      style: AppTextStyles.caption.copyWith(fontSize: 14),
    );
  }
}

class _ListGroup extends StatelessWidget {
  const _ListGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.showDivider});

  final SocialFocusMember member;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.person, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(_statusLabel(member), style: AppTextStyles.caption),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: AppSpacing.xl + AppSpacing.lg,
            color: AppColors.surfaceMuted,
          ),
      ],
    );
  }

  String _statusLabel(SocialFocusMember member) {
    return switch (member.status) {
      SocialFocusMemberStatus.idle => 'not started',
      SocialFocusMemberStatus.breakTime => 'break',
      SocialFocusMemberStatus.focusing => _activityLabel(member.activity),
    };
  }

  String _activityLabel(SocialFocusActivity activity) {
    return switch (activity) {
      SocialFocusActivity.reading => 'reading',
      SocialFocusActivity.writing => 'writing',
      SocialFocusActivity.coding => 'coding',
    };
  }
}

class _LeaveRow extends StatelessWidget {
  const _LeaveRow({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Center(
            child: Text(
              'Leave Room',
              style: AppTextStyles.body.copyWith(
                color: CupertinoColors.systemRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
