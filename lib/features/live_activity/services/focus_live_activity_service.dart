import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/focus_session_phase.dart';

class FocusLiveActivityService {
  const FocusLiveActivityService();

  static const _channel = MethodChannel('pats_space/focus_live_activity');
  static Future<void> _operationQueue = Future.value();

  Future<void> sync(FocusTimerController timer, {required String title}) async {
    if (!Platform.isIOS) return;

    final arguments = timer.active
        ? <String, Object?>{
            'title': title,
            'phase': _phaseLabel(timer.phase),
            'paused': timer.paused,
            'countUp': timer.phase == FocusSessionPhase.stopwatch,
            'remainingSeconds': timer.remainingSeconds,
            'totalSeconds': timer.currentPhaseTotalSeconds,
            'expectedEndMilliseconds': timer.paused
                ? null
                : DateTime.now()
                      .add(
                        timer.phase == FocusSessionPhase.stopwatch
                            ? -Duration(seconds: timer.remainingSeconds)
                            : Duration(seconds: timer.remainingSeconds),
                      )
                      .millisecondsSinceEpoch,
          }
        : null;

    _operationQueue = _operationQueue.then((_) {
      return _invoke(arguments);
    });
    await _operationQueue;
  }

  Future<void> _invoke(Map<String, Object?>? arguments) async {
    try {
      if (arguments == null) {
        await _channel.invokeMethod<void>('end');
        return;
      }

      await _channel.invokeMethod<void>('sync', arguments);
    } on MissingPluginException {
      // The native target is unavailable on non-iOS builds and older installs.
    } on PlatformException {
      // Live Activities are an optional enhancement and must not affect focus.
    } catch (_) {
      // Keep a failed native operation from blocking a later timer state.
    }
  }

  String _phaseLabel(FocusSessionPhase phase) {
    return switch (phase) {
      FocusSessionPhase.focus => 'Focus',
      FocusSessionPhase.breakTime => 'Pause',
      FocusSessionPhase.stopwatch => 'Focus',
      FocusSessionPhase.idle => 'Focus',
    };
  }
}
