import 'package:flutter/widgets.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/stats/painters/donut_chart_painter.dart';
import 'package:pats_space/features/stats/utils/stats_aggregations.dart';
import 'package:pats_space/features/stats/utils/stats_date_formatters.dart';
import 'package:pats_space/features/stats/widgets/stats_card.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

class FocusByTagsCard extends StatelessWidget {
  const FocusByTagsCard({super.key, required this.records});

  final List<FocusSessionRecord> records;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final segments = tagFocusSegments(records);

    return StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CardTitleMarker(),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.focusByTags,
                style: AppTextStyles.headline.copyWith(
                  fontSize: 20,
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
                painter: DonutChartPainter(segments: segments),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (segments.isEmpty)
            Text(
              l10n.noFocusData,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${segment.percentage.round()}%, ${formatDuration(segment.duration)}',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.grayWarm,
                          fontSize: 17,
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
}
