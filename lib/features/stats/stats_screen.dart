import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/stats/utils/stats_aggregations.dart';
import 'package:pats_space/features/stats/utils/stats_date_formatters.dart';
import 'package:pats_space/features/stats/widgets/focus_by_tags_card.dart';
import 'package:pats_space/features/stats/widgets/focus_line_chart_card.dart';
import 'package:pats_space/features/stats/widgets/month_calendar_card.dart';

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
        final now = DateTime.now();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.xxl,
            ),
            child: Column(
              children: [
                MonthCalendarCard(
                  visibleMonth: _visibleMonth,
                  records: records,
                  onPreviousMonth: _showPreviousMonth,
                  onNextMonth: _showNextMonth,
                ),
                const SizedBox(height: AppSpacing.lg),
                FocusLineChartCard(
                  title: 'Avg Focus Time',
                  value: formatDuration(averageDailyFocusTime(records)),
                  rangeTitle: formatWeekRange(now),
                  labels: const [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ],
                  values: weeklyFocusHours(records, now),
                  onPreviousRange: () {},
                  onNextRange: () {},
                ),
                const SizedBox(height: AppSpacing.lg),
                FocusLineChartCard(
                  title: 'Monthly Focus Time',
                  value: formatDuration(
                    monthlyFocusTime(records, _visibleMonth),
                  ),
                  rangeTitle: formatMonthShortTitle(_visibleMonth),
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
}
