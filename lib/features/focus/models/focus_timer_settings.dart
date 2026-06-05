import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';

class FocusTimerSettings {
  const FocusTimerSettings({
    required this.mode,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.longBreakInterval,
    required this.sessionsPerRound,
    required this.accentColor,
    required this.badgeIcon,
    required this.animationPair,
  });

  final FocusMode mode;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakInterval;
  final int sessionsPerRound;
  final FocusAccentColor accentColor;
  final FocusBadgeIcon badgeIcon;
  final FocusAnimationPair animationPair;

  FocusTimerSettings copyWith({
    FocusMode? mode,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakInterval,
    int? sessionsPerRound,
    FocusAccentColor? accentColor,
    FocusBadgeIcon? badgeIcon,
    FocusAnimationPair? animationPair,
  }) {
    return FocusTimerSettings(
      mode: mode ?? this.mode,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      sessionsPerRound: sessionsPerRound ?? this.sessionsPerRound,
      accentColor: accentColor ?? this.accentColor,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      animationPair: animationPair ?? this.animationPair,
    );
  }
}
