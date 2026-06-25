import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/social_focus/models/social_focus_models.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_header.dart';

Future<GroupFocusLobbySelection?> showGroupFocusLobbySheet({
  required BuildContext context,
  required SocialFocusLobbySnapshot snapshot,
}) {
  return showModalBottomSheet<GroupFocusLobbySelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => GroupFocusLobbySheet(snapshot: snapshot),
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
  const GroupFocusLobbySheet({super.key, required this.snapshot});

  final SocialFocusLobbySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
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
                      const _SectionLabel('Friends focusing now'),
                      const SizedBox(height: AppSpacing.xs),
                      _RoomsList(rooms: snapshot.openRooms),
                      SizedBox(height: contentGap),
                      const _SectionLabel('Friends'),
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
    return SizedBox(
      height: compact ? 58 : 72,
      child: Row(
        children: [
          IconButton(
            onPressed: onCancel,
            icon: const Icon(CupertinoIcons.xmark, size: 30),
          ),
          Expanded(
            child: Text(
              'Group Focus',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(fontSize: compact ? 24 : 28),
            ),
          ),
          IconButton(
            onPressed: onCreate,
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
    return _ListGroup(
      children: [
        _ListRow(
          leading: const Icon(CupertinoIcons.plus_circle_fill),
          title: 'Create open room',
          subtitle: 'Friends can join while you focus',
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
      return const _ListGroup(
        children: [
          _EmptyRow(
            leading: Icon(CupertinoIcons.person_2),
            title: 'No rooms right now',
            subtitle: 'Create a room so friends can join you.',
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
      return const _ListGroup(
        children: [
          _EmptyRow(
            leading: Icon(CupertinoIcons.person),
            title: 'No friends yet',
            subtitle: 'Friends you add will appear here.',
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
    final full = room.members.length >= room.capacity;

    return _ListRow(
      leading: const Icon(CupertinoIcons.person_2_fill),
      title: '${room.hostName}\'s room',
      subtitle: '${room.statusLabel} • ${room.memberNames}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(room.seatsLabel, style: AppTextStyles.caption),
          const SizedBox(width: AppSpacing.xs),
          full
              ? const _StatusText('Full', enabled: false)
              : const _ActionText('Join'),
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
    final available = friend.status == SocialFocusFriendStatus.online;

    return _ListRow(
      leading: const Icon(CupertinoIcons.person),
      title: friend.name,
      subtitle: _friendStatusLabel(friend.status),
      trailing: _StatusText(
        available ? 'Available' : _friendStatusLabel(friend.status),
        enabled: available,
      ),
      showDivider: showDivider,
    );
  }

  String _friendStatusLabel(SocialFocusFriendStatus status) {
    return switch (status) {
      SocialFocusFriendStatus.online => 'online',
      SocialFocusFriendStatus.focusing => 'focusing',
      SocialFocusFriendStatus.offline => 'offline',
    };
  }
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
