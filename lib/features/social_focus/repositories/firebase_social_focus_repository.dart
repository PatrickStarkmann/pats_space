import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pats_space/features/social_focus/models/social_focus_models.dart';
import 'package:pats_space/features/social_focus/repositories/social_focus_repository.dart';

class FirebaseSocialFocusRepository implements SocialFocusRepository {
  FirebaseSocialFocusRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  static const _roomCapacity = 4;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('social_focus_rooms');

  DocumentReference<Map<String, dynamic>> _userRef(String userId) =>
      _firestore.collection('users').doc(userId);

  @override
  Future<SocialFocusLobbySnapshot> loadLobby() async {
    final user = await _ensureSignedIn();
    final friends = await _loadFriends(user.uid);
    final friendIds = friends.map((friend) => friend.id).toSet();
    final snapshot = await _rooms
        .where('isOpen', isEqualTo: true)
        .limit(20)
        .get();

    final rooms = await Future.wait(
      snapshot.docs.map((doc) => _roomFromDocument(doc)),
    );
    final openRooms = rooms
        .where(
          (room) =>
              room.members.length < room.capacity &&
              !room.members.any((member) => member.id == user.uid) &&
              _containsFriend(room, friendIds),
        )
        .toList();
    final focusingFriendIds = rooms
        .expand((room) => room.members)
        .where((member) => friendIds.contains(member.id))
        .map((member) => member.id)
        .toSet();
    final friendsWithStatus = [
      for (final friend in friends)
        SocialFocusFriend(
          id: friend.id,
          name: friend.name,
          status: focusingFriendIds.contains(friend.id)
              ? SocialFocusFriendStatus.focusing
              : SocialFocusFriendStatus.online,
        ),
    ];

    return SocialFocusLobbySnapshot(
      openRooms: openRooms,
      friends: friendsWithStatus,
    );
  }

  @override
  Future<SocialFocusRoom?> restoreActiveRoom() async {
    final user = await _ensureSignedIn();
    final storedRoomId = await _loadActiveRoomId(user.uid);
    if (storedRoomId != null) {
      final room = await _restoreRoomForUser(storedRoomId, user.uid);
      if (room != null) {
        return room;
      }
    }

    final QuerySnapshot<Map<String, dynamic>> staleMembership;
    try {
      staleMembership = await _firestore
          .collectionGroup('members')
          .where('id', isEqualTo: user.uid)
          .limit(1)
          .get();
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied' ||
          error.code == 'failed-precondition') {
        return null;
      }
      rethrow;
    }
    if (staleMembership.docs.isEmpty) {
      return null;
    }

    final roomRef = staleMembership.docs.first.reference.parent.parent;
    if (roomRef == null) {
      return null;
    }

