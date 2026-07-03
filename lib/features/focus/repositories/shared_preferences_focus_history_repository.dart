import 'dart:convert';

import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/repositories/focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/focus_history_json_codec.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesFocusHistoryRepository
    implements FocusHistoryRepository {
  const SharedPreferencesFocusHistoryRepository(this._preferences);

  static const _recordsKey = 'focus_history_records_v1';
  static const _codec = FocusHistoryJsonCodec();

  final SharedPreferences _preferences;

  @override
  Future<List<FocusSessionRecord>> loadRecords() async {
    final rawRecords = _preferences.getString(_recordsKey);
    if (rawRecords == null) {
      return const [];
    }

    final json = jsonDecode(rawRecords);
    if (json is! List) {
      return const [];
    }

    return json
        .whereType<Map<String, dynamic>>()
        .map(_codec.recordFromJson)
        .whereType<FocusSessionRecord>()
        .toList();
  }

  @override
  Future<void> saveRecords(List<FocusSessionRecord> records) {
    return _preferences.setString(
      _recordsKey,
      jsonEncode(records.map(_codec.recordToJson).toList()),
    );
  }

  @override
  Future<void> clearRecords() {
    return _preferences.remove(_recordsKey);
  }
}
