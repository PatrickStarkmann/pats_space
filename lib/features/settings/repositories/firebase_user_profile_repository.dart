import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pats_space/features/settings/models/user_profile.dart';
import 'package:pats_space/features/settings/repositories/user_profile_repository.dart';

class FirebaseUserProfileRepository implements UserProfileRepository {
  FirebaseUserProfileRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserProfile> loadProfile() async {
    final user = await _ensureSignedIn();
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    final data = snapshot.data();
    final displayName = _cleanDisplayName(
      data?['displayName'] as String? ?? user.displayName,
      fallbackUid: user.uid,
    );
    final storedFriendCode = data?['friendCode'] as String?;
    final friendCode =
        storedFriendCode == null || storedFriendCode.startsWith('PAT-')
        ? _friendCodeFor(user.uid)
        : storedFriendCode;

    await userRef.set({
      'displayName': displayName,
      'friendCode': friendCode,
      'searchName': displayName.toLowerCase(),
      'createdAt': data?['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _firestore.collection('friend_codes').doc(friendCode).set({
      'uid': user.uid,
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (user.displayName != displayName) {
      await user.updateDisplayName(displayName);
    }

    return UserProfile(
      uid: user.uid,
      displayName: displayName,
      friendCode: friendCode,
    );
  }

  @override
  Future<UserProfile> saveDisplayName(String displayName) async {
    final user = await _ensureSignedIn();
    final cleanedName = _cleanDisplayName(displayName, fallbackUid: user.uid);
    final currentProfile = await loadProfile();
    await _firestore.collection('users').doc(user.uid).set({
      'displayName': cleanedName,
      'searchName': cleanedName.toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _firestore
        .collection('friend_codes')
        .doc(currentProfile.friendCode)
        .set({
          'displayName': cleanedName,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    await _updateFriendMirrors(
      userId: user.uid,
      displayName: cleanedName,
      friendCode: currentProfile.friendCode,
    );
    await user.updateDisplayName(cleanedName);

    return UserProfile(
      uid: user.uid,
      displayName: cleanedName,
      friendCode: currentProfile.friendCode,
    );
  }

  @override
  Future<List<UserFriend>> loadFriends() async {
    final user = await _ensureSignedIn();
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserFriend(
        uid: doc.id,
        displayName: _cleanDisplayName(
          data['displayName'] as String?,
          fallbackUid: doc.id,
        ),
        friendCode: data['friendCode'] as String? ?? '',
      );
    }).toList();
  }

  @override
  Future<List<FriendRequest>> loadIncomingFriendRequests() async {
    final user = await _ensureSignedIn();
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friend_requests')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FriendRequest(
        uid: doc.id,
        displayName: _cleanDisplayName(
          data['displayName'] as String?,
          fallbackUid: doc.id,
        ),
        friendCode: data['friendCode'] as String? ?? '',
      );
    }).toList();
  }

  @override
  Future<List<FriendRequest>> loadSentFriendRequests() async {
    final user = await _ensureSignedIn();
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sent_friend_requests')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FriendRequest(
        uid: doc.id,
        displayName: _cleanDisplayName(
          data['displayName'] as String?,
          fallbackUid: doc.id,
        ),
        friendCode: data['friendCode'] as String? ?? '',
      );
    }).toList();
  }

  @override
  Future<UserProfile> sendFriendRequestByCode(String friendCode) async {
    final user = await _ensureSignedIn();
    final profile = await loadProfile();
    final normalizedCode = _normalizeFriendCode(friendCode);
    if (normalizedCode == profile.friendCode) {
      throw const FriendCodeException(FriendCodeFailure.self);
    }

    final codeDoc = await _firestore
        .collection('friend_codes')
        .doc(normalizedCode)
        .get();
    final friendUid = codeDoc.data()?['uid'] as String?;
    if (friendUid == null || friendUid.isEmpty) {
      throw const FriendCodeException(FriendCodeFailure.notFound);
    }

    final existingFriend = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(friendUid)
        .get();
    if (existingFriend.exists) {
      return profile;
    }

    final friendProfile = await _firestore
        .collection('users')
        .doc(friendUid)
        .get();
    final friendName = _cleanDisplayName(
      friendProfile.data()?['displayName'] as String?,
      fallbackUid: friendUid,
    );
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();
    batch.set(
      _firestore
          .collection('users')
          .doc(friendUid)
          .collection('friend_requests')
          .doc(user.uid),
      {
        'uid': user.uid,
        'displayName': profile.displayName,
        'friendCode': profile.friendCode,
        'createdAt': now,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );
    batch.set(
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sent_friend_requests')
          .doc(friendUid),
      {
        'uid': friendUid,
        'displayName': friendName,
        'friendCode': normalizedCode,
        'createdAt': now,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );
    await batch.commit();

    return profile;
  }

  @override
  Future<void> acceptFriendRequest(FriendRequest request) async {
    final user = await _ensureSignedIn();
    final profile = await loadProfile();
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();
    batch.set(
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(request.uid),
      {
        'uid': request.uid,
        'displayName': request.displayName,
        'friendCode': request.friendCode,
        'createdAt': now,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );
    batch.set(
      _firestore
          .collection('users')
          .doc(request.uid)
          .collection('friends')
          .doc(user.uid),
      {
        'uid': user.uid,
        'displayName': profile.displayName,
        'friendCode': profile.friendCode,
        'createdAt': now,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );
    batch.delete(
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friend_requests')
          .doc(request.uid),
    );
    batch.delete(
      _firestore
          .collection('users')
          .doc(request.uid)
          .collection('sent_friend_requests')
          .doc(user.uid),
    );
    await batch.commit();
  }

  @override
  Future<void> cancelFriendRequest(FriendRequest request) async {
    final user = await _ensureSignedIn();
    final batch = _firestore.batch();
    batch.delete(
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sent_friend_requests')
          .doc(request.uid),
    );
    batch.delete(
      _firestore
          .collection('users')
          .doc(request.uid)
          .collection('friend_requests')
          .doc(user.uid),
    );
    await batch.commit();
  }

  @override
  Future<void> deleteFriend(UserFriend friend) async {
    final user = await _ensureSignedIn();
    final batch = _firestore.batch();
    batch.delete(
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(friend.uid),
    );
    batch.delete(
      _firestore
          .collection('users')
          .doc(friend.uid)
          .collection('friends')
          .doc(user.uid),
    );
    await batch.commit();
  }

  Future<void> _updateFriendMirrors({
    required String userId,
    required String displayName,
    required String friendCode,
  }) async {
    final ownFriendDocs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .get();
    final sentRequests = await _firestore
        .collection('users')
        .doc(userId)
        .collection('sent_friend_requests')
        .get();

    var batch = _firestore.batch();
    var writeCount = 0;

    Future<void> queueUpdate(
      DocumentReference<Map<String, dynamic>> ref,
    ) async {
      batch.set(ref, {
        'displayName': displayName,
        'friendCode': friendCode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      writeCount += 1;
      if (writeCount == 450) {
        await batch.commit();
        batch = _firestore.batch();
        writeCount = 0;
      }
    }

    for (final friendDoc in ownFriendDocs.docs) {
      await queueUpdate(
        _firestore
            .collection('users')
            .doc(friendDoc.id)
            .collection('friends')
            .doc(userId),
      );
    }
    for (final requestDoc in sentRequests.docs) {
      await queueUpdate(
        _firestore
            .collection('users')
            .doc(requestDoc.id)
            .collection('friend_requests')
            .doc(userId),
      );
    }

    if (writeCount > 0) {
      await batch.commit();
    }
  }

  Future<User> _ensureSignedIn() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser;
    }

    final credential = await _auth.signInAnonymously();
    return credential.user!;
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

  String _friendCodeFor(String uid) {
    final normalizedUid = uid.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    final suffix = normalizedUid.length >= 6
        ? normalizedUid.substring(normalizedUid.length - 6)
        : normalizedUid.padLeft(6, 'X');
    return suffix;
  }

  String _normalizeFriendCode(String friendCode) {
    return friendCode
        .trim()
        .toUpperCase()
        .replaceAll(' ', '')
        .replaceFirst('PAT-', '')
        .replaceAll('-', '');
  }
}

enum FriendCodeFailure { self, notFound }

class FriendCodeException implements Exception {
  const FriendCodeException(this.failure);

  final FriendCodeFailure failure;
}
