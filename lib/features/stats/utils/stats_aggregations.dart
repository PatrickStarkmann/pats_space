import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/settings/models/week_start_day.dart';
import 'package:pats_space/features/stats/models/tag_focus_segment.dart';

Duration averageDailyFocusTime(
  List<FocusSessionRecord> records,
  DateTime date,
  WeekStartDay weekStartDay,
) {
  final weekValues = weeklyFocusDurations(records, date, weekStartDay);
  final activeDays = weekValues.where((duration) => duration > Duration.zero);
  if (activeDays.isEmpty) {
    return Duration.zero;
  }

  final totalSeconds = activeDays.fold<int>(
    0,
    (total, duration) => total + duration.inSeconds,
  );
  return Duration(seconds: totalSeconds ~/ activeDays.length);
}

Duration monthlyFocusTime(List<FocusSessionRecord> records, DateTime month) {
  return records.fold(Duration.zero, (total, record) {
    final inMonth =
        record.completedAt.year == month.year &&
        record.completedAt.month == month.month;
    return inMonth ? total + record.focusDuration : total;
  });
}

List<double> weeklyFocusHours(
  List<FocusSessionRecord> records,
  DateTime date,
  WeekStartDay weekStartDay,
) {
  return weeklyFocusDurations(
    records,
    date,
    weekStartDay,
  ).map((duration) => duration.inMinutes / 60).toList();
}

List<Duration> weeklyFocusDurations(
  List<FocusSessionRecord> records,
  DateTime date,
  WeekStartDay weekStartDay,
) {
  final firstDayOfWeek = startOfWeek(date, weekStartDay);
  return List.generate(7, (index) {
    final day = firstDayOfWeek.add(Duration(days: index));
    return records.fold(Duration.zero, (total, record) {
      final sameDay =
          record.completedAt.year == day.year &&
          record.completedAt.month == day.month &&
          record.completedAt.day == day.day;
      return sameDay ? total + record.focusDuration : total;
    });
  });
}

DateTime startOfWeek(DateTime date, WeekStartDay weekStartDay) {
  final normalized = DateTime(date.year, date.month, date.day);
  final offset = switch (weekStartDay) {
    WeekStartDay.monday => normalized.weekday - DateTime.monday,
    WeekStartDay.sunday => normalized.weekday % DateTime.daysPerWeek,
  };
  return normalized.subtract(Duration(days: offset));
}

List<double> monthlyFocusHours(
  List<FocusSessionRecord> records,
  DateTime month,
) {
  const sampleDays = [1, 7, 14, 21, 28, 31];
  return sampleDays.map((day) {
    final cappedDay = math.min(
      day,
      DateTime(month.year, month.month + 1, 0).day,
    );
    final dayDate = DateTime(month.year, month.month, cappedDay);
    final duration = records.fold(Duration.zero, (total, record) {
      final sameDay =
          record.completedAt.year == dayDate.year &&
          record.completedAt.month == dayDate.month &&
          record.completedAt.day == dayDate.day;
      return sameDay ? total + record.focusDuration : total;
    });
    return duration.inMinutes / 60;
  }).toList();
}

List<TagFocusSegment> tagFocusSegments(List<FocusSessionRecord> records) {
  final totals = <String, _MutableTagTotal>{};
  for (final record in records) {
    final total = totals.putIfAbsent(
      record.tag.name,
      () => _MutableTagTotal(
        label: record.tag.name,
        color: record.tag.accentColor.color,
      ),
    );
    total.duration += record.focusDuration;
  }

  final totalDuration = totals.values.fold<int>(
    0,
    (total, tagTotal) => total + tagTotal.duration.inSeconds,
  );
  if (totalDuration == 0) {
    return const [];
  }

  final segments = totals.values.map((tagTotal) {
    final percentage = tagTotal.duration.inSeconds / totalDuration * 100;
    return TagFocusSegment(
      label: tagTotal.label,
      color: tagTotal.color,
      duration: tagTotal.duration,
      percentage: percentage,
    );
  }).toList()..sort((a, b) => b.duration.compareTo(a.duration));
  return segments;
}

class _MutableTagTotal {
  _MutableTagTotal({required this.label, required this.color});

  final String label;
  final Color color;
  Duration duration = Duration.zero;
}
