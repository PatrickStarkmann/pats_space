import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/stats/utils/stats_date_formatters.dart';

class MonthCalendarCard extends StatelessWidget {
  const MonthCalendarCard({
    super.key,
    required this.visibleMonth,
    required this.records,
    required this.today,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime visibleMonth;
  final List<FocusSessionRecord> records;
  final DateTime today;
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
                  title: formatMonthTitle(visibleMonth),
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
                          isToday: _isToday(dayNumber),
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

  bool _isToday(int day) {
    return visibleMonth.year == today.year &&
        visibleMonth.month == today.month &&
        day == today.day;
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.record,
    required this.isToday,
  });

  final int day;
  final FocusSessionRecord? record;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final hasRecord = record != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day.toString(),
          style: AppTextStyles.headline.copyWith(
            color: isToday ? CupertinoColors.systemRed : AppColors.charcoal,
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
              color: isToday ? AppColors.charcoal : const Color(0xFFE7E8EB),
              width: isToday ? 3 : 2.4,
            ),
          ),
          child: SizedBox(
            width: 36,
            height: 36,
            child: hasRecord ? _CalendarBadgeIcon(record: record!) : null,
          ),
        ),
      ],
    );
  }
}

class _CalendarBadgeIcon extends StatelessWidget {
  const _CalendarBadgeIcon({required this.record});

  final FocusSessionRecord record;

  @override
  Widget build(BuildContext context) {
    final badgeIcon = record.tag.badgeIcon;
    if (badgeIcon == FocusBadgeIcon.none) {
      return const SizedBox.shrink();
    }

    final assetPath = badgeIcon.assetPath;
    if (assetPath != null) {
      return Center(
        child: ClipOval(
          child: SizedBox(
            width: 31,
            height: 31,
            child: Transform.translate(
              offset: const Offset(0, 6),
              child: Image.asset(
                assetPath,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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
