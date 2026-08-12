import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';

class FocusTimerSettings {
  const FocusTimerSettings({
    required this.mode,
    required this.focusMinutes,
    this.focusSeconds,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.longBreakInterval,
    required this.sessionsPerRound,
    required this.focusLabel,
    required this.accentColor,
    required this.badgeIcon,
    required this.animationPair,
    required this.deepFocusEnabled,
  });

  final FocusMode mode;
  final int focusMinutes;

  /// Optional short focus duration used for quick timer checks.
  ///
  /// Normal sessions continue to use [focusMinutes].
  final int? focusSeconds;

  Duration get focusDuration => focusSeconds == null
      ? Duration(minutes: focusMinutes)
      : Duration(seconds: focusSeconds!);

  Duration breakDuration({required bool isLongBreak}) {
    if (focusSeconds != null) {
      return Duration(seconds: focusSeconds!);
    }
    return Duration(
      minutes: isLongBreak ? longBreakMinutes : shortBreakMinutes,
    );
  }

  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakInterval;
  final int sessionsPerRound;
  final String focusLabel;
  final FocusAccentColor accentColor;
  final FocusBadgeIcon badgeIcon;
  final FocusAnimationPair animationPair;
  final bool deepFocusEnabled;

  FocusTimerSettings copyWith({
    FocusMode? mode,
    int? focusMinutes,
    int? focusSeconds,
    bool clearFocusSeconds = false,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakInterval,
    int? sessionsPerRound,
    String? focusLabel,
    FocusAccentColor? accentColor,
    FocusBadgeIcon? badgeIcon,
    FocusAnimationPair? animationPair,
    bool? deepFocusEnabled,
  }) {
    return FocusTimerSettings(
      mode: mode ?? this.mode,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      focusSeconds: clearFocusSeconds
          ? null
          : focusSeconds ?? this.focusSeconds,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      sessionsPerRound: sessionsPerRound ?? this.sessionsPerRound,
      focusLabel: focusLabel ?? this.focusLabel,
      accentColor: accentColor ?? this.accentColor,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      animationPair: animationPair ?? this.animationPair,
      deepFocusEnabled: deepFocusEnabled ?? this.deepFocusEnabled,
    );
  }
}
