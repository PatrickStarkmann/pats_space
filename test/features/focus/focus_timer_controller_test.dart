import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_phase.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';

void main() {
  group('FocusTimerController', () {
    testWidgets('uses the optional 30-second focus duration', (tester) async {
      final controller = FocusTimerController(
        initialSettings: FocusTimerController.defaultSettings.copyWith(
          focusSeconds: 30,
        ),
      );
      addTearDown(controller.dispose);

      controller.toggle();
      expect(controller.remainingSeconds, 30);

      await tester.pump(const Duration(seconds: 30));
      expect(controller.phase, FocusSessionPhase.breakTime);

      await tester.pump(const Duration(seconds: 30));
      expect(controller.phase, FocusSessionPhase.focus);
      controller.cancelFocusRound();
    });

    testWidgets(
      'auto-starts next focus after a break until round is complete',
      (tester) async {
        final records = <FocusSessionRecord>[];
        var completedRounds = 0;
        var completedFocusPeriods = 0;
        var completedBreakPeriods = 0;
        var finishedRounds = 0;
        final controller = FocusTimerController(
          initialSettings: FocusTimerController.defaultSettings.copyWith(
            focusMinutes: 1,
            shortBreakMinutes: 1,
            longBreakMinutes: 1,
            sessionsPerRound: 2,
          ),
          onFocusSessionCompleted: records.add,
          onFocusRoundCompleted: () => completedRounds += 1,
          onFocusPeriodCompleted: () => completedFocusPeriods += 1,
          onBreakPeriodCompleted: () => completedBreakPeriods += 1,
          onFocusRoundFinished: () => finishedRounds += 1,
        );
        addTearDown(controller.dispose);

        controller.toggle();
        expect(controller.phase, FocusSessionPhase.focus);

        await tester.pump(const Duration(minutes: 1));
        expect(controller.phase, FocusSessionPhase.breakTime);
        expect(records, hasLength(1));
        expect(completedFocusPeriods, 1);

        await tester.pump(const Duration(minutes: 1));
        expect(controller.phase, FocusSessionPhase.focus);
        expect(controller.completedSessions, 1);
        expect(completedRounds, 0);
        expect(completedBreakPeriods, 1);

        await tester.pump(const Duration(minutes: 1));
        expect(controller.phase, FocusSessionPhase.breakTime);
        expect(records, hasLength(2));
        expect(completedFocusPeriods, 2);

        await tester.pump(const Duration(minutes: 1));
        expect(controller.phase, FocusSessionPhase.idle);
        expect(controller.completedSessions, 2);
        expect(completedRounds, 1);
        expect(completedBreakPeriods, 1);
        expect(finishedRounds, 1);
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

    testWidgets(
      'emits the normal finish event when the last break is skipped',
      (tester) async {
        var completedBreakPeriods = 0;
        var finishedRounds = 0;
        final controller = FocusTimerController(
          initialSettings: FocusTimerController.defaultSettings.copyWith(
            focusMinutes: 1,
            shortBreakMinutes: 1,
            sessionsPerRound: 1,
          ),
          onBreakPeriodCompleted: () => completedBreakPeriods += 1,
          onFocusRoundFinished: () => finishedRounds += 1,
        );
        addTearDown(controller.dispose);

        controller.toggle();
        await tester.pump(const Duration(minutes: 1));
        controller.skip();

        expect(completedBreakPeriods, 0);
        expect(finishedRounds, 1);
        expect(controller.phase, FocusSessionPhase.idle);
      },
    );

    test('emits the normal focus-end event when focus is skipped', () {
      var completedFocusPeriods = 0;
      final controller = FocusTimerController(
        onFocusPeriodCompleted: () => completedFocusPeriods += 1,
      );
      addTearDown(controller.dispose);

      controller.toggle();
      controller.skip();

      expect(controller.phase, FocusSessionPhase.breakTime);
      expect(completedFocusPeriods, 1);
    });

    testWidgets('uses a temporary focus duration when one is provided', (
      tester,
    ) async {
      final records = <FocusSessionRecord>[];
      final controller = FocusTimerController(
        focusDurationOverride: const Duration(seconds: 30),
        onFocusSessionCompleted: records.add,
      );

      controller.toggle();
      expect(controller.remainingSeconds, 30);

      await tester.pump(const Duration(seconds: 30));
      expect(controller.phase, FocusSessionPhase.breakTime);
      expect(records, hasLength(1));
      expect(records.single.focusDuration, const Duration(seconds: 30));
      controller.dispose();
    });

    testWidgets('can stop after a completed focus without starting a break', (
      tester,
    ) async {
      final controller = FocusTimerController(
        focusDurationOverride: const Duration(seconds: 30),
        startBreakAfterFocus: false,
      );

      controller.toggle();
      await tester.pump(const Duration(seconds: 30));

      expect(controller.phase, FocusSessionPhase.idle);
      expect(controller.remainingSeconds, 0);
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
