import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/focus_session_phase.dart';

class FocusHomeWidgetService {
  const FocusHomeWidgetService();

  static const _channel = MethodChannel('pats_space/focus_home_widget');
  static Future<void> _operationQueue = Future.value();

  Future<void> sync(FocusTimerController timer, {required String title}) async {
    if (!Platform.isIOS) return;
    final arguments = <String, Object?>{
      'active': timer.active,
      'paused': timer.paused,
      'phase': switch (timer.phase) {
        FocusSessionPhase.breakTime => 'Pause',
        _ => 'Fokus',
      },
      'title': title,
      'countsUp': timer.phase == FocusSessionPhase.stopwatch,
      'remainingSeconds': timer.remainingSeconds,
      'totalSeconds': timer.currentPhaseTotalSeconds,
      'completedSessions': timer.completedSessions,
      'sessionsPerRound': timer.settings.sessionsPerRound,
      'expectedEndMilliseconds': !timer.active || timer.paused
          ? null
          : timer.phase == FocusSessionPhase.stopwatch
          ? DateTime.now()
                .subtract(Duration(seconds: timer.remainingSeconds))
                .millisecondsSinceEpoch
          : DateTime.now()
                .add(Duration(seconds: timer.remainingSeconds))
                .millisecondsSinceEpoch,
    };

    _operationQueue = _operationQueue.then((_) => _invoke(arguments));
    await _operationQueue;
  }

  Future<void> _invoke(Map<String, Object?> arguments) async {
    try {
      await _channel.invokeMethod<void>('sync', arguments);
    } on MissingPluginException {
      // The widget extension is optional.
    } on PlatformException {
      // The focus timer must remain independent from the widget.
    } catch (_) {
      // Keep a failed native call from blocking the next widget update.
    }
  }
}
