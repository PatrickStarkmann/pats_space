import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class FirebasePresenceRepository with WidgetsBindingObserver {
  FirebasePresenceRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    this.heartbeatInterval = const Duration(seconds: 45),
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Duration heartbeatInterval;
  Timer? _heartbeatTimer;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _markSeen();
    _startHeartbeat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _markSeen();
        _startHeartbeat();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _stopHeartbeat();
        _markSeen();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopHeartbeat();
    _markSeen();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) => _markSeen());
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _markSeen() async {
    try {
      final user = await _ensureSignedIn();
      await _firestore.collection('users').doc(user.uid).set({
        'lastSeenAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Presence is best-effort; stale timestamps naturally expire offline.
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
}
