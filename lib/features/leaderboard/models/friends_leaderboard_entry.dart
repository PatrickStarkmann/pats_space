class FriendsLeaderboardEntry {
  const FriendsLeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.focusSeconds,
    this.isCurrentUser = false,
  });

  final String userId;
  final String displayName;
  final int focusSeconds;
  final bool isCurrentUser;
}
