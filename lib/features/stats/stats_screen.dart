import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.historyController});

  final FocusHistoryController historyController;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.historyController,
      builder: (context, child) {
        final records = widget.historyController.records;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.xxl,
            ),
            child: FractionallySizedBox(
              widthFactor: 1,
              child: Column(
                children: [
                  _MonthCalendarCard(
                    visibleMonth: _visibleMonth,
                    records: records,
                    onPreviousMonth: _showPreviousMonth,
                    onNextMonth: _showNextMonth,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FocusLineChartCard(
                    title: 'Avg Focus Time',
                    value: _formatDuration(_averageDailyFocusTime(records)),
                    rangeTitle: _formatWeekRange(DateTime.now()),
                    labels: const [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ],
                    values: _weeklyFocusHours(records, DateTime.now()),
                    onPreviousRange: () {},
                    onNextRange: () {},
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FocusLineChartCard(
                    title: 'Monthly Focus Time',
                    value: _formatDuration(
                      _monthlyFocusTime(records, _visibleMonth),
                    ),
                    rangeTitle: _formatMonthShortTitle(_visibleMonth),
                    labels: const ['1', '7', '14', '21', '28', '31'],
                    values: _monthlyFocusHours(records, _visibleMonth),
                    onPreviousRange: _showPreviousMonth,
                    onNextRange: _showNextMonth,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FocusByTagsCard(records: records),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _showNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }
}

class _FocusLineChartCard extends StatelessWidget {
  const _FocusLineChartCard({
    required this.title,
    required this.value,
    required this.rangeTitle,
    required this.labels,
    required this.values,
    required this.onPreviousRange,
    required this.onNextRange,
  });

  final String title;
  final String value;
  final String rangeTitle;
  final List<String> labels;
  final List<double> values;
  final VoidCallback onPreviousRange;
  final VoidCallback onNextRange;

  @override
  Widget build(BuildContext context) {
    return _StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: AppTextStyles.title.copyWith(fontSize: 39),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.grayWarm,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _RangePill(
                title: rangeTitle,
                onPrevious: onPreviousRange,
                onNext: onNextRange,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 150,
            child: _LineChart(values: values, labels: labels),
          ),
        ],
      ),
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    required this.title,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: 174,
        height: 45,
        child: Row(
          children: [
            _SmallPillArrow(
              icon: CupertinoIcons.chevron_left,
              onPressed: onPrevious,
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.headline.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _SmallPillArrow(
              icon: CupertinoIcons.chevron_right,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPillArrow extends StatelessWidget {
  const _SmallPillArrow({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: 42,
        height: 45,
        child: Icon(icon, color: AppColors.charcoal, size: 22),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(values: values, labels: labels),
      size: Size.infinite,
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const leftLabelInset = 18.0;
    const rightLabelWidth = 30.0;
    const bottomLabelHeight = 26.0;
    final chartRect = Rect.fromLTWH(
      leftLabelInset,
      0,
      size.width - leftLabelInset - rightLabelWidth,
      size.height - bottomLabelHeight,
    );
    final gridPaint = Paint()
      ..color = const Color(0xFFD4D4D8)
      ..strokeWidth = 1;
    final dashedPaint = Paint()
      ..color = const Color(0xFFC9C9CE)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xFF35C962)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i <= 4; i++) {
      final y = chartRect.top + chartRect.height * i / 4;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
      _drawText(
        canvas,
        '${4 - i}h',
        Offset(chartRect.right + 8, y - 11),
        color: AppColors.grayWarm,
        fontSize: 16,
      );
    }

    final verticalCount = labels.length;
    for (var i = 0; i < verticalCount; i++) {
      final x = verticalCount == 1
          ? chartRect.left
          : chartRect.left + chartRect.width * i / (verticalCount - 1);
      _drawDashedLine(
        canvas,
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom + 10),
        dashedPaint,
      );
      _drawText(
        canvas,
        labels[i],
        Offset(x, chartRect.bottom + 4),
        color: AppColors.grayWarm,
        fontSize: 14,
        horizontalAnchor: _TextHorizontalAnchor.center,
      );
    }

    if (values.isEmpty) {
      return;
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? chartRect.left
          : chartRect.left + chartRect.width * i / (values.length - 1);
      final normalized = (values[i] / 4).clamp(0.0, 1.0);
      final y = chartRect.bottom - chartRect.height * normalized;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashHeight = 5.0;
    const dashSpace = 5.0;
    var distance = 0.0;
    final totalDistance = (end - start).distance;
    final direction = (end - start) / totalDistance;
    while (distance < totalDistance) {
      final dashStart = start + direction * distance;
      final dashEnd =
          start + direction * math.min(distance + dashHeight, totalDistance);
      canvas.drawLine(dashStart, dashEnd, paint);
      distance += dashHeight + dashSpace;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    required double fontSize,
    _TextHorizontalAnchor horizontalAnchor = _TextHorizontalAnchor.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (horizontalAnchor) {
      _TextHorizontalAnchor.left => offset.dx,
      _TextHorizontalAnchor.center => offset.dx - painter.width / 2,
    };
    painter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}

enum _TextHorizontalAnchor { left, center }

class _FocusByTagsCard extends StatelessWidget {
  const _FocusByTagsCard({required this.records});

  final List<FocusSessionRecord> records;

  @override
  Widget build(BuildContext context) {
    final segments = _tagSegments(records);

    return _StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _CardTitleMarker(),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Focus by Tags',
                style: AppTextStyles.headline.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: SizedBox(
              width: 230,
              height: 230,
              child: CustomPaint(
                painter: _DonutChartPainter(segments: segments),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (segments.isEmpty)
            Text(
              'Noch keine Fokusdaten',
              style: AppTextStyles.body.copyWith(color: AppColors.grayWarm),
            )
          else
            Column(
              children: segments.map((segment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: segment.color,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(width: 18, height: 18),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          segment.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headline.copyWith(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${segment.percentage.round()}%, ${_formatDuration(segment.duration)}',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.grayWarm,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  List<_TagSegment> _tagSegments(List<FocusSessionRecord> records) {
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
      return _TagSegment(
        label: tagTotal.label,
        color: tagTotal.color,
        duration: tagTotal.duration,
        percentage: percentage,
      );
    }).toList()..sort((a, b) => b.duration.compareTo(a.duration));
    return segments;
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({required this.segments});

  final List<_TagSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = size.width * 0.23;
    final center = rect.center;
    final radius = size.width / 2 - strokeWidth / 2;
    final basePaint = Paint()
      ..color = const Color(0xFFE9EAEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (segments.isEmpty) {
      canvas.drawCircle(center, radius, basePaint);
      return;
    }

    var startAngle = -math.pi / 2;
    final total = segments.fold<double>(
      0,
      (total, segment) => total + segment.duration.inSeconds,
    );

    for (final segment in segments) {
      final sweepAngle = segment.duration.inSeconds / total * math.pi * 2;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.08,
        math.max(0, sweepAngle - 0.16),
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

class _CardTitleMarker extends StatelessWidget {
  const _CardTitleMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const SizedBox(width: 7, height: 28),
    );
  }
}

class _MutableTagTotal {
  _MutableTagTotal({required this.label, required this.color});

  final String label;
  final Color color;
  Duration duration = Duration.zero;
}

class _TagSegment {
  const _TagSegment({
    required this.label,
    required this.color,
    required this.duration,
    required this.percentage,
  });

  final String label;
  final Color color;
  final Duration duration;
  final double percentage;
}

class _MonthCalendarCard extends StatelessWidget {
  const _MonthCalendarCard({
    required this.visibleMonth,
    required this.records,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime visibleMonth;
  final List<FocusSessionRecord> records;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final recordsByDay = _recordsByDay(records, visibleMonth);
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final firstWeekdayOffset =
        DateTime(visibleMonth.year, visibleMonth.month).weekday % 7;
    final cellCount = firstWeekdayOffset + daysInMonth;
    final rowCount = (cellCount / 7).ceil();
    final weekdays = ['So.', 'Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.'];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CalendarHeaderPill(
                  title: _formatMonthTitle(visibleMonth),
                  onPreviousMonth: onPreviousMonth,
                  onNextMonth: onNextMonth,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: weekdays.map((weekday) {
                return Expanded(
                  child: Text(
                    weekday,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headline.copyWith(
                      color: const Color(0xFFB9C1CC),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xs),
            Column(
              children: List.generate(rowCount, (rowIndex) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: rowIndex == rowCount - 1 ? 0 : AppSpacing.md,
                  ),
                  child: Row(
                    children: List.generate(7, (weekdayIndex) {
                      final dayIndex = rowIndex * 7 + weekdayIndex;
                      final dayNumber = dayIndex - firstWeekdayOffset + 1;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const Expanded(child: SizedBox(height: 60));
                      }

                      return Expanded(
                        child: _CalendarDayCell(
                          day: dayNumber,
                          record: recordsByDay[dayNumber],
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, FocusSessionRecord> _recordsByDay(
    List<FocusSessionRecord> records,
    DateTime month,
  ) {
    final matchingRecords = records.where((record) {
      return record.completedAt.year == month.year &&
          record.completedAt.month == month.month;
    });
    final groupedRecords = <int, FocusSessionRecord>{};
    for (final record in matchingRecords) {
      groupedRecords.putIfAbsent(record.completedAt.day, () => record);
    }
    return groupedRecords;
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({required this.day, required this.record});

  final int day;
  final FocusSessionRecord? record;

  @override
  Widget build(BuildContext context) {
    final hasRecord = record != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day.toString(),
          style: AppTextStyles.headline.copyWith(
            color: hasRecord
                ? record!.tag.accentColor.color
                : AppColors.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: hasRecord
                ? record!.tag.accentColor.color
                : AppColors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: hasRecord
                  ? record!.tag.accentColor.color
                  : const Color(0xFFE7E8EB),
              width: 2.4,
            ),
          ),
          child: SizedBox(
            width: 36,
            height: 36,
            child: hasRecord
                ? Icon(
                    record!.tag.badgeIcon.icon,
                    color: AppColors.charcoal,
                    size: 18,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _CalendarHeaderPill extends StatelessWidget {
  const _CalendarHeaderPill({
    required this.title,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final String title;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: SizedBox(
          height: 46,
          child: Row(
            children: [
              _CalendarPillButton(
                icon: CupertinoIcons.chevron_left,
                onPressed: onPreviousMonth,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _CalendarPillButton(
                icon: CupertinoIcons.chevron_right,
                onPressed: onNextMonth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarPillButton extends StatelessWidget {
  const _CalendarPillButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: 58,
        height: 46,
        child: Icon(icon, color: AppColors.charcoal, size: 27),
      ),
    );
  }
}

String _formatMonthTitle(DateTime month) {
  return '${month.year} / ${month.month.toString().padLeft(2, '0')}';
}

String _formatMonthShortTitle(DateTime month) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${monthNames[month.month - 1]} ${month.year}';
}

String _formatWeekRange(DateTime date) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final startOfWeek = DateTime(
    date.year,
    date.month,
    date.day - (date.weekday - 1),
  );
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  if (startOfWeek.month == endOfWeek.month) {
    return '${monthNames[startOfWeek.month - 1]}, ${startOfWeek.day} - ${endOfWeek.day}';
  }
  return '${monthNames[startOfWeek.month - 1]} ${startOfWeek.day} - ${monthNames[endOfWeek.month - 1]} ${endOfWeek.day}';
}

Duration _averageDailyFocusTime(List<FocusSessionRecord> records) {
  final weekValues = _weeklyFocusDurations(records, DateTime.now());
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

Duration _monthlyFocusTime(List<FocusSessionRecord> records, DateTime month) {
  return records.fold(Duration.zero, (total, record) {
    final inMonth =
        record.completedAt.year == month.year &&
        record.completedAt.month == month.month;
    return inMonth ? total + record.focusDuration : total;
  });
}

List<double> _weeklyFocusHours(
  List<FocusSessionRecord> records,
  DateTime date,
) {
  return _weeklyFocusDurations(
    records,
    date,
  ).map((duration) => duration.inMinutes / 60).toList();
}

List<Duration> _weeklyFocusDurations(
  List<FocusSessionRecord> records,
  DateTime date,
) {
  final startOfWeek = DateTime(
    date.year,
    date.month,
    date.day - (date.weekday - 1),
  );
  return List.generate(7, (index) {
    final day = startOfWeek.add(Duration(days: index));
    return records.fold(Duration.zero, (total, record) {
      final sameDay =
          record.completedAt.year == day.year &&
          record.completedAt.month == day.month &&
          record.completedAt.day == day.day;
      return sameDay ? total + record.focusDuration : total;
    });
  });
}

List<double> _monthlyFocusHours(
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

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes < 60) {
    return '${minutes}m';
  }

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (remainingMinutes == 0) {
    return '${hours}h';
  }

  return '${hours}h ${remainingMinutes}m';
}
