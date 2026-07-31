import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_tag.dart';
import 'package:pats_space/features/settings/models/week_start_day.dart';
import 'package:pats_space/features/stats/utils/stats_aggregations.dart';

void main() {
  group('stats week start', () {
    test('starts on Monday when configured', () {
      final start = startOfWeek(DateTime(2026, 7, 22), WeekStartDay.monday);

      expect(start, DateTime(2026, 7, 20));
    });

    test('starts on Sunday when configured', () {
      final start = startOfWeek(DateTime(2026, 7, 22), WeekStartDay.sunday);

      expect(start, DateTime(2026, 7, 19));
    });

    test('weekly durations follow the selected start day', () {
      final records = [
        _record(id: 'sun', completedAt: DateTime(2026, 7, 19)),
        _record(id: 'mon', completedAt: DateTime(2026, 7, 20)),
      ];

      final mondayFirst = weeklyFocusDurations(
        records,
        DateTime(2026, 7, 22),
        WeekStartDay.monday,
      );
      final sundayFirst = weeklyFocusDurations(
        records,
        DateTime(2026, 7, 22),
        WeekStartDay.sunday,
      );

      expect(mondayFirst.first, const Duration(minutes: 25));
      expect(sundayFirst.first, const Duration(minutes: 25));
      expect(sundayFirst[1], const Duration(minutes: 25));
    });
  });
}

FocusSessionRecord _record({
  required String id,
  required DateTime completedAt,
}) {
  return FocusSessionRecord(
    id: id,
    tag: const FocusTag(
      name: 'Study',
      accentColor: FocusAccentColor.sunshine,
      badgeIcon: FocusBadgeIcon.character,
    ),
    mode: FocusMode.pomodoro,
    focusDuration: const Duration(minutes: 25),
    startedAt: completedAt.subtract(const Duration(minutes: 25)),
    completedAt: completedAt,
    animationPair: FocusAnimationPair.standard,
  );
}
