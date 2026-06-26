enum SocialFocusActivity { reading, studying, working }

enum SocialFocusFriendStatus { online, focusing, offline }

enum SocialFocusMemberStatus { idle, focusing, breakTime }

class SocialFocusFriend {
  const SocialFocusFriend({
    required this.id,
    required this.name,
    required this.status,
  });

  final String id;
  final String name;
  final SocialFocusFriendStatus status;
}

class SocialFocusMember {
  const SocialFocusMember({
    required this.id,
    required this.name,
    required this.activity,
    this.status = SocialFocusMemberStatus.idle,
  });

  final String id;
  final String name;
  final SocialFocusActivity activity;
  final SocialFocusMemberStatus status;
}

class SocialFocusRoom {
  const SocialFocusRoom({
    required this.id,
    required this.hostName,
    required this.statusLabel,
    required this.members,
    this.capacity = 4,
  });

  final String id;
  final String hostName;
  final String statusLabel;
  final List<SocialFocusMember> members;
  final int capacity;

  String get seatsLabel => '${members.length}/$capacity';

  String get memberNames {
    return members.map((member) => member.name).join(', ');
  }
}

class SocialFocusLobbySnapshot {
  const SocialFocusLobbySnapshot({
    required this.openRooms,
    required this.friends,
  });

  final List<SocialFocusRoom> openRooms;
  final List<SocialFocusFriend> friends;
}
