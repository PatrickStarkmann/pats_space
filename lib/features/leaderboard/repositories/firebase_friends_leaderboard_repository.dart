import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pats_space/core/auth/auth_session.dart';
import 'package:pats_space/features/leaderboard/models/friends_leaderboard_entry.dart';
import 'package:pats_space/features/leaderboard/repositories/friends_leaderboard_repository.dart';

class FirebaseFriendsLeaderboardRepository
    implements FriendsLeaderboardRepository {
  FirebaseFriendsLeaderboardRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<void> watchFriendships() {
    final user = requireCurrentUser(_auth);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .snapshots()
        .map((_) {});
  }

  @override
  Future<List<FriendsLeaderboardEntry>> loadCurrentWeek() async {
    final user = requireCurrentUser(_auth);
    final friends = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .get();
    final ids = <String>[
      user.uid,
      ...friends.docs.map((doc) => doc.id).where((id) => id != user.uid),
    ];
    final weekId = _weekId(DateTime.now());
    final docs = await Future.wait(
      ids.map((id) => _scoreRef(id, weekId).get()),
    );
    return [
      for (var index = 0; index < docs.length; index++)
        if (docs[index].exists)
          FriendsLeaderboardEntry(
            userId: ids[index],
            displayName:
                (docs[index].data()?['displayName'] as String?)
                        ?.trim()
                        .isNotEmpty ==
                    true
                ? docs[index].data()!['displayName'] as String
                : 'Pat',
            focusSeconds:
                (docs[index].data()?['focusSeconds'] as num?)?.toInt() ?? 0,
            isCurrentUser: ids[index] == user.uid,
          ),
    ];
  }

  @override
  Future<void> syncOwnCurrentWeek({required int focusSeconds}) async {
    final user = requireCurrentUser(_auth);
    await _scoreRef(user.uid, _weekId(DateTime.now())).set({
      'displayName': user.displayName?.trim().isNotEmpty == true
          ? user.displayName
          : 'Pat',
      'focusSeconds': focusSeconds,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> addFocusTime({required Duration duration}) async {
    if (duration <= Duration.zero) return;
    final user = requireCurrentUser(_auth);
    await _scoreRef(user.uid, _weekId(DateTime.now())).set({
      'displayName': user.displayName?.trim().isNotEmpty == true
          ? user.displayName
          : 'Pat',
      'focusSeconds': FieldValue.increment(duration.inSeconds),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _scoreRef(
    String userId,
    String weekId,
  ) => _firestore
      .collection('users')
      .doc(userId)
      .collection('leaderboard')
      .doc(weekId);

  String _weekId(DateTime value) {
    final date = DateTime(value.year, value.month, value.day);
    final monday = date.subtract(
      Duration(days: date.weekday - DateTime.monday),
    );
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }
}
