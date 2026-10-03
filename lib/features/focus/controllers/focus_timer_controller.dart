import 'dart:async';
import 'dart:math';

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
    this.onFocusTimeEnded,
    this.onFocusRoundCompleted,
    this.onFocusPeriodCompleted,
    this.onBreakPeriodCompleted,
    this.onFocusRoundFinished,
    bool Function(FocusAnimationPair pair)? isAnimationPairAvailable,
    DateTime Function()? clock,
  }) : _settings = initialSettings,
       _isAnimationPairAvailable = isAnimationPairAvailable ?? ((_) => true),
       _clock = clock ?? DateTime.now,
       _focusDuration = focusDurationOverride ?? initialSettings.focusDuration,
       _remainingSeconds = initialSettings.mode == FocusMode.stopwatch
           ? 0
           : (focusDurationOverride ?? initialSettings.focusDuration)
                 .inSeconds {
    _prepareShufflePreview();
  }

  static const defaultSettings = FocusTimerSettings(
    mode: FocusMode.pomodoro,
    focusMinutes: 25,
    shortBreakMinutes: 5,
    longBreakMinutes: 20,
    longBreakInterval: 4,
    sessionsPerRound: 4,
    focusLabel: 'study',
    accentColor: FocusAccentColor.sage,
    badgeIcon: FocusBadgeIcon.character,
    animationPair: FocusAnimationPair.standard,
    deepFocusEnabled: false,
    autoContinue: true,
  );

  final Duration tickStep;
  final bool startBreakAfterFocus;
  final ValueChanged<FocusSessionRecord>? onFocusSessionCompleted;
  final ValueChanged<Duration>? onFocusTimeEnded;
  final VoidCallback? onFocusRoundCompleted;
  final VoidCallback? onFocusPeriodCompleted;
  final VoidCallback? onBreakPeriodCompleted;
  final VoidCallback? onFocusRoundFinished;
  final DateTime Function() _clock;
  final bool Function(FocusAnimationPair pair) _isAnimationPairAvailable;

  Timer? _ticker;
  FocusTimerSettings _settings;
  Duration _focusDuration;
  FocusSessionPhase _phase = FocusSessionPhase.idle;
  bool _paused = false;
  int _remainingSeconds;
  int _completedSessions = 0;
  DateTime? _focusStartedAt;
  DateTime? _backgroundStartedAt;
  DateTime? _lastTickerTickAt;
  DateTime? _phaseDeadline;
  FocusAnimationPair? _activeAnimationPair;
  FocusAnimationPair? _lastShuffledAnimationPair;

  FocusTimerSettings get settings => _settings;
  FocusSessionPhase get phase => _phase;
  bool get paused => _paused;
  int get remainingSeconds {
    final deadline = _phaseDeadline;
    if (!running || deadline == null || _phase == FocusSessionPhase.stopwatch) {
      return _remainingSeconds;
    }
    final remaining = deadline.difference(_clock());
    if (remaining <= Duration.zero) return 0;
    return (remaining.inMilliseconds + 999) ~/ Duration.millisecondsPerSecond;
  }

  int get completedSessions => _completedSessions;
  FocusAnimationPair get activeAnimationPair =>
      _activeAnimationPair ??
      (_settings.animationPair == FocusAnimationPair.shuffle
          ? FocusAnimationPair.standard
          : _settings.animationPair);

  bool get active => _phase != FocusSessionPhase.idle;
  bool get running => active && !_paused;
  bool get isStopwatch => _settings.mode == FocusMode.stopwatch;

  int get currentPhaseTotalSeconds {
    return switch (_phase) {
      FocusSessionPhase.focus => _focusDuration.inSeconds,
      FocusSessionPhase.breakTime =>
        _settings
            .breakDuration(
              isLongBreak:
                  (_completedSessions + 1) %
                      (_settings.longBreakInterval <= 0
                          ? 1
                          : _settings.longBreakInterval) ==
                  0,
            )
            .inSeconds,
      FocusSessionPhase.stopwatch || FocusSessionPhase.idle => 0,
    };
  }

  ActiveTimerState? get persistentState {
    if (!active) return null;
    return ActiveTimerState(
      phase: _phase,
      paused: _paused,
      completedSessions: _completedSessions,
      remainingSeconds: remainingSeconds,
      savedAt: _clock(),
      focusStartedAt: _focusStartedAt,
      animationPair: _activeAnimationPair,
    );
  }

  Duration get elapsedFocusDuration {
    return switch (_phase) {
      FocusSessionPhase.focus => Duration(
        seconds: (_focusDuration.inSeconds - remainingSeconds).clamp(
          0,
          _focusDuration.inSeconds,
        ),
      ),
      FocusSessionPhase.stopwatch => Duration(seconds: remainingSeconds),
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
    _reportUnfinishedFocusTime();
    _settings = _settingsWithAvailableAnimation(settings);
    _focusDuration = _settings.focusDuration;
    _resetToIdleWithoutNotify();
    notifyListeners();
  }

  void restartCurrentSession() {
    _reportUnfinishedFocusTime();
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

  /// Returns the currently running focus period as a partial record.
  ///
  /// Call this before cancelling a round when elapsed focus time should still
  /// count towards a user's history.
  FocusSessionRecord? get partialFocusRecord {
    final mode = switch (_phase) {
      FocusSessionPhase.focus => FocusMode.pomodoro,
      FocusSessionPhase.stopwatch => FocusMode.stopwatch,
      FocusSessionPhase.idle || FocusSessionPhase.breakTime => null,
    };
    if (mode == null) {
      return null;
    }

    final duration = elapsedFocusDuration;
    if (duration <= Duration.zero) {
      return null;
    }

    final completedAt = _clock();
    final startedAt = _focusStartedAt ?? completedAt.subtract(duration);
    return FocusSessionRecord(
      id: completedAt.microsecondsSinceEpoch.toString(),
      tag: FocusTag(
        name: _settings.focusLabel,
        accentColor: _settings.accentColor,
        badgeIcon: _settings.badgeIcon,
      ),
      mode: mode,
      focusDuration: duration,
      startedAt: startedAt,
      completedAt: completedAt,
      animationPair: activeAnimationPair,
    );
  }

  void cancelFocusRound({bool reportUnfinishedFocusTime = true}) {
    _completedSessions = 0;
    resetToIdle(reportUnfinishedFocusTime: reportUnfinishedFocusTime);
  }

  void acknowledgeRoundCompletion() {
    if (active || _completedSessions < _settings.sessionsPerRound) {
      return;
    }
    _completedSessions = 0;
    notifyListeners();
  }

  void finishStopwatch() {
    if (_phase != FocusSessionPhase.stopwatch) {
      return;
    }

    _ticker?.cancel();
    if (_remainingSeconds > 0) {
      onFocusTimeEnded?.call(Duration(seconds: _remainingSeconds));
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
        _reportUnfinishedFocusTime();
        _startBreak();
        onFocusPeriodCompleted?.call();
      case FocusSessionPhase.breakTime:
        _completeBreak();
      case FocusSessionPhase.stopwatch:
      case FocusSessionPhase.idle:
        resetToIdle();
    }
  }

  void resetToIdle({bool reportUnfinishedFocusTime = true}) {
    if (reportUnfinishedFocusTime) {
      _reportUnfinishedFocusTime();
    }
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
    final savedPair = state.animationPair ?? _settings.animationPair;
    final restoredPair = _isAnimationPairAvailable(savedPair)
        ? savedPair
        : FocusAnimationPair.standard;
    _activeAnimationPair = restoredPair != FocusAnimationPair.shuffle
        ? restoredPair
        : (_settings.animationPair == FocusAnimationPair.shuffle
              ? FocusAnimationPair.standard
              : _settings.animationPair);
    _backgroundStartedAt = null;
    _phaseDeadline = null;
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
    _lastTickerTickAt = null;
    _backgroundStartedAt = _clock();
  }

  void resumeFromBackground({bool emitSoundEvents = false}) {
    final backgroundStartedAt = _backgroundStartedAt;
    final lastTickerTickAt = _lastTickerTickAt;
    if (backgroundStartedAt == null && lastTickerTickAt == null) {
      return;
    }

    final checkpoint = backgroundStartedAt ?? lastTickerTickAt!;
    final elapsedSeconds = _clock().difference(checkpoint).inSeconds;

    // A repeated foreground callback has nothing to reconcile. More
    // importantly, avoid restarting an already healthy foreground ticker.
    if (backgroundStartedAt == null && elapsedSeconds <= 0) {
      return;
    }

    _backgroundStartedAt = null;
    _ticker?.cancel();
    _lastTickerTickAt = null;
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
    _activeAnimationPair ??= _selectAnimationPair();
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
    _activeAnimationPair ??= _selectAnimationPair();
    _remainingSeconds = 0;
    _startTicker();
    notifyListeners();
  }

  void _pause() {
    _remainingSeconds = remainingSeconds;
    _ticker?.cancel();
    _lastTickerTickAt = null;
    _phaseDeadline = null;
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
    _lastTickerTickAt = null;
    _phaseDeadline = null;
    _completedSessions = (_completedSessions + 1).clamp(
      0,
      _settings.sessionsPerRound,
    );

    if (_completedSessions < _settings.sessionsPerRound) {
      _activeAnimationPair = null;
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
    _phaseDeadline = null;
    _activeAnimationPair = null;
    _prepareShufflePreview();
    _remainingSeconds = _focusDuration.inSeconds;
    notifyListeners();
    onFocusRoundCompleted?.call();
    if (emitSoundEvent) {
      onFocusRoundFinished?.call();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _lastTickerTickAt = _clock();
    if (_phase == FocusSessionPhase.focus ||
        _phase == FocusSessionPhase.breakTime) {
      _phaseDeadline = _clock().add(Duration(seconds: _remainingSeconds));
    }
    _ticker = Timer.periodic(tickStep, (_) => _handleTick());
  }

  void _handleTick() {
    final now = _clock();
    final previousTickAt = _lastTickerTickAt ?? now;
    final minimumElapsedSeconds = max(1, tickStep.inSeconds);
    final elapsedSeconds = now
        .difference(previousTickAt)
        .inSeconds
        .clamp(minimumElapsedSeconds, 1 << 30)
        .toInt();

    // Keep the sub-second remainder, so delayed Dart callbacks cannot make
    // the in-app timer lag behind the wall-clock based home-screen widget.
    _lastTickerTickAt = previousTickAt.add(Duration(seconds: elapsedSeconds));
    _elapse(elapsedSeconds);
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
    onFocusTimeEnded?.call(_focusDuration);
    if (recordCompletion) {
      _recordCompletedFocusSession();
    }
    if (!startBreakAfterFocus) {
      _ticker?.cancel();
      _phaseDeadline = null;
      _phase = FocusSessionPhase.idle;
      _paused = false;
      _focusStartedAt = null;
      _activeAnimationPair = null;
      _prepareShufflePreview();
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
        animationPair: activeAnimationPair,
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
        animationPair: activeAnimationPair,
      ),
    );
  }

  void _resetToIdleWithoutNotify() {
    _ticker?.cancel();
    _lastTickerTickAt = null;
    _phaseDeadline = null;
    _phase = FocusSessionPhase.idle;
    _paused = false;
    _focusStartedAt = null;
    _backgroundStartedAt = null;
    _activeAnimationPair = null;
    _prepareShufflePreview();
    _remainingSeconds = isStopwatch ? 0 : _focusDuration.inSeconds;
  }

  void _reportUnfinishedFocusTime() {
    final duration = elapsedFocusDuration;
    if (duration > Duration.zero) {
      onFocusTimeEnded?.call(duration);
    }
  }

  FocusAnimationPair _selectAnimationPair() {
    if (_settings.animationPair != FocusAnimationPair.shuffle) {
      return _settings.animationPair;
    }

    final candidates = FocusAnimationPair.values
        .where((pair) => pair != FocusAnimationPair.shuffle)
        .where(_isAnimationPairAvailable)
        .where((pair) => pair != _lastShuffledAnimationPair)
        .toList();
    if (candidates.isEmpty) {
      return FocusAnimationPair.standard;
    }
    final selected = candidates[Random().nextInt(candidates.length)];
    _lastShuffledAnimationPair = selected;
    return selected;
  }

  FocusTimerSettings _settingsWithAvailableAnimation(
    FocusTimerSettings settings,
  ) {
    if (settings.animationPair == FocusAnimationPair.shuffle ||
        _isAnimationPairAvailable(settings.animationPair)) {
      return settings;
    }
    return settings.copyWith(animationPair: FocusAnimationPair.standard);
  }

  void _prepareShufflePreview() {
    if (_settings.animationPair == FocusAnimationPair.shuffle) {
      _activeAnimationPair = _selectAnimationPair();
    }
  }
}
