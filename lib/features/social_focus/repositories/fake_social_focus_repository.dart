import 'package:pats_space/features/social_focus/models/social_focus_models.dart';
import 'package:pats_space/features/social_focus/repositories/social_focus_repository.dart';

class FakeSocialFocusRepository implements SocialFocusRepository {
  static const _currentUser = SocialFocusMember(
    id: 'me',
    name: 'Patrick',
    activity: SocialFocusActivity.working,
  );

  static const _rooms = [
    SocialFocusRoom(
      id: 'mila-room',
      hostName: 'Mila',
      statusLabel: '2 friends in room',
      members: [
        SocialFocusMember(
          id: 'mila',
          name: 'Mila',
          activity: SocialFocusActivity.reading,
          status: SocialFocusMemberStatus.focusing,
        ),
        SocialFocusMember(
          id: 'leo',
          name: 'Leo',
          activity: SocialFocusActivity.working,
          status: SocialFocusMemberStatus.breakTime,
        ),
      ],
    ),
    SocialFocusRoom(
      id: 'nora-room',
      hostName: 'Nora',
      statusLabel: 'starting a study session',
      members: [
        SocialFocusMember(
          id: 'nora',
          name: 'Nora',
          activity: SocialFocusActivity.studying,
          status: SocialFocusMemberStatus.focusing,
        ),
      ],
    ),
    SocialFocusRoom(
      id: 'sam-room',
      hostName: 'Sam',
      statusLabel: '3 friends in room',
      members: [
        SocialFocusMember(
          id: 'sam',
          name: 'Sam',
          activity: SocialFocusActivity.working,
          status: SocialFocusMemberStatus.focusing,
        ),
        SocialFocusMember(
          id: 'ava',
          name: 'Ava',
          activity: SocialFocusActivity.reading,
          status: SocialFocusMemberStatus.focusing,
        ),
        SocialFocusMember(
          id: 'jonas',
          name: 'Jonas',
          activity: SocialFocusActivity.studying,
          status: SocialFocusMemberStatus.idle,
        ),
      ],
    ),
    SocialFocusRoom(
      id: 'full-room',
      hostName: 'Ava',
      statusLabel: 'full room',
      members: [
        SocialFocusMember(
          id: 'ava-full',
          name: 'Ava',
          activity: SocialFocusActivity.reading,
          status: SocialFocusMemberStatus.focusing,
        ),
        SocialFocusMember(
          id: 'mila-full',
          name: 'Mila',
          activity: SocialFocusActivity.studying,
          status: SocialFocusMemberStatus.focusing,
        ),
        SocialFocusMember(
          id: 'leo-full',
          name: 'Leo',
          activity: SocialFocusActivity.working,
          status: SocialFocusMemberStatus.breakTime,
        ),
        SocialFocusMember(
          id: 'nora-full',
          name: 'Nora',
          activity: SocialFocusActivity.reading,
          status: SocialFocusMemberStatus.idle,
        ),
      ],
    ),
  ];

  static const _friends = [
    SocialFocusFriend(
      id: 'sam',
      name: 'Sam',
      status: SocialFocusFriendStatus.online,
    ),
    SocialFocusFriend(
      id: 'ava',
      name: 'Ava',
      status: SocialFocusFriendStatus.online,
    ),
    SocialFocusFriend(
      id: 'jonas',
      name: 'Jonas',
      status: SocialFocusFriendStatus.offline,
    ),
  ];

  @override
  Future<SocialFocusLobbySnapshot> loadLobby() async {
    return const SocialFocusLobbySnapshot(openRooms: _rooms, friends: _friends);
  }

  @override
  Future<SocialFocusRoom> createOpenRoom() async {
    return const SocialFocusRoom(
      id: 'my-room',
      hostName: 'Patrick',
      statusLabel: 'open room',
      members: [_currentUser],
    );
  }

  @override
  Future<SocialFocusRoom> joinRoom(String roomId) async {
    final room = _rooms.firstWhere(
      (room) => room.id == roomId,
      orElse: () => _rooms.first,
    );

    return SocialFocusRoom(
      id: room.id,
      hostName: room.hostName,
      statusLabel: room.statusLabel,
      capacity: room.capacity,
      members: [_currentUser, ...room.members].take(room.capacity).toList(),
    );
  }

  @override
  Future<void> leaveRoom(String roomId) async {}
}
