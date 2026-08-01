import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_session_phase.dart';
import 'package:pats_space/features/focus/models/focus_session_status.dart';
import 'package:pats_space/features/focus/models/focus_tag.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';

class FocusTimerController extends ChangeNotifier {
  FocusTimerController({
    FocusTimerSettings initialSettings = defaultSettings,
    this.tickStep = const Duration(seconds: 1),
    this.onFocusSessionCompleted,
    this.onFocusRoundCompleted,
  }) : _settings = initialSettings,
       _remainingSeconds = initialSettings.mode == FocusMode.stopwatch
           ? 0
           : initialSettings.focusMinutes * 60;

  static const defaultSettings = FocusTimerSettings(
    mode: FocusMode.pomodoro,
    focusMinutes: 5,
    shortBreakMinutes: 5,
    longBreakMinutes: 20,
    longBreakInterval: 4,
    sessionsPerRound: 4,
    focusLabel: 'study',
    accentColor: FocusAccentColor.sunshine,
    badgeIcon: FocusBadgeIcon.character,
    animationPair: FocusAnimationPair.standard,
    deepFocusEnabled: false,
  );

  final Duration tickStep;
  final ValueChanged<FocusSessionRecord>? onFocusSessionCompleted;
  final VoidCallback? onFocusRoundCompleted;

  Timer? _ticker;
  FocusTimerSettings _settings;
  FocusSessionPhase _phase = FocusSessionPhase.idle;
  bool _paused = false;
  int _remainingSeconds;
  int _completedSessions = 0;
  DateTime? _focusStartedAt;

  FocusTimerSettings get settings => _settings;
  FocusSessionPhase get phase => _phase;
  bool get paused => _paused;
  int get remainingSeconds => _remainingSeconds;
  int get completedSessions => _completedSessions;

  bool get active => _phase != FocusSessionPhase.idle;
  bool get running => active && !_paused;
  bool get isStopwatch => _settings.mode == FocusMode.stopwatch;

  Duration get elapsedFocusDuration {
    return switch (_phase) {
      FocusSessionPhase.focus => Duration(
        seconds: (_settings.focusMinutes * 60 - _remainingSeconds).clamp(
          0,
          _settings.focusMinutes * 60,
        ),
      ),
      FocusSessionPhase.stopwatch => Duration(seconds: _remainingSeconds),
      FocusSessionPhase.breakTime || FocusSessionPhase.idle => Duration.zero,
    };
  }

  String get modeLabel {
    return switch (_phase) {
      FocusSessionPhase.breakTime => 'break',
      FocusSessionPhase.stopwatch => 'stopwatch',
      _ => isStopwatch ? 'stopwatch' : 'study',
    };
  }

  List<FocusSessionStatus> get sessionStatuses {
    return List.generate(_settings.sessionsPerRound, (index) {
      if (index < _completedSessions) {
        return FocusSessionStatus.complete;
      }

      if (active &&
          _phase != FocusSessionPhase.stopwatch &&
          index == _completedSessions) {
        return FocusSessionStatus.active;
      }

      return FocusSessionStatus.empty;
    });
  }

  void updateSettings(FocusTimerSettings settings) {
    _settings = settings;
    _resetToIdleWithoutNotify();
    notifyListeners();
  }

  void restartCurrentSession() {
    switch (_phase) {
      case FocusSessionPhase.focus:
        _startFocus();
      case FocusSessionPhase.breakTime:
        _startBreak();
      case FocusSessionPhase.stopwatch:
        _startStopwatch();
      case FocusSessionPhase.idle:
        _startSelectedMode();
    }
  }

  void cancelFocusRound() {
    _completedSessions = 0;
    resetToIdle();
  }

  void finishStopwatch() {
    if (_phase != FocusSessionPhase.stopwatch) {
      return;
    }

    _ticker?.cancel();
    if (_remainingSeconds > 0) {
      _recordCompletedStopwatchSession();
    }
    _resetToIdleWithoutNotify();
    notifyListeners();
  }

  void toggle() {
    if (running) {
      _pause();
      return;
    }

    if (_paused && active) {
      _resume();
      return;
    }

    _startSelectedMode();
  }

  void skip() {
    switch (_phase) {
      case FocusSessionPhase.focus:
        _startBreak();
      case FocusSessionPhase.breakTime:
        _completeBreak();
      case FocusSessionPhase.stopwatch:
      case FocusSessionPhase.idle:
        resetToIdle();
    }
  }

