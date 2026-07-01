class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.friendCode,
  });

  final String uid;
  final String displayName;
  final String friendCode;
}

class FriendRequest {
  const FriendRequest({
    required this.uid,
    required this.displayName,
    required this.friendCode,
  });

  final String uid;
  final String displayName;
  final String friendCode;
}

class UserFriend {
  const UserFriend({
    required this.uid,
    required this.displayName,
    required this.friendCode,
  });

  final String uid;
  final String displayName;
  final String friendCode;
}
