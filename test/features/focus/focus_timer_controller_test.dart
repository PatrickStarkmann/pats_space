import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_phase.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';

void main() {
  group('FocusTimerController', () {
    testWidgets(
      'auto-starts next focus after a break until round is complete',
      (tester) async {
        final records = <FocusSessionRecord>[];
        var completedRounds = 0;
        final controller = FocusTimerController(
          initialSettings: FocusTimerController.defaultSettings.copyWith(
            focusMinutes: 1,
            shortBreakMinutes: 1,
            longBreakMinutes: 1,
            sessionsPerRound: 2,
          ),
          onFocusSessionCompleted: records.add,
          onFocusRoundCompleted: () => completedRounds += 1,
        );
        addTearDown(controller.dispose);

        controller.toggle();
        expect(controller.phase, FocusSessionPhase.focus);

        await tester.pump(const Duration(minutes: 1));
        expect(controller.phase, FocusSessionPhase.breakTime);
        expect(records, hasLength(1));

        await tester.pump(const Duration(minutes: 1));
        expect(controller.phase, FocusSessionPhase.focus);
        expect(controller.completedSessions, 1);
        expect(completedRounds, 0);

        await tester.pump(const Duration(minutes: 1));
        expect(controller.phase, FocusSessionPhase.breakTime);
        expect(records, hasLength(2));

        await tester.pump(const Duration(minutes: 1));
        expect(controller.phase, FocusSessionPhase.idle);
        expect(controller.completedSessions, 2);
        expect(completedRounds, 1);
      },
    );

    testWidgets('skip during break starts next focus when sessions remain', (
      tester,
    ) async {
      final controller = FocusTimerController(
        initialSettings: FocusTimerController.defaultSettings.copyWith(
          focusMinutes: 1,
          shortBreakMinutes: 1,
          longBreakMinutes: 1,
          sessionsPerRound: 2,
        ),
      );

      controller.toggle();
      await tester.pump(const Duration(minutes: 1));
      expect(controller.phase, FocusSessionPhase.breakTime);

      controller.skip();
      expect(controller.phase, FocusSessionPhase.focus);
      expect(controller.completedSessions, 1);
      controller.dispose();
    });

    testWidgets('stopwatch records elapsed duration when finished', (
      tester,
    ) async {
      final records = <FocusSessionRecord>[];
      final controller = FocusTimerController(
        initialSettings: FocusTimerController.defaultSettings.copyWith(
          mode: FocusMode.stopwatch,
        ),
        onFocusSessionCompleted: records.add,
      );
      addTearDown(controller.dispose);

      controller.toggle();
      await tester.pump(const Duration(minutes: 7, seconds: 30));
      controller.finishStopwatch();

      expect(controller.phase, FocusSessionPhase.idle);
      expect(records, hasLength(1));
      expect(records.single.mode, FocusMode.stopwatch);
      expect(
        records.single.focusDuration,
        const Duration(minutes: 7, seconds: 30),
      );
    });
  });
}
