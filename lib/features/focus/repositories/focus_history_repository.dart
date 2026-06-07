import 'package:pats_space/features/focus/models/focus_session_record.dart';

abstract class FocusHistoryRepository {
  Future<List<FocusSessionRecord>> loadRecords();

  Future<void> saveRecords(List<FocusSessionRecord> records);

  Future<void> clearRecords();
}
