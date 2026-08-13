import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/active_timer_state.dart';
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
    Duration? focusDurationOverride,
    this.startBreakAfterFocus = true,
    this.tickStep = const Duration(seconds: 1),
    this.onFocusSessionCompleted,
    this.onFocusRoundCompleted,
    this.onFocusPeriodCompleted,
    this.onBreakPeriodCompleted,
    this.onFocusRoundFinished,
    DateTime Function()? clock,
  }) : _settings = initialSettings,
       _clock = clock ?? DateTime.now,
       _focusDuration = focusDurationOverride ?? initialSettings.focusDuration,
       _remainingSeconds = initialSettings.mode == FocusMode.stopwatch
           ? 0
           : (focusDurationOverride ?? initialSettings.focusDuration).inSeconds;

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
    autoContinue: true,
  );

  final Duration tickStep;
  final bool startBreakAfterFocus;
  final ValueChanged<FocusSessionRecord>? onFocusSessionCompleted;
  final VoidCallback? onFocusRoundCompleted;
  final VoidCallback? onFocusPeriodCompleted;
  final VoidCallback? onBreakPeriodCompleted;
  final VoidCallback? onFocusRoundFinished;
  final DateTime Function() _clock;

  Timer? _ticker;
  FocusTimerSettings _settings;
  Duration _focusDuration;
  FocusSessionPhase _phase = FocusSessionPhase.idle;
  bool _paused = false;
  int _remainingSeconds;
  int _completedSessions = 0;
  DateTime? _focusStartedAt;
  DateTime? _backgroundStartedAt;

  FocusTimerSettings get settings => _settings;
  FocusSessionPhase get phase => _phase;
  bool get paused => _paused;
  int get remainingSeconds => _remainingSeconds;
  int get completedSessions => _completedSessions;

  bool get active => _phase != FocusSessionPhase.idle;
  bool get running => active && !_paused;
  bool get isStopwatch => _settings.mode == FocusMode.stopwatch;

  ActiveTimerState? get persistentState {
    if (!active) return null;
    return ActiveTimerState(
      phase: _phase,
      paused: _paused,
      completedSessions: _completedSessions,
      remainingSeconds: _remainingSeconds,
      savedAt: _clock(),
      focusStartedAt: _focusStartedAt,
    );
  }

  Duration get elapsedFocusDuration {
    return switch (_phase) {
      FocusSessionPhase.focus => Duration(
        seconds: (_focusDuration.inSeconds - _remainingSeconds).clamp(
          0,
          _focusDuration.inSeconds,
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
    _focusDuration = settings.focusDuration;
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
        onFocusPeriodCompleted?.call();
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

  void restore(ActiveTimerState state) {
    _ticker?.cancel();
    _phase = state.phase;
    _paused = state.paused;
    _completedSessions = state.completedSessions.clamp(
      0,
      _settings.sessionsPerRound,
    );
    _remainingSeconds = state.remainingSeconds;
    _focusStartedAt = state.focusStartedAt;
    _backgroundStartedAt = null;
    if (!_paused) {
      final elapsedSeconds = _clock().difference(state.savedAt).inSeconds;
      if (elapsedSeconds > 0) {
        _elapse(
          elapsedSeconds,
          emitSoundEvents: false,
          recordCompletions: false,
        );
      }
      if (running) _startTicker();
    }
    notifyListeners();
  }

  void suspendForBackground() {
    if (!running || _backgroundStartedAt != null) {
      return;
    }
    _ticker?.cancel();
    _backgroundStartedAt = _clock();
  }

  void resumeFromBackground({bool emitSoundEvents = false}) {
    final backgroundStartedAt = _backgroundStartedAt;
    if (backgroundStartedAt == null) {
      return;
    }
    _backgroundStartedAt = null;
    final elapsedSeconds = _clock().difference(backgroundStartedAt).inSeconds;
    if (elapsedSeconds > 0) {
      _elapse(elapsedSeconds, emitSoundEvents: emitSoundEvents);
    }
    if (running) {
      _startTicker();
    }
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
    _focusStartedAt = _clock();
    if (_completedSessions >= _settings.sessionsPerRound) {
      _completedSessions = 0;
    }
    _remainingSeconds = _focusDuration.inSeconds;
    _startTicker();
    notifyListeners();
  }

  void _startStopwatch() {
    _ticker?.cancel();
    _phase = FocusSessionPhase.stopwatch;
    _paused = false;
    _focusStartedAt = _clock();
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
    _remainingSeconds = _settings
        .breakDuration(isLongBreak: isLongBreak)
        .inSeconds;
    _startTicker();
    notifyListeners();
  }

  void _completeBreak({bool emitSoundEvent = true}) {
    _ticker?.cancel();
    _completedSessions = (_completedSessions + 1).clamp(
      0,
      _settings.sessionsPerRound,
    );

    if (_completedSessions < _settings.sessionsPerRound) {
      _startFocus();
      if (!_settings.autoContinue) {
        _pause();
      }
      if (emitSoundEvent) {
        onBreakPeriodCompleted?.call();
      }
      return;
    }

    _phase = FocusSessionPhase.idle;
    _paused = false;
    _remainingSeconds = _focusDuration.inSeconds;
    notifyListeners();
    onFocusRoundCompleted?.call();
    if (emitSoundEvent) {
      onFocusRoundFinished?.call();
    }
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

    _elapse(1);
  }

  void _elapse(
    int elapsedSeconds, {
    bool emitSoundEvents = true,
    bool recordCompletions = true,
  }) {
    if (_phase == FocusSessionPhase.stopwatch) {
      _remainingSeconds += elapsedSeconds;
      notifyListeners();
      return;
    }

    var remainingElapsedSeconds = elapsedSeconds;
    while (remainingElapsedSeconds > 0 && running) {
      if (remainingElapsedSeconds < _remainingSeconds) {
        _remainingSeconds -= remainingElapsedSeconds;
        notifyListeners();
        return;
      }

      remainingElapsedSeconds -= _remainingSeconds;
      _remainingSeconds = 0;
      if (_phase == FocusSessionPhase.focus) {
        _completeFocus(
          emitSoundEvent: emitSoundEvents,
          recordCompletion: recordCompletions,
        );
      } else if (_phase == FocusSessionPhase.breakTime) {
        _completeBreak(emitSoundEvent: emitSoundEvents);
      }
    }
  }

  void _completeFocus({
    bool emitSoundEvent = true,
    bool recordCompletion = true,
  }) {
    if (recordCompletion) {
      _recordCompletedFocusSession();
    }
    if (!startBreakAfterFocus) {
      _ticker?.cancel();
      _phase = FocusSessionPhase.idle;
      _paused = false;
      _focusStartedAt = null;
      _remainingSeconds = 0;
      notifyListeners();
      if (emitSoundEvent) {
        onFocusPeriodCompleted?.call();
      }
      return;
    }

    _startBreak();
    if (!_settings.autoContinue) {
      _pause();
    }
    if (emitSoundEvent) {
      onFocusPeriodCompleted?.call();
    }
  }

  void _recordCompletedFocusSession() {
    final completedAt = _clock();
    final startedAt = _focusStartedAt ?? completedAt.subtract(_focusDuration);

    onFocusSessionCompleted?.call(
      FocusSessionRecord(
        id: completedAt.microsecondsSinceEpoch.toString(),
        tag: FocusTag(
          name: _settings.focusLabel,
          accentColor: _settings.accentColor,
          badgeIcon: _settings.badgeIcon,
        ),
        mode: FocusMode.pomodoro,
        focusDuration: _focusDuration,
        startedAt: startedAt,
        completedAt: completedAt,
        animationPair: _settings.animationPair,
      ),
    );
  }

  void _recordCompletedStopwatchSession() {
    final completedAt = _clock();
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
    _backgroundStartedAt = null;
    _remainingSeconds = isStopwatch ? 0 : _focusDuration.inSeconds;
  }
}
