import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/widgets/app_icon_button.dart';
import 'package:pats_space/features/home/widgets/focus_mode_label.dart';
import 'package:pats_space/features/home/widgets/focus_session_dots.dart';
import 'package:pats_space/features/home/widgets/focus_timer_preview.dart';
import 'package:pats_space/features/home/widgets/patsspace_character_view.dart';
import 'package:pats_space/features/home/widgets/time_settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _sessionsPerRound = 4;
  static const _animationStep = Duration(milliseconds: 1100);
  static const _tickerStep = Duration(seconds: 1);

  TimeSettings _settings = const TimeSettings(
    mode: FocusMode.pomodoro,
    focusMinutes: 5,
    shortBreakMinutes: 5,
    longBreakMinutes: 20,
    longBreakInterval: 4,
  );
  Timer? _ticker;
  Timer? _animationTicker;
  _FocusPhase _phase = _FocusPhase.idle;
  int _remainingSeconds = 5 * 60;
  int _completedSessions = 0;
  int _animationFrame = 0;

  bool get _running =>
      _phase == _FocusPhase.focus || _phase == _FocusPhase.breakTime;

  bool get _inBreak => _phase == _FocusPhase.breakTime;

  bool get _isStopwatch => _settings.mode == FocusMode.stopwatch;

  @override
  void dispose() {
    _ticker?.cancel();
    _animationTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 680;
        final topSpace = compact ? AppSpacing.xl : AppSpacing.xxl * 2.25;
        final characterGap = compact ? AppSpacing.lg : AppSpacing.xxl * 1.25;

        return Column(
          children: [
            SizedBox(height: topSpace),
            FocusModeLabel(label: _modeLabel, onPressed: _openSettings),
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
            FocusTimerPreview(
              timeLabel: _formatTime(_remainingSeconds),
              onPressed: _openSettings,
            ),
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            FocusSessionDots(states: _dotStates),
            SizedBox(height: characterGap),
            PatsspaceCharacterView(
              compact: compact,
              assetPath: _currentCharacterAsset,
            ),
            SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xxl),
            _FocusControls(
              running: _running,
              onSkip: _skipPhase,
              onPlayPause: _toggleTimer,
            ),
            const Spacer(),
          ],
        );
      },
    );
  }

  String get _modeLabel {
    return switch (_phase) {
      _FocusPhase.breakTime => 'break',
      _ => _isStopwatch ? 'stopwatch' : 'pomodoro',
    };
  }

  String get _currentCharacterAsset {
    final frames = _inBreak
        ? AppAssets.focusPair01Break
        : AppAssets.focusPair01Focus;
    return frames[_animationFrame % frames.length];
  }

  List<FocusSessionDotState> get _dotStates {
    return List.generate(_sessionsPerRound, (index) {
      if (index < _completedSessions) {
        return FocusSessionDotState.complete;
      }

      if (_running && index == _completedSessions) {
        return FocusSessionDotState.active;
      }

      return FocusSessionDotState.empty;
    });
  }

  Future<void> _openSettings() async {
    final updated = await showTimeSettingsSheet(
      context: context,
      settings: _settings,
    );

    if (updated == null || !mounted) {
      return;
    }

    setState(() {
      _settings = updated;
      if (_phase == _FocusPhase.idle) {
        _remainingSeconds = _isStopwatch ? 0 : _settings.focusMinutes * 60;
      }
    });
  }

  void _toggleTimer() {
    if (_running) {
      _pauseTimer();
      return;
    }

    _startFocus();
  }

  void _startFocus() {
    setState(() {
      _phase = _FocusPhase.focus;
      if (!_isStopwatch && _completedSessions >= _sessionsPerRound) {
        _completedSessions = 0;
      }
      if (_isStopwatch) {
        _remainingSeconds = 0;
      } else if (_remainingSeconds <= 0) {
        _remainingSeconds = _settings.focusMinutes * 60;
      }
    });
    _startTickers();
  }

  void _pauseTimer() {
    _ticker?.cancel();
    _animationTicker?.cancel();
    setState(() => _phase = _FocusPhase.paused);
  }

  void _startBreak() {
    if (_isStopwatch) {
      _resetToIdle();
      return;
    }

    final isLongBreak =
        (_completedSessions + 1) % _settings.longBreakInterval == 0;
    setState(() {
      _phase = _FocusPhase.breakTime;
      _remainingSeconds =
          (isLongBreak
              ? _settings.longBreakMinutes
              : _settings.shortBreakMinutes) *
          60;
    });
    _startTickers();
  }

  void _completeBreak() {
    _ticker?.cancel();
    _animationTicker?.cancel();
    setState(() {
      _phase = _FocusPhase.idle;
      _completedSessions = (_completedSessions + 1).clamp(0, _sessionsPerRound);
      _remainingSeconds = _settings.focusMinutes * 60;
      _animationFrame = 0;
    });
  }

  void _skipPhase() {
    if (_phase == _FocusPhase.focus) {
      _ticker?.cancel();
      _animationTicker?.cancel();
      _startBreak();
      return;
    }

    if (_phase == _FocusPhase.breakTime) {
      _completeBreak();
      return;
    }

    _resetToIdle();
  }

  void _startTickers() {
    _ticker?.cancel();
    _animationTicker?.cancel();

    _ticker = Timer.periodic(_tickerStep, (_) {
      if (!mounted) {
        return;
      }

      if (_isStopwatch && _phase == _FocusPhase.focus) {
        setState(() => _remainingSeconds += 1);
        return;
      }

      if (_remainingSeconds <= 1) {
        if (_phase == _FocusPhase.focus) {
          _ticker?.cancel();
          _animationTicker?.cancel();
          _startBreak();
        } else if (_phase == _FocusPhase.breakTime) {
          _completeBreak();
        }
        return;
      }

      setState(() => _remainingSeconds -= 1);
    });

    _animationTicker = Timer.periodic(_animationStep, (_) {
      if (mounted) {
        setState(() => _animationFrame += 1);
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _resetToIdle() {
    _ticker?.cancel();
    _animationTicker?.cancel();
    setState(() {
      _phase = _FocusPhase.idle;
      _remainingSeconds = _isStopwatch ? 0 : _settings.focusMinutes * 60;
      _animationFrame = 0;
    });
  }
}

class _FocusControls extends StatelessWidget {
  const _FocusControls({
    required this.running,
    required this.onSkip,
    required this.onPlayPause,
  });

  final bool running;
  final VoidCallback onSkip;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIconButton(
          icon: CupertinoIcons.forward_end,
          semanticLabel: 'Skip',
          onPressed: onSkip,
        ),
        const SizedBox(width: AppSpacing.xl),
        AppIconButton(
          icon: running ? CupertinoIcons.pause : CupertinoIcons.play,
          semanticLabel: running ? 'Pause' : 'Start',
          onPressed: onPlayPause,
        ),
      ],
    );
  }
}

enum _FocusPhase { idle, focus, breakTime, paused }
