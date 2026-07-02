import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:pats_space/app/patsspace_app.dart';
import 'package:pats_space/core/auth/auth_session.dart';
import 'package:pats_space/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ensureAnonymousSession(FirebaseAuth.instance);
  runApp(const PatsspaceApp());
}
