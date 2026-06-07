import 'dart:convert';

import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_tag.dart';
import 'package:pats_space/features/focus/repositories/focus_history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesFocusHistoryRepository
    implements FocusHistoryRepository {
  const SharedPreferencesFocusHistoryRepository(this._preferences);

  static const _recordsKey = 'focus_history_records_v1';

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
        .map(_recordFromJson)
        .whereType<FocusSessionRecord>()
        .toList();
  }

  @override
  Future<void> saveRecords(List<FocusSessionRecord> records) {
    return _preferences.setString(
      _recordsKey,
      jsonEncode(records.map(_recordToJson).toList()),
    );
  }

  @override
  Future<void> clearRecords() {
    return _preferences.remove(_recordsKey);
  }

  FocusSessionRecord? _recordFromJson(Map<String, dynamic> json) {
    final tagJson = json['tag'];
    final startedAt = DateTime.tryParse(json['startedAt'] as String? ?? '');
    final completedAt = DateTime.tryParse(json['completedAt'] as String? ?? '');
    final focusDurationSeconds = _intValue(json['focusDurationSeconds']);

    if (tagJson is! Map<String, dynamic> ||
        startedAt == null ||
        completedAt == null ||
        focusDurationSeconds == null) {
      return null;
    }

    return FocusSessionRecord(
      id:
          json['id'] as String? ??
          completedAt.microsecondsSinceEpoch.toString(),
      tag: FocusTag(
        name: tagJson['name'] as String? ?? 'pomodoro',
        accentColor:
            _enumValue(FocusAccentColor.values, tagJson['accentColor']) ??
            FocusAccentColor.sunshine,
        badgeIcon:
            _enumValue(FocusBadgeIcon.values, tagJson['badgeIcon']) ??
            FocusBadgeIcon.cat,
      ),
      mode: _enumValue(FocusMode.values, json['mode']) ?? FocusMode.pomodoro,
      focusDuration: Duration(seconds: focusDurationSeconds),
      startedAt: startedAt,
      completedAt: completedAt,
      animationPair:
          _enumValue(FocusAnimationPair.values, json['animationPair']) ??
          FocusAnimationPair.standard,
    );
  }

  Map<String, Object?> _recordToJson(FocusSessionRecord record) {
    return {
      'id': record.id,
      'tag': {
        'name': record.tag.name,
        'accentColor': record.tag.accentColor.name,
        'badgeIcon': record.tag.badgeIcon.name,
      },
      'mode': record.mode.name,
      'focusDurationSeconds': record.focusDuration.inSeconds,
      'startedAt': record.startedAt.toIso8601String(),
      'completedAt': record.completedAt.toIso8601String(),
      'animationPair': record.animationPair.name,
    };
  }

  T? _enumValue<T extends Enum>(List<T> values, Object? name) {
    if (name is! String) {
      return null;
    }

    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }

  int? _intValue(Object? value) {
    return switch (value) {
      int() => value,
      num() => value.toInt(),
      _ => null,
    };
  }
}