  void resetToIdle() {
    _resetToIdleWithoutNotify();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startSelectedMode() {
    if (isStopwatch) {
      _startStopwatch();
      return;
    }

    _startFocus();
  }

  void _startFocus() {
    _ticker?.cancel();
    _phase = FocusSessionPhase.focus;
    _paused = false;
    _focusStartedAt = DateTime.now();
    if (_completedSessions >= _settings.sessionsPerRound) {
      _completedSessions = 0;
    }
    _remainingSeconds = _settings.focusMinutes * 60;
    _startTicker();
    notifyListeners();
  }

  void _startStopwatch() {
    _ticker?.cancel();
    _phase = FocusSessionPhase.stopwatch;
    _paused = false;
    _focusStartedAt = DateTime.now();
    _remainingSeconds = 0;
    _startTicker();
    notifyListeners();
  }

  void _pause() {
    _ticker?.cancel();
    _paused = true;
    notifyListeners();
  }

  void _resume() {
    _paused = false;
    _startTicker();
    notifyListeners();
  }

  void _startBreak() {
    _ticker?.cancel();
    _focusStartedAt = null;
    final isLongBreak =
        (_completedSessions + 1) % _settings.longBreakInterval == 0;
    _phase = FocusSessionPhase.breakTime;
    _paused = false;
    _remainingSeconds =
        (isLongBreak
            ? _settings.longBreakMinutes
            : _settings.shortBreakMinutes) *
        60;
    _startTicker();
    notifyListeners();
  }

  void _completeBreak() {
    _ticker?.cancel();
    _completedSessions = (_completedSessions + 1).clamp(
      0,
      _settings.sessionsPerRound,
    );

    if (_completedSessions < _settings.sessionsPerRound) {
      _startFocus();
      return;
    }

    _phase = FocusSessionPhase.idle;
    _paused = false;
    _remainingSeconds = _settings.focusMinutes * 60;
    notifyListeners();
    onFocusRoundCompleted?.call();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(tickStep, (_) => _handleTick());
  }

  void _handleTick() {
    if (_phase == FocusSessionPhase.stopwatch) {
      _remainingSeconds += 1;
      notifyListeners();
      return;
    }

    if (_remainingSeconds <= 1) {
      if (_phase == FocusSessionPhase.focus) {
        _completeFocus();
      } else if (_phase == FocusSessionPhase.breakTime) {
        _completeBreak();
      }
      return;
    }

    _remainingSeconds -= 1;
    notifyListeners();
  }

  void _completeFocus() {
    _recordCompletedFocusSession();
    _startBreak();
  }

  void _recordCompletedFocusSession() {
    final completedAt = DateTime.now();
    final startedAt =
        _focusStartedAt ??
        completedAt.subtract(Duration(minutes: _settings.focusMinutes));

    onFocusSessionCompleted?.call(
      FocusSessionRecord(
        id: completedAt.microsecondsSinceEpoch.toString(),
        tag: FocusTag(
          name: _settings.focusLabel,
          accentColor: _settings.accentColor,
          badgeIcon: _settings.badgeIcon,
        ),
        mode: FocusMode.pomodoro,
        focusDuration: Duration(minutes: _settings.focusMinutes),
        startedAt: startedAt,
        completedAt: completedAt,
        animationPair: _settings.animationPair,
      ),
    );
  }

  void _recordCompletedStopwatchSession() {
    final completedAt = DateTime.now();
    final duration = Duration(seconds: _remainingSeconds);
    final startedAt = _focusStartedAt ?? completedAt.subtract(duration);

    onFocusSessionCompleted?.call(
      FocusSessionRecord(
        id: completedAt.microsecondsSinceEpoch.toString(),
        tag: FocusTag(
          name: _settings.focusLabel,
          accentColor: _settings.accentColor,
          badgeIcon: _settings.badgeIcon,
        ),
        mode: FocusMode.stopwatch,
        focusDuration: duration,
        startedAt: startedAt,
        completedAt: completedAt,
        animationPair: _settings.animationPair,
      ),
    );
  }

  void _resetToIdleWithoutNotify() {
    _ticker?.cancel();
    _phase = FocusSessionPhase.idle;
    _paused = false;
    _focusStartedAt = null;
    _remainingSeconds = isStopwatch ? 0 : _settings.focusMinutes * 60;
  }
}
