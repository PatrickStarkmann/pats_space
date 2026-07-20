import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RemoteAvailabilityService {
  const RemoteAvailabilityService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required Connectivity connectivity,
  }) : _auth = auth,
       _firestore = firestore,
       _connectivity = connectivity;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;

  Stream<bool> get hasNetworkConnection {
    return _connectivity.onConnectivityChanged.map(_hasNetworkConnection);
  }

  Future<bool> checkNetworkConnection() async {
    return _hasNetworkConnection(await _connectivity.checkConnectivity());
  }

  Future<bool> checkRemoteAvailable() async {
    if (!await checkNetworkConnection()) {
      return false;
    }

    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 2));
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _hasNetworkConnection(List<ConnectivityResult> results) {
    return !results.contains(ConnectivityResult.none);
  }
}
