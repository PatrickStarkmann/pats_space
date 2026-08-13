import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pats_space/app/patsspace_app.dart';
import 'package:pats_space/core/auth/auth_session.dart';
import 'package:pats_space/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _configureCrashlytics();
  await ensureAnonymousSession(FirebaseAuth.instance);
  runApp(const PatsspaceApp());
}

void _configureCrashlytics() {
  if (!_supportsCrashlytics) {
    return;
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

bool get _supportsCrashlytics => switch (defaultTargetPlatform) {
  TargetPlatform.android || TargetPlatform.iOS => true,
  TargetPlatform.fuchsia ||
  TargetPlatform.linux ||
  TargetPlatform.macOS ||
  TargetPlatform.windows => false,
};
