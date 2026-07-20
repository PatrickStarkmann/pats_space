import 'dart:convert';

import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/repositories/focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/focus_history_json_codec.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesFocusHistoryRepository
    implements FocusHistoryRepository {
  const SharedPreferencesFocusHistoryRepository(
    this._preferences, {
    required String userId,
  }) : _userId = userId;

  static const _recordsKey = 'focus_history_records_v1';
  static const _codec = FocusHistoryJsonCodec();

  final SharedPreferences _preferences;
  final String _userId;

  String get _scopedRecordsKey => '$_recordsKey:$_userId';

  @override
  Future<List<FocusSessionRecord>> loadRecords() async {
    await migrateLegacyRecordsIfNeeded(_preferences, userId: _userId);
    final rawRecords = _preferences.getString(_scopedRecordsKey);
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
      _scopedRecordsKey,
      jsonEncode(records.map(_codec.recordToJson).toList()),
    );
  }

  @override
  Future<void> clearRecords() {
    return clearRecordsForUser(_preferences, userId: _userId);
  }

  static Future<void> migrateLegacyRecordsIfNeeded(
    SharedPreferences preferences, {
    required String userId,
  }) async {
    final scopedKey = '$_recordsKey:$userId';
    if (preferences.containsKey(scopedKey)) {
      return;
    }

    final legacyRecords = preferences.getString(_recordsKey);
    if (legacyRecords == null) {
      return;
    }

    await preferences.setString(scopedKey, legacyRecords);
    await preferences.remove(_recordsKey);
  }

  static Future<void> clearRecordsForUser(
    SharedPreferences preferences, {
    required String userId,
  }) {
    return preferences.remove('$_recordsKey:$userId');
  }
}
