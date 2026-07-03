import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pats_space/core/auth/auth_session.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/repositories/focus_history_json_codec.dart';
import 'package:pats_space/features/focus/repositories/focus_history_repository.dart';

class FirebaseFocusHistoryRepository implements FocusHistoryRepository {
  FirebaseFocusHistoryRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  static const _codec = FocusHistoryJsonCodec();
  static const _maxStoredRecords = 500;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<List<FocusSessionRecord>> loadRecords() async {
    final doc = await _historyRef().get();
    final records = doc.data()?['records'];
    if (records is! List) {
      return const [];
    }

    return records
        .whereType<Map<String, dynamic>>()
        .map(_codec.recordFromJson)
        .whereType<FocusSessionRecord>()
        .toList();
  }

  @override
  Future<void> saveRecords(List<FocusSessionRecord> records) async {
    await _historyRef().set({
      'records': records
          .take(_maxStoredRecords)
          .map(_codec.recordToJson)
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> clearRecords() async {
    await _historyRef().delete();
  }

  DocumentReference<Map<String, dynamic>> _historyRef() {
    final user = requireCurrentUser(_auth);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('private')
        .doc('focus_history');
  }
}
