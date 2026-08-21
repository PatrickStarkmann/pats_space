import 'package:pats_space/features/leaderboard/models/friends_leaderboard_entry.dart';

abstract interface class FriendsLeaderboardRepository {
  Future<List<FriendsLeaderboardEntry>> loadCurrentWeek();

  Stream<void> watchFriendships();

  Future<void> syncOwnCurrentWeek({required int focusSeconds});

  Future<void> addFocusTime({required Duration duration});
}