    final room = await _restoreRoomForUser(roomRef.id, user.uid);
    if (room != null) {
      await _storeActiveRoomId(user.uid, room.id);
    }
    return room;
  }

  @override
  Stream<SocialFocusRoom?> watchRoom(String roomId) {
    final roomRef = _rooms.doc(roomId);
    return roomRef.snapshots().asyncMap((doc) async {
      if (!doc.exists) {
        return null;
      }

      final room = await _roomFromDocument(doc);
      return room.members.isEmpty ? null : room;
    });
  }

  @override
  Future<SocialFocusRoom> createOpenRoom() async {
    final user = await _ensureSignedIn();
    await _leavePreviousRoom(user.uid);
    final roomRef = _rooms.doc();
    final member = await _localMember(user);
    final now = FieldValue.serverTimestamp();

    await roomRef.set({
      'hostUid': user.uid,
      'hostName': member.name,
      'statusLabel': 'open room',
      'capacity': _roomCapacity,
      'isOpen': true,
      'createdAt': now,
      'updatedAt': now,
    });
    await roomRef.collection('members').doc(user.uid).set({
      ...member.toJson(),
      'joinedAt': now,
      'updatedAt': now,
    });
    await _storeActiveRoomId(user.uid, roomRef.id);

    return _roomFromReference(roomRef);
  }

  @override
  Future<SocialFocusRoom> joinRoom(String roomId) async {
    final user = await _ensureSignedIn();
    await _leavePreviousRoom(user.uid, exceptRoomId: roomId);
    final roomRef = _rooms.doc(roomId);
    final member = await _localMember(user);

    final currentRoom = await _roomFromReference(roomRef);
    final alreadyJoined = currentRoom.members.any(
      (roomMember) => roomMember.id == user.uid,
    );
    if (!alreadyJoined && currentRoom.members.length >= currentRoom.capacity) {
      throw StateError('Social focus room is full.');
    }

    final now = FieldValue.serverTimestamp();
    await roomRef.collection('members').doc(user.uid).set({
      ...member.toJson(),
      'joinedAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
    await roomRef.update({'isOpen': true, 'updatedAt': now});
    await _storeActiveRoomId(user.uid, roomId);

    return _roomFromReference(roomRef);
  }

  @override
  Future<SocialFocusRoom> updateLocalActivity(
    String roomId,
    SocialFocusActivity activity,
  ) async {
    final user = await _ensureSignedIn();
    final now = FieldValue.serverTimestamp();
    await _rooms.doc(roomId).collection('members').doc(user.uid).set({
      'id': user.uid,
      'name': await _loadDisplayName(user),
      'activity': activity.value,
      'updatedAt': now,
    }, SetOptions(merge: true));
    await _rooms.doc(roomId).update({'updatedAt': now});

    return _roomFromReference(_rooms.doc(roomId));
  }

  @override
  Future<SocialFocusRoom> updateLocalStatus(
    String roomId,
    SocialFocusMemberStatus status,
  ) async {
    final user = await _ensureSignedIn();
    final now = FieldValue.serverTimestamp();
    await _rooms.doc(roomId).collection('members').doc(user.uid).set({
      'id': user.uid,
      'name': await _loadDisplayName(user),
      'status': status.value,
      'updatedAt': now,
    }, SetOptions(merge: true));
    await _rooms.doc(roomId).update({'updatedAt': now});

    return _roomFromReference(_rooms.doc(roomId));
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    final user = await _ensureSignedIn();
    final roomRef = _rooms.doc(roomId);
    await roomRef.collection('members').doc(user.uid).delete();

    final roomDoc = await roomRef.get();
    if (!roomDoc.exists) {
      return;
    }

    final remainingMembers = await roomRef.collection('members').limit(1).get();
    final isHost = roomDoc.data()?['hostUid'] == user.uid;
    if (remainingMembers.docs.isEmpty && isHost) {
      await roomRef.delete();
    } else if (isHost) {
      final nextHost = remainingMembers.docs.first;
      await roomRef.update({
        'hostUid': nextHost.id,
        'hostName': nextHost.data()['name'] as String? ?? 'Friend',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else if (remainingMembers.docs.isEmpty || isHost) {
      await roomRef.update({
        'isOpen': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await roomRef.update({'updatedAt': FieldValue.serverTimestamp()});
    }
    await _clearActiveRoomId(user.uid);
  }

  Future<User> _ensureSignedIn() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser;
    }

    final credential = await _auth.signInAnonymously();
    return credential.user!;
  }

  Future<SocialFocusMember> _localMember(User user) async {
    return SocialFocusMember(
      id: user.uid,
      name: await _loadDisplayName(user),
      activity: SocialFocusActivity.working,
    );
  }

  Future<String> _loadDisplayName(User user) async {
    final snapshot = await _userRef(user.uid).get();
    return _cleanDisplayName(
      snapshot.data()?['displayName'] as String? ?? user.displayName,
      fallbackUid: user.uid,
    );
  }

  String _cleanDisplayName(String? displayName, {required String fallbackUid}) {
    final trimmedName = displayName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName.length > 24
          ? trimmedName.substring(0, 24)
          : trimmedName;
    }

    final suffix = fallbackUid.length >= 4
        ? fallbackUid.substring(fallbackUid.length - 4).toUpperCase()
        : fallbackUid.toUpperCase();
    return 'Guest $suffix';
  }

  Future<List<SocialFocusFriend>> _loadFriends(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          return SocialFocusFriend(
            id: doc.id,
            name: _cleanDisplayName(
              data['displayName'] as String?,
              fallbackUid: doc.id,
            ),
            status: SocialFocusFriendStatus.online,
          );
        })
        .toList(growable: false);
  }

  bool _containsFriend(SocialFocusRoom room, Set<String> friendIds) {
    if (friendIds.isEmpty) {
      return false;
    }

    return room.members.any((member) => friendIds.contains(member.id));
  }

  Future<String?> _loadActiveRoomId(String userId) async {
    final doc = await _userRef(userId).get();
    return doc.data()?['activeSocialFocusRoomId'] as String?;
  }

  Future<void> _storeActiveRoomId(String userId, String roomId) async {
    await _userRef(userId).set({
      'activeSocialFocusRoomId': roomId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _clearActiveRoomId(String userId) async {
    await _userRef(userId).set({
      'activeSocialFocusRoomId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _leavePreviousRoom(String userId, {String? exceptRoomId}) async {
    final activeRoomId = await _loadActiveRoomId(userId);
    if (activeRoomId == null || activeRoomId == exceptRoomId) {
      return;
    }

    await leaveRoom(activeRoomId);
  }

  Future<SocialFocusRoom?> _restoreRoomForUser(
    String roomId,
    String userId,
  ) async {
    final roomRef = _rooms.doc(roomId);
    final roomDoc = await roomRef.get();
    final roomData = roomDoc.data();
    if (!roomDoc.exists || roomData?['isOpen'] != true) {
      await _clearActiveRoomId(userId);
      return null;
    }

    final memberDoc = await roomRef.collection('members').doc(userId).get();
    if (!memberDoc.exists) {
      await _clearActiveRoomId(userId);
      return null;
    }

    return _roomFromDocument(roomDoc);
  }

  Future<SocialFocusRoom> _roomFromReference(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final doc = await ref.get();
    if (!doc.exists) {
      throw StateError('Social focus room does not exist.');
    }

    return _roomFromDocument(doc);
  }

  Future<SocialFocusRoom> _roomFromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data() ?? const <String, dynamic>{};
    final membersSnapshot = await doc.reference
        .collection('members')
        .orderBy('joinedAt')
        .get();
    final members = membersSnapshot.docs
        .map((memberDoc) {
          return SocialFocusMember.fromJson({
            ...memberDoc.data(),
            'id': memberDoc.id,
          });
        })
        .toList(growable: false);

    return SocialFocusRoom(
      id: doc.id,
      hostName: data['hostName'] as String? ?? 'Friend',
      statusLabel: data['statusLabel'] as String? ?? 'open room',
      capacity: data['capacity'] as int? ?? _roomCapacity,
      members: members,
    );
  }
}
