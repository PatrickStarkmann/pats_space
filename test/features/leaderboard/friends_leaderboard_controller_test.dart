import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_tag.dart';
import 'package:pats_space/features/leaderboard/controllers/friends_leaderboard_controller.dart';
import 'package:pats_space/features/leaderboard/models/friends_leaderboard_entry.dart';
import 'package:pats_space/features/leaderboard/repositories/friends_leaderboard_repository.dart';

void main() {
  test(
    'keeps qualifying partial focus time after a leaderboard restart',
    () async {
      final repository = _FakeFriendsLeaderboardRepository();
      final controller = FriendsLeaderboardController(repository: repository);
      addTearDown(controller.dispose);
      final now = DateTime.now();
      final partialRecord = FocusSessionRecord(
        id: 'partial-focus',
        tag: const FocusTag(
          name: 'study',
          accentColor: FocusAccentColor.sage,
          badgeIcon: FocusBadgeIcon.character,
        ),
        mode: FocusMode.pomodoro,
        focusDuration: const Duration(minutes: 5),
        startedAt: now.subtract(const Duration(minutes: 5)),
        completedAt: now,
        animationPair: FocusAnimationPair.standard,
        waterReward: 1,
      );

      await controller.initialize([partialRecord]);

      expect(repository.syncedFocusSeconds, 5 * 60);
      expect(controller.ownFocusSeconds, 5 * 60);
    },
  );
}

class _FakeFriendsLeaderboardRepository
    implements FriendsLeaderboardRepository {
  int syncedFocusSeconds = 0;

  @override
  Future<void> addFocusTime({required Duration duration}) async {
    syncedFocusSeconds += duration.inSeconds;
  }

  @override
  Future<List<FriendsLeaderboardEntry>> loadCurrentWeek() async => [
    FriendsLeaderboardEntry(
      userId: 'current-user',
      displayName: 'Pat',
      focusSeconds: syncedFocusSeconds,
      isCurrentUser: true,
    ),
  ];

  @override
  Future<void> syncOwnCurrentWeek({required int focusSeconds}) async {
    syncedFocusSeconds = focusSeconds;
  }

  @override
  Stream<void> watchFriendships() => const Stream.empty();
}
