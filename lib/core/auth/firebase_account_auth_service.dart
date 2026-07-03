import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pats_space/core/auth/account_auth_service.dart';
import 'package:pats_space/core/auth/auth_session.dart';
import 'package:pats_space/features/social_focus/repositories/firebase_social_focus_repository.dart';

class FirebaseAccountAuthService implements AccountAuthService {
  FirebaseAccountAuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _googleSignInInitialized = false;

  @override
  bool get isAppleSignInAvailable {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  Future<AccountAuthResult> secureWithApple() async {
    final user = await ensureAnonymousSession(_auth);
    try {
      await user.linkWithProvider(_appleProvider());
      return const AccountSecured();
    } on FirebaseAuthException catch (error) {
      if (!_shouldUseExistingAccount(user, error)) {
        rethrow;
      }

      return GuestReplacementRequired(
        provider: AccountSignInProvider.apple,
        guestUid: user.uid,
      );
    }
  }

  @override
  Future<AccountAuthResult> secureWithGoogle() async {
    final user = await ensureAnonymousSession(_auth);
    final credential = await _googleCredential();
    try {
      await user.linkWithCredential(credential);
      return const AccountSecured();
    } on FirebaseAuthException catch (error) {
      if (!_shouldUseExistingAccount(user, error)) {
        rethrow;
      }

      return _GoogleGuestReplacementRequired(
        guestUid: user.uid,
        credential: credential,
      );
    }
  }

  @override
  Future<AccountAuthResult> replaceGuestWithExistingAccount(
    GuestReplacementRequired replacement,
  ) async {
    final guestUser = _auth.currentUser;
    if (guestUser == null ||
        !guestUser.isAnonymous ||
        guestUser.uid != replacement.guestUid) {
      throw FirebaseAuthException(code: 'guest-account-changed');
    }

    await _deleteAccountData(guestUser);
    await guestUser.delete();
    switch (replacement.provider) {
      case AccountSignInProvider.apple:
        await _auth.signInWithProvider(_appleProvider());
      case AccountSignInProvider.google:
        final credential = switch (replacement) {
          _GoogleGuestReplacementRequired() => replacement.credential,
          _ => await _googleCredential(),
        };
        await _auth.signInWithCredential(credential);
    }

    return const ExistingAccountSignedIn();
  }

  @override
  Future<void> signOutToGuest() async {
    await _auth.signOut();
    await ensureAnonymousSession(_auth);
  }

  @override
  Future<void> deleteCurrentAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _reauthenticateForDelete(user);
    await _deleteAccountData(user);
    await user.delete();
    await ensureAnonymousSession(_auth);
  }

  AppleAuthProvider _appleProvider() {
    return AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
  }

  Future<AuthCredential> _googleCredential() async {
    await _ensureGoogleSignInInitialized();
    await GoogleSignIn.instance.signOut();
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: const ['email', 'profile'],
    );
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'missing-google-id-token');
    }

    return GoogleAuthProvider.credential(idToken: idToken);
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) {
      return;
    }

    await GoogleSignIn.instance.initialize();
    _googleSignInInitialized = true;
  }

  bool _shouldUseExistingAccount(User user, FirebaseAuthException error) {
    if (!user.isAnonymous) {
      return false;
    }

    return error.code == 'credential-already-in-use' ||
        error.code == 'account-exists-with-different-credential' ||
        error.code == 'email-already-in-use';
  }

  Future<void> _reauthenticateForDelete(User user) async {
    if (user.isAnonymous) {
      return;
    }

    final providerIds = user.providerData
        .map((provider) => provider.providerId)
        .toSet();
    if (isAppleSignInAvailable &&
        providerIds.contains(AppleAuthProvider.PROVIDER_ID)) {
      await user.reauthenticateWithProvider(_appleProvider());
      return;
    }
    if (providerIds.contains(GoogleAuthProvider.PROVIDER_ID)) {
      final credential = await _googleCredential();
      await user.reauthenticateWithCredential(credential);
    }
  }

  Future<void> _deleteAccountData(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    final userData = userDoc.data();
    final friendCode = userData?['friendCode'] as String?;
    final activeRoomId = userData?['activeSocialFocusRoomId'] as String?;
    if (activeRoomId != null) {
      await FirebaseSocialFocusRepository(
        auth: _auth,
        firestore: _firestore,
      ).leaveRoom(activeRoomId);
    }

    final friends = await userRef.collection('friends').get();
    final incoming = await userRef.collection('friend_requests').get();
    final sent = await userRef.collection('sent_friend_requests').get();
    final privateDocs = await userRef.collection('private').get();
    var batch = _firestore.batch();
    var writeCount = 0;

    Future<void> queueDelete(
      DocumentReference<Map<String, dynamic>> ref,
    ) async {
      batch.delete(ref);
      writeCount += 1;
      if (writeCount >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        writeCount = 0;
      }
    }

    for (final friend in friends.docs) {
      await queueDelete(friend.reference);
      await queueDelete(
        _firestore
            .collection('users')
            .doc(friend.id)
            .collection('friends')
            .doc(user.uid),
      );
    }
    for (final request in incoming.docs) {
      await queueDelete(request.reference);
      await queueDelete(
        _firestore
            .collection('users')
            .doc(request.id)
            .collection('sent_friend_requests')
            .doc(user.uid),
      );
    }
    for (final request in sent.docs) {
      await queueDelete(request.reference);
      await queueDelete(
        _firestore
            .collection('users')
            .doc(request.id)
            .collection('friend_requests')
            .doc(user.uid),
      );
    }
    for (final doc in privateDocs.docs) {
      await queueDelete(doc.reference);
    }
    if (friendCode != null && friendCode.isNotEmpty) {
      await queueDelete(_firestore.collection('friend_codes').doc(friendCode));
    }
    await queueDelete(userRef);
    if (writeCount > 0) {
      await batch.commit();
    }
  }
}

class _GoogleGuestReplacementRequired extends GuestReplacementRequired {
  const _GoogleGuestReplacementRequired({
    required super.guestUid,
    required this.credential,
  }) : super(provider: AccountSignInProvider.google);

  final AuthCredential credential;
}
