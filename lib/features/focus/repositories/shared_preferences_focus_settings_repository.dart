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
  const SharedPreferencesFocusSettingsRepository(
    this._preferences, {
    required this.userId,
  });

  static const _keyPrefix = 'focus_settings.v2';

  final SharedPreferences _preferences;
  final String userId;

  String get _settingsKey => _keyFor(userId);

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
      focusMinutes: _intValue(json['focusMinutes']) ?? 25,
      // `focusSeconds` was only used by the temporary 30-second test mode.
      // Ignore the legacy value so an old test setting cannot survive updates.
      focusSeconds: null,
      shortBreakMinutes: _intValue(json['shortBreakMinutes']) ?? 5,
      longBreakMinutes: _intValue(json['longBreakMinutes']) ?? 20,
      longBreakInterval: _intValue(json['longBreakInterval']) ?? 4,
      sessionsPerRound: _intValue(json['sessionsPerRound']) ?? 4,
      focusLabel: _focusLabelValue(json['focusLabel']),
      accentColor:
          _enumValue(FocusAccentColor.values, json['accentColor']) ??
          FocusAccentColor.sage,
      badgeIcon: _badgeIconValue(json['badgeIcon']),
      animationPair:
          _enumValue(FocusAnimationPair.values, json['animationPair']) ??
          FocusAnimationPair.standard,
      deepFocusEnabled: json['deepFocusEnabled'] as bool? ?? false,
      autoContinue: json['autoContinue'] as bool? ?? true,
    );
  }

  @override
  Future<void> saveSettings(FocusTimerSettings settings) {
    return _preferences.setString(
      _settingsKey,
      jsonEncode({
        'mode': settings.mode.name,
        'focusMinutes': settings.focusMinutes,
        'focusSeconds': settings.focusSeconds,
        'shortBreakMinutes': settings.shortBreakMinutes,
        'longBreakMinutes': settings.longBreakMinutes,
        'longBreakInterval': settings.longBreakInterval,
        'sessionsPerRound': settings.sessionsPerRound,
        'focusLabel': settings.focusLabel,
        'accentColor': settings.accentColor.name,
        'badgeIcon': settings.badgeIcon.name,
        'animationPair': settings.animationPair.name,
        'deepFocusEnabled': settings.deepFocusEnabled,
        'autoContinue': settings.autoContinue,
      }),
    );
  }

  static Future<void> clearSettingsForUser(
    SharedPreferences preferences, {
    required String userId,
  }) {
    return preferences.remove(_keyFor(userId));
  }

  static String _keyFor(String userId) => '$_keyPrefix.$userId';

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

  String _focusLabelValue(Object? value) {
    if (value is! String) {
      return 'study';
    }

    final label = value.trim();
    if (label.isEmpty || label.toLowerCase() == 'pomodoro') {
      return 'study';
    }

    return label;
  }

  FocusBadgeIcon _badgeIconValue(Object? value) {
    if (value is! String || value.isEmpty) {
      return FocusBadgeIcon.character;
    }

    return _enumValue(FocusBadgeIcon.values, value) ?? FocusBadgeIcon.character;
  }
}
