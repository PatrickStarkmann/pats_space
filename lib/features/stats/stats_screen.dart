import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/settings/models/week_start_day.dart';
import 'package:pats_space/features/stats/utils/stats_aggregations.dart';
import 'package:pats_space/features/stats/utils/stats_date_formatters.dart';
import 'package:pats_space/features/stats/widgets/focus_by_tags_card.dart';
import 'package:pats_space/features/stats/widgets/focus_line_chart_card.dart';
import 'package:pats_space/features/stats/widgets/month_calendar_card.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({
    super.key,
    required this.historyController,
    required this.weekStartDay,
  });

  final FocusHistoryController historyController;
  final WeekStartDay weekStartDay;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _visibleMonth;
  late DateTime _visibleWeek;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _visibleWeek = startOfWeek(now, widget.weekStartDay);
  }

  @override
  void didUpdateWidget(covariant StatsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weekStartDay != widget.weekStartDay) {
      _visibleWeek = startOfWeek(_visibleWeek, widget.weekStartDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.historyController,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        final records = widget.historyController.records;
        final now = DateTime.now();
        final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.md,
              MediaQuery.paddingOf(context).bottom + AppSpacing.xxl * 2.4,
            ),
            child: Column(
              children: [
                MonthCalendarCard(
                  visibleMonth: _visibleMonth,
                  records: records,
                  today: now,
                  weekStartDay: widget.weekStartDay,
                  onPreviousMonth: _showPreviousMonth,
                  onNextMonth: _showNextMonth,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (tablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _weeklyChart(l10n, records)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: _monthlyChart(l10n, records)),
                    ],
                  )
                else ...[
                  _weeklyChart(l10n, records),
                  const SizedBox(height: AppSpacing.lg),
                  _monthlyChart(l10n, records),
                ],
                const SizedBox(height: AppSpacing.lg),
                FocusByTagsCard(records: records),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _weeklyChart(AppLocalizations l10n, List<FocusSessionRecord> records) {
    return FocusLineChartCard(
      title: l10n.avgFocusTime,
      value: formatDuration(
        averageDailyFocusTime(records, _visibleWeek, widget.weekStartDay),
      ),
      rangeTitle: formatWeekRange(_visibleWeek, l10n, widget.weekStartDay),
      labels: _weekdayLabels(l10n),
      values: weeklyFocusHours(records, _visibleWeek, widget.weekStartDay),
      onPreviousRange: _showPreviousWeek,
      onNextRange: _showNextWeek,
    );
  }

  Widget _monthlyChart(
    AppLocalizations l10n,
    List<FocusSessionRecord> records,
  ) {
    return FocusLineChartCard(
      title: l10n.monthlyFocusTime,
      value: formatDuration(monthlyFocusTime(records, _visibleMonth)),
      rangeTitle: formatMonthShortTitle(_visibleMonth, l10n),
      labels: const ['1', '7', '14', '21', '28', '31'],
      values: monthlyFocusHours(records, _visibleMonth),
      onPreviousRange: _showPreviousMonth,
      onNextRange: _showNextMonth,
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

  void _showPreviousWeek() {
    setState(() {
      _visibleWeek = _visibleWeek.subtract(const Duration(days: 7));
    });
  }

  void _showNextWeek() {
    setState(() {
      _visibleWeek = _visibleWeek.add(const Duration(days: 7));
    });
  }

  List<String> _weekdayLabels(AppLocalizations l10n) {
    final mondayFirst = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    if (widget.weekStartDay == WeekStartDay.monday) {
      return mondayFirst;
    }

    return [l10n.weekdaySun, ...mondayFirst.take(6)];
  }
}
