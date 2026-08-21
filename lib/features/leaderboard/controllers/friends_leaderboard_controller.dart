import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/leaderboard/models/friends_leaderboard_entry.dart';
import 'package:pats_space/features/leaderboard/repositories/friends_leaderboard_repository.dart';

class FriendsLeaderboardController extends ChangeNotifier {
  FriendsLeaderboardController({
    required FriendsLeaderboardRepository repository,
  }) : _repository = repository;

  final FriendsLeaderboardRepository _repository;
  List<FriendsLeaderboardEntry> _entries = const [];
  bool _loading = false;
  int _ownFocusSeconds = 0;
  StreamSubscription<void>? _friendshipsSubscription;

  List<FriendsLeaderboardEntry> get entries => List.unmodifiable(_entries);
  bool get loading => _loading;
  int get ownFocusSeconds => _ownFocusSeconds;

  Future<void> initialize(List<FocusSessionRecord> records) async {
    _watchFriendships();
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final seconds = records
        .where((record) => !record.completedAt.isBefore(monday))
        .fold(0, (total, record) => total + record.focusDuration.inSeconds);
    _ownFocusSeconds = seconds;
    notifyListeners();
    try {
      await _repository.syncOwnCurrentWeek(focusSeconds: seconds);
    } catch (_) {}
    await refresh();
  }

  Future<void> addFocusTime(Duration duration) async {
    if (duration <= Duration.zero) return;
    _ownFocusSeconds += duration.inSeconds;
    notifyListeners();
    try {
      await _repository.addFocusTime(duration: duration);
      await refresh();
    } catch (_) {}
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      final entries = await _repository.loadCurrentWeek();
      entries.sort((a, b) => b.focusSeconds.compareTo(a.focusSeconds));
      _entries = entries;
      final ownEntry = entries.where((entry) => entry.isCurrentUser);
      if (ownEntry.isNotEmpty) {
        _ownFocusSeconds = ownEntry.first.focusSeconds;
      }
    } catch (_) {
      _entries = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _watchFriendships() {
    _friendshipsSubscription?.cancel();
    try {
      _friendshipsSubscription = _repository.watchFriendships().listen(
        (_) => unawaited(refresh()),
        onError: (_, _) {},
      );
    } catch (_) {
      // The leaderboard still works through explicit refreshes while offline.
    }
  }

  @override
  void dispose() {
    _friendshipsSubscription?.cancel();
    super.dispose();
  }
}
