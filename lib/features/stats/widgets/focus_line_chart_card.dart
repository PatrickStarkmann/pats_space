import 'package:flutter/widgets.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/stats/painters/line_chart_painter.dart';
import 'package:pats_space/features/stats/widgets/range_pill.dart';
import 'package:pats_space/features/stats/widgets/stats_card.dart';

class FocusLineChartCard extends StatelessWidget {
  const FocusLineChartCard({
    super.key,
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
    return StatsCard(
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
              RangePill(
                title: rangeTitle,
                onPrevious: onPreviousRange,
                onNext: onNextRange,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: LineChartPainter(values: values, labels: labels),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}
