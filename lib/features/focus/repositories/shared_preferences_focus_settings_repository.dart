import 'dart:convert';

import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/focus/repositories/focus_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesFocusSettingsRepository
    implements FocusSettingsRepository {
  const SharedPreferencesFocusSettingsRepository(this._preferences);

  static const _settingsKey = 'focus_settings_v1';

  final SharedPreferences _preferences;

  @override
  Future<FocusTimerSettings?> loadSettings() async {
    final rawSettings = _preferences.getString(_settingsKey);
    if (rawSettings == null) {
      return null;
    }

    final json = jsonDecode(rawSettings);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    return FocusTimerSettings(
      mode: _enumValue(FocusMode.values, json['mode']) ?? FocusMode.pomodoro,
      focusMinutes: _intValue(json['focusMinutes']) ?? 5,
      shortBreakMinutes: _intValue(json['shortBreakMinutes']) ?? 5,
      longBreakMinutes: _intValue(json['longBreakMinutes']) ?? 20,
      longBreakInterval: _intValue(json['longBreakInterval']) ?? 4,
      sessionsPerRound: _intValue(json['sessionsPerRound']) ?? 4,
      focusLabel: json['focusLabel'] as String? ?? 'pomodoro',
      accentColor:
          _enumValue(FocusAccentColor.values, json['accentColor']) ??
          FocusAccentColor.sunshine,
      badgeIcon:
          _enumValue(FocusBadgeIcon.values, json['badgeIcon']) ??
          FocusBadgeIcon.cat,
      animationPair:
          _enumValue(FocusAnimationPair.values, json['animationPair']) ??
          FocusAnimationPair.standard,
    );
  }

  @override
  Future<void> saveSettings(FocusTimerSettings settings) {
    return _preferences.setString(
      _settingsKey,
      jsonEncode({
        'mode': settings.mode.name,
        'focusMinutes': settings.focusMinutes,
        'shortBreakMinutes': settings.shortBreakMinutes,
        'longBreakMinutes': settings.longBreakMinutes,
        'longBreakInterval': settings.longBreakInterval,
        'sessionsPerRound': settings.sessionsPerRound,
        'focusLabel': settings.focusLabel,
        'accentColor': settings.accentColor.name,
        'badgeIcon': settings.badgeIcon.name,
        'animationPair': settings.animationPair.name,
      }),
    );
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
