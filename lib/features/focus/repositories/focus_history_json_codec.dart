import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_tag.dart';

class FocusHistoryJsonCodec {
  const FocusHistoryJsonCodec();

  FocusSessionRecord? recordFromJson(Map<String, dynamic> json) {
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
        name: tagJson['name'] as String? ?? 'study',
        accentColor:
            _enumValue(FocusAccentColor.values, tagJson['accentColor']) ??
            FocusAccentColor.sunshine,
        badgeIcon: _badgeIconValue(tagJson['badgeIcon']),
      ),
      mode: _enumValue(FocusMode.values, json['mode']) ?? FocusMode.pomodoro,
      focusDuration: Duration(seconds: focusDurationSeconds),
      startedAt: startedAt,
      completedAt: completedAt,
      animationPair:
          _enumValue(FocusAnimationPair.values, json['animationPair']) ??
          FocusAnimationPair.standard,
      waterReward: _intValue(json['waterReward']) ?? 0,
    );
  }

  Map<String, Object?> recordToJson(FocusSessionRecord record) {
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
      'waterReward': record.waterReward,
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

  FocusBadgeIcon _badgeIconValue(Object? value) {
    if (value is! String || value.isEmpty) {
      return FocusBadgeIcon.character;
    }

    return _enumValue(FocusBadgeIcon.values, value) ?? FocusBadgeIcon.character;
  }
}
