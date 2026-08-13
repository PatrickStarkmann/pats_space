import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/active_timer_state.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_phase.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';

void main() {
  group('FocusTimerController', () {
    test(
      'catches up a running timer after the app returns from background',
      () {
        var now = DateTime(2026, 8, 12, 16);
        var focusEndSounds = 0;
        final controller = FocusTimerController(
          initialSettings: FocusTimerController.defaultSettings.copyWith(
            focusSeconds: 30,
          ),
          clock: () => now,
          onFocusPeriodCompleted: () => focusEndSounds += 1,
        );
        addTearDown(controller.dispose);

        controller.toggle();
        controller.suspendForBackground();
        now = now.add(const Duration(seconds: 45));
        controller.resumeFromBackground();

        expect(controller.phase, FocusSessionPhase.breakTime);
        expect(controller.remainingSeconds, 15);
        expect(focusEndSounds, 0);
        controller.cancelFocusRound();
      },
    );

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
      'waits for manual start between phases when auto continue is off',
      (tester) async {
        final controller = FocusTimerController(
          initialSettings: FocusTimerController.defaultSettings.copyWith(
            focusSeconds: 30,
            autoContinue: false,
          ),
        );
        addTearDown(controller.dispose);

        controller.toggle();
        await tester.pump(const Duration(seconds: 30));

        expect(controller.phase, FocusSessionPhase.breakTime);
        expect(controller.paused, isTrue);
        expect(controller.remainingSeconds, 30);
      },
    );

    test(
      'does not skip further phases on resume when auto continue is off',
      () {
        var now = DateTime(2026, 8, 13, 16);
        final controller = FocusTimerController(
          initialSettings: FocusTimerController.defaultSettings.copyWith(
            focusSeconds: 30,
            autoContinue: false,
          ),
          clock: () => now,
        );
        addTearDown(controller.dispose);

        controller.toggle();
        controller.suspendForBackground();
        now = now.add(const Duration(minutes: 3));
        controller.resumeFromBackground();

        expect(controller.phase, FocusSessionPhase.breakTime);
        expect(controller.paused, isTrue);
        expect(controller.completedSessions, 0);
        expect(controller.remainingSeconds, 30);
      },
    );

    test('restores a running timer from the elapsed wall-clock time', () {
      var now = DateTime(2026, 8, 13, 16);
      final controller = FocusTimerController(
        initialSettings: FocusTimerController.defaultSettings.copyWith(
          focusSeconds: 30,
        ),
        clock: () => now,
      );
      addTearDown(controller.dispose);

      controller.restore(
        ActiveTimerState(
          phase: FocusSessionPhase.focus,
          paused: false,
          completedSessions: 0,
          remainingSeconds: 30,
          savedAt: now,
        ),
      );
      final savedState = controller.persistentState!;
      now = now.add(const Duration(seconds: 45));
      controller.restore(savedState);

      expect(controller.phase, FocusSessionPhase.breakTime);
      expect(controller.remainingSeconds, 15);
      controller.cancelFocusRound();
    });

    test('restores a paused timer without consuming elapsed time', () {
      var now = DateTime(2026, 8, 13, 16);
      final controller = FocusTimerController(
        initialSettings: FocusTimerController.defaultSettings.copyWith(
          focusSeconds: 30,
        ),
        clock: () => now,
      );
      addTearDown(controller.dispose);

      controller.restore(
        ActiveTimerState(
          phase: FocusSessionPhase.breakTime,
          paused: true,
          completedSessions: 0,
          remainingSeconds: 30,
          savedAt: now,
        ),
      );
      final savedState = controller.persistentState!;
      now = now.add(const Duration(minutes: 5));
      controller.restore(savedState);

      expect(controller.phase, FocusSessionPhase.breakTime);
      expect(controller.paused, isTrue);
      expect(controller.remainingSeconds, 30);
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

    testWidgets('clears completed session dots when a round is acknowledged', (
      tester,
    ) async {
      final controller = FocusTimerController(
        initialSettings: FocusTimerController.defaultSettings.copyWith(
          focusSeconds: 30,
          sessionsPerRound: 1,
        ),
      );
      addTearDown(controller.dispose);

      controller.toggle();
      await tester.pump(const Duration(seconds: 30));
      await tester.pump(const Duration(seconds: 30));
      expect(controller.completedSessions, 1);

      controller.acknowledgeRoundCompletion();
      expect(controller.completedSessions, 0);
    });

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
