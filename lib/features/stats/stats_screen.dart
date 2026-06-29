import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/stats/utils/stats_aggregations.dart';
import 'package:pats_space/features/stats/utils/stats_date_formatters.dart';
import 'package:pats_space/features/stats/widgets/focus_by_tags_card.dart';
import 'package:pats_space/features/stats/widgets/focus_line_chart_card.dart';
import 'package:pats_space/features/stats/widgets/month_calendar_card.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.historyController});

  final FocusHistoryController historyController;

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
    _visibleWeek = _startOfWeek(now);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.historyController,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        final records = widget.historyController.records;
        final now = DateTime.now();

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
                  onPreviousMonth: _showPreviousMonth,
                  onNextMonth: _showNextMonth,
                ),
                const SizedBox(height: AppSpacing.lg),
                FocusLineChartCard(
                  title: l10n.avgFocusTime,
                  value: formatDuration(
                    averageDailyFocusTime(records, _visibleWeek),
                  ),
                  rangeTitle: formatWeekRange(_visibleWeek, l10n),
                  labels: [
                    l10n.weekdayMon,
                    l10n.weekdayTue,
                    l10n.weekdayWed,
                    l10n.weekdayThu,
                    l10n.weekdayFri,
                    l10n.weekdaySat,
                    l10n.weekdaySun,
                  ],
                  values: weeklyFocusHours(records, _visibleWeek),
                  onPreviousRange: _showPreviousWeek,
                  onNextRange: _showNextWeek,
                ),
                const SizedBox(height: AppSpacing.lg),
                FocusLineChartCard(
                  title: l10n.monthlyFocusTime,
                  value: formatDuration(
                    monthlyFocusTime(records, _visibleMonth),
                  ),
                  rangeTitle: formatMonthShortTitle(_visibleMonth, l10n),
                  labels: const ['1', '7', '14', '21', '28', '31'],
                  values: monthlyFocusHours(records, _visibleMonth),
                  onPreviousRange: _showPreviousMonth,
                  onNextRange: _showNextMonth,
                ),
                const SizedBox(height: AppSpacing.lg),
                FocusByTagsCard(records: records),
              ],
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

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }
}
