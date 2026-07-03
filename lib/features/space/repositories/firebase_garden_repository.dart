import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pats_space/core/auth/auth_session.dart';
import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/garden_repository.dart';
import 'package:pats_space/features/space/repositories/garden_state_json_codec.dart';

class FirebaseGardenRepository implements GardenRepository {
  FirebaseGardenRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  static const _codec = GardenStateJsonCodec();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<GardenState?> loadState() async {
    final doc = await _gardenRef().get();
    final data = doc.data();
    if (data == null) {
      return null;
    }

    return _codec.stateFromJson(data);
  }

  @override
  Future<void> saveState(GardenState state) async {
    await _gardenRef().set({
      ..._codec.stateToJson(state),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearState() async {
    await _gardenRef().delete();
  }

  DocumentReference<Map<String, dynamic>> _gardenRef() {
    final user = requireCurrentUser(_auth);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('private')
        .doc('garden');
  }
}
