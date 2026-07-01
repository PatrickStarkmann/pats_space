enum SocialFocusActivity { reading, studying, working }

enum SocialFocusFriendStatus { online, focusing, offline }

enum SocialFocusMemberStatus { idle, focusing, breakTime }

extension SocialFocusActivitySerialization on SocialFocusActivity {
  String get value => name;

  static SocialFocusActivity fromValue(Object? value) {
    return SocialFocusActivity.values.firstWhere(
      (activity) => activity.name == value,
      orElse: () => SocialFocusActivity.working,
    );
  }
}

extension SocialFocusMemberStatusSerialization on SocialFocusMemberStatus {
  String get value => name;

  static SocialFocusMemberStatus fromValue(Object? value) {
    return SocialFocusMemberStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SocialFocusMemberStatus.idle,
    );
  }
}

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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'activity': activity.value,
      'status': status.value,
    };
  }

  static SocialFocusMember fromJson(Map<String, Object?> json) {
    return SocialFocusMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Friend',
      activity: SocialFocusActivitySerialization.fromValue(json['activity']),
      status: SocialFocusMemberStatusSerialization.fromValue(json['status']),
    );
  }
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

  SocialFocusRoom copyWith({
    String? id,
    String? hostName,
    String? statusLabel,
    List<SocialFocusMember>? members,
    int? capacity,
  }) {
    return SocialFocusRoom(
      id: id ?? this.id,
      hostName: hostName ?? this.hostName,
      statusLabel: statusLabel ?? this.statusLabel,
      members: members ?? this.members,
      capacity: capacity ?? this.capacity,
    );
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
