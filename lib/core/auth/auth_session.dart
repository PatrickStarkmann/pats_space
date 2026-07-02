import 'package:firebase_auth/firebase_auth.dart';

Future<User> ensureAnonymousSession(FirebaseAuth auth) async {
  final currentUser = auth.currentUser;
  if (currentUser != null) {
    return currentUser;
  }

  final credential = await auth.signInAnonymously();
  final user = credential.user;
  if (user == null) {
    throw FirebaseAuthException(code: 'no-current-user');
  }

  return user;
}

User requireCurrentUser(FirebaseAuth auth) {
  final currentUser = auth.currentUser;
  if (currentUser == null) {
    throw FirebaseAuthException(code: 'no-current-user');
  }

  return currentUser;
}
