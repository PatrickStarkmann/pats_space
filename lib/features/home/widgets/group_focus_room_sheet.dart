import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_header.dart';
import 'package:pats_space/features/social_focus/models/social_focus_models.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

Future<bool> showGroupFocusRoomSheet({
  required BuildContext context,
  required SocialFocusRoom room,
  required Future<void> Function(SocialFocusActivity activity)
  onLocalActivityChanged,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => GroupFocusRoomSheet(
      room: room,
      onLocalActivityChanged: onLocalActivityChanged,
    ),
  );

  return result ?? false;
}

class GroupFocusRoomSheet extends StatefulWidget {
  const GroupFocusRoomSheet({
    super.key,
    required this.room,
    required this.onLocalActivityChanged,
  });

  final SocialFocusRoom room;
  final Future<void> Function(SocialFocusActivity activity)
  onLocalActivityChanged;

  @override
  State<GroupFocusRoomSheet> createState() => _GroupFocusRoomSheetState();
}

class _GroupFocusRoomSheetState extends State<GroupFocusRoomSheet> {
  late SocialFocusRoom _room = widget.room;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context);
    final compact = mediaQuery.size.height < 760;

    return SafeArea(
      top: false,
      bottom: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.82),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            mediaQuery.viewInsets.bottom +
                mediaQuery.padding.bottom +
                AppSpacing.lg,
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
                title: l10n.roomTitle(_room.hostName),
                onClose: () => Navigator.of(context).pop(false),
              ),
              _RoomSummary(room: _room),
              const SizedBox(height: AppSpacing.lg),
              _ListGroup(
                children: [
                  for (var index = 0; index < _room.members.length; index++)
                    _MemberRow(
                      member: _room.members[index],
                      showDivider: index < _room.members.length - 1,
                      onActivityPressed: _room.members[index].id == 'me'
                          ? () => _showActivityPicker(_room.members[index])
                          : null,
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

  Future<void> _showActivityPicker(SocialFocusMember member) async {
    final l10n = AppLocalizations.of(context);
    final selectedActivity = await showCupertinoModalPopup<SocialFocusActivity>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(l10n.chooseActivity),
          actions: [
            for (final activity in SocialFocusActivity.values)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(activity),
                child: Text(
                  _activityLabel(activity, l10n),
                  style: const TextStyle(color: AppColors.charcoal),
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.charcoal),
            ),
          ),
        );
      },
    );

    if (selectedActivity == null || selectedActivity == member.activity) {
      return;
    }

    await widget.onLocalActivityChanged(selectedActivity);
    if (!mounted) {
      return;
    }

    setState(() {
      _room = SocialFocusRoom(
        id: _room.id,
        hostName: _room.hostName,
        statusLabel: _room.statusLabel,
        capacity: _room.capacity,
        members: [
          for (final roomMember in _room.members)
            roomMember.id == member.id
                ? SocialFocusMember(
                    id: roomMember.id,
                    name: roomMember.name,
                    activity: selectedActivity,
                    status: roomMember.status,
                  )
                : roomMember,
        ],
      );
    });
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
    final l10n = AppLocalizations.of(context);
    final focusingCount = room.members
        .where((member) => member.status == SocialFocusMemberStatus.focusing)
        .length;
    final breakCount = room.members
        .where((member) => member.status == SocialFocusMemberStatus.breakTime)
        .length;
    final parts = [
      if (focusingCount > 0) l10n.focusCount(focusingCount),
      if (breakCount > 0) l10n.breakCount(breakCount),
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
  const _MemberRow({
    required this.member,
    required this.showDivider,
    required this.onActivityPressed,
  });

  final SocialFocusMember member;
  final bool showDivider;
  final VoidCallback? onActivityPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editable = onActivityPressed != null;

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
              _MemberStatusButton(
                label: _statusLabel(member, editable: editable, l10n: l10n),
                editable: editable,
                onPressed: onActivityPressed,
              ),
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

  String _statusLabel(
    SocialFocusMember member, {
    required bool editable,
    required AppLocalizations l10n,
  }) {
    if (editable && member.status == SocialFocusMemberStatus.idle) {
      return '${_activityLabel(member.activity, l10n)} · ${l10n.notStarted}';
    }

    return switch (member.status) {
      SocialFocusMemberStatus.idle => l10n.notStarted,
      SocialFocusMemberStatus.breakTime => l10n.breakLabel,
      SocialFocusMemberStatus.focusing => _activityLabel(member.activity, l10n),
    };
  }
}

class _MemberStatusButton extends StatelessWidget {
  const _MemberStatusButton({
    required this.label,
    required this.editable,
    required this.onPressed,
  });

  final String label;
  final bool editable;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!editable) {
      return Text(label, style: AppTextStyles.caption);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          const Icon(
            CupertinoIcons.chevron_down,
            size: 14,
            color: AppColors.grayWarm,
          ),
        ],
      ),
    );
  }
}

String _activityLabel(SocialFocusActivity activity, AppLocalizations l10n) {
  return switch (activity) {
    SocialFocusActivity.reading => l10n.reading,
    SocialFocusActivity.studying => l10n.studying,
    SocialFocusActivity.working => l10n.working,
  };
}

class _LeaveRow extends StatelessWidget {
  const _LeaveRow({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
              l10n.leaveRoom,
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
