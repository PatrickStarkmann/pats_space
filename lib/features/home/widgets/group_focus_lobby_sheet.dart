import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/social_focus/models/social_focus_models.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_header.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

Future<GroupFocusLobbySelection?> showGroupFocusLobbySheet({
  required BuildContext context,
  required SocialFocusLobbySnapshot snapshot,
  required Stream<SocialFocusLobbySnapshot> snapshots,
}) {
  return showModalBottomSheet<GroupFocusLobbySelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) =>
        GroupFocusLobbySheet(initialSnapshot: snapshot, snapshots: snapshots),
  );
}

class GroupFocusLobbySelection {
  const GroupFocusLobbySelection._({this.roomId});

  const GroupFocusLobbySelection.create() : this._();

  const GroupFocusLobbySelection.join(String roomId) : this._(roomId: roomId);

  final String? roomId;

  bool get createsRoom => roomId == null;
}

class GroupFocusLobbySheet extends StatelessWidget {
  const GroupFocusLobbySheet({
    super.key,
    required this.initialSnapshot,
    required this.snapshots,
  });

  final SocialFocusLobbySnapshot initialSnapshot;
  final Stream<SocialFocusLobbySnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SocialFocusLobbySnapshot>(
      stream: snapshots,
      initialData: initialSnapshot,
      builder: (context, snapshot) {
        return _GroupFocusLobbyContent(
          snapshot: snapshot.data ?? initialSnapshot,
        );
      },
    );
  }
}

class _GroupFocusLobbyContent extends StatelessWidget {
  const _GroupFocusLobbyContent({required this.snapshot});

  final SocialFocusLobbySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context);
    final compact = mediaQuery.size.height < 760;
    final contentGap = compact ? AppSpacing.md : AppSpacing.lg;

    return SafeArea(
      top: false,
      bottom: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
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
              _GroupFocusHeader(
                compact: compact,
                onCancel: () => Navigator.of(context).pop(),
                onCreate: () => Navigator.of(
                  context,
                ).pop(const GroupFocusLobbySelection.create()),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _CreateRoomRow(
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(const GroupFocusLobbySelection.create()),
                      ),
                      SizedBox(height: contentGap),
                      _SectionLabel(l10n.friendsFocusingNow),
                      const SizedBox(height: AppSpacing.xs),
                      _RoomsList(rooms: snapshot.openRooms),
                      SizedBox(height: contentGap),
                      _SectionLabel(l10n.friends),
                      const SizedBox(height: AppSpacing.xs),
                      _FriendsList(friends: snapshot.friends),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupFocusHeader extends StatelessWidget {
  const _GroupFocusHeader({
    required this.compact,
    required this.onCancel,
    required this.onCreate,
  });

  final bool compact;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: compact ? 58 : 72,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              AppHaptics.selection();
              onCancel();
            },
            icon: const Icon(CupertinoIcons.xmark, size: 30),
          ),
          Expanded(
            child: Text(
              l10n.groupFocus,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(fontSize: compact ? 24 : 28),
            ),
          ),
          IconButton(
            onPressed: () {
              AppHaptics.lightImpact();
              onCreate();
            },
            icon: const Icon(CupertinoIcons.plus, size: 30),
          ),
        ],
      ),
    );
  }
}

class _CreateRoomRow extends StatelessWidget {
  const _CreateRoomRow({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _ListGroup(
      children: [
        _ListRow(
          leading: const Icon(CupertinoIcons.plus_circle_fill),
          title: l10n.createOpenRoom,
          subtitle: l10n.createOpenRoomSubtitle,
          trailing: const _Chevron(),
          onTap: onPressed,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.grayWarm,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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

class _RoomsList extends StatelessWidget {
  const _RoomsList({required this.rooms});

  final List<SocialFocusRoom> rooms;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return _ListGroup(
        children: [
          _EmptyRow(
            leading: const Icon(CupertinoIcons.person_2),
            title: l10n.noRoomsRightNow,
            subtitle: l10n.noRoomsSubtitle,
          ),
        ],
      );
    }

    return _ListGroup(
      children: [
        for (var index = 0; index < rooms.length; index++)
          _RoomRow(room: rooms[index], showDivider: index < rooms.length - 1),
      ],
    );
  }
}

class _FriendsList extends StatelessWidget {
  const _FriendsList({required this.friends});

  final List<SocialFocusFriend> friends;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return _ListGroup(
        children: [
          _EmptyRow(
            leading: const Icon(CupertinoIcons.person),
            title: l10n.noFriendsYet,
            subtitle: l10n.noFriendsSubtitle,
          ),
        ],
      );
    }

    return _ListGroup(
      children: [
        for (var index = 0; index < friends.length; index++)
          _FriendRow(
            friend: friends[index],
            showDivider: index < friends.length - 1,
          ),
      ],
    );
  }
}

class _RoomRow extends StatelessWidget {
  const _RoomRow({required this.room, required this.showDivider});

  final SocialFocusRoom room;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final full = room.members.length >= room.capacity;

    return _ListRow(
      leading: const Icon(CupertinoIcons.person_2_fill),
      title: l10n.roomTitle(room.hostName),
      subtitle: '${_roomStatusLabel(room, l10n)} • ${room.memberNames}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(room.seatsLabel, style: AppTextStyles.caption),
          const SizedBox(width: AppSpacing.xs),
          full
              ? _StatusText(l10n.full, enabled: false)
              : _ActionText(l10n.join),
        ],
      ),
      showDivider: showDivider,
      onTap: full
          ? null
          : () => Navigator.of(
              context,
            ).pop(GroupFocusLobbySelection.join(room.id)),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.friend, required this.showDivider});

  final SocialFocusFriend friend;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = friend.status == SocialFocusFriendStatus.online;

    return _ListRow(
      leading: const Icon(CupertinoIcons.person),
      title: friend.name,
      subtitle: _friendStatusLabel(friend.status, l10n),
      trailing: _StatusText(
        available ? l10n.available : _friendStatusLabel(friend.status, l10n),
        enabled: available,
      ),
      showDivider: showDivider,
    );
  }

  String _friendStatusLabel(
    SocialFocusFriendStatus status,
    AppLocalizations l10n,
  ) {
    return switch (status) {
      SocialFocusFriendStatus.online => l10n.online,
      SocialFocusFriendStatus.focusing => l10n.focusing,
      SocialFocusFriendStatus.offline => l10n.offline,
    };
  }
}

String _roomStatusLabel(SocialFocusRoom room, AppLocalizations l10n) {
  if (room.members.length >= room.capacity) {
    return l10n.fullRoom;
  }
  if (room.members.length <= 1) {
    return l10n.startingPomodoro;
  }

  return l10n.friendsInRoom(room.members.length);
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  final Widget leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconTheme(
            data: const IconThemeData(color: AppColors.grayWarm, size: 24),
            child: SizedBox(width: 28, child: Center(child: leading)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.charcoal.withValues(alpha: .76),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.showDivider = false,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                IconTheme(
                  data: const IconThemeData(
                    color: AppColors.charcoal,
                    size: 24,
                  ),
                  child: SizedBox(width: 28, child: Center(child: leading)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                trailing,
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
      ),
    );
  }
}

class _ActionText extends StatelessWidget {
  const _ActionText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText(this.label, {required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: enabled ? AppColors.charcoal : AppColors.grayWarm,
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.chevron_forward,
      color: AppColors.grayWarm,
      size: 18,
    );
  }
}
