import 'package:firebase_auth/firebase_auth.dart';
import 'package:pats_space/features/pro/controllers/pro_controller.dart';

/// Shared app-level entitlement state. It is initialized in [PatsspaceApp].
final proController = ProController(auth: FirebaseAuth.instance);
