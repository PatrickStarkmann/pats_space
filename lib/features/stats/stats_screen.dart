import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/leaderboard/controllers/friends_leaderboard_controller.dart';
import 'package:pats_space/features/leaderboard/models/friends_leaderboard_entry.dart';
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
    required this.leaderboardController,
  });

  final FocusHistoryController historyController;
  final WeekStartDay weekStartDay;
  final FriendsLeaderboardController leaderboardController;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _FriendsLeaderboardCard extends StatelessWidget {
  const _FriendsLeaderboardCard({
    required this.entries,
    required this.loading,
    required this.ownFocusSeconds,
    required this.onPressed,
  });

  final List<FriendsLeaderboardEntry> entries;
  final bool loading;
  final int ownFocusSeconds;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rankedEntries = _rankedEntries(entries, ownFocusSeconds, l10n.you);
    final friends = rankedEntries
        .where((entry) => !entry.isCurrentUser)
        .toList();
    final ownEntry = _ownEntry(rankedEntries, ownFocusSeconds, l10n.you);
    final ownRank = _rankOfCurrentUser(rankedEntries);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.rosette,
                  color: AppColors.charcoal,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(l10n.friendsThisWeek, style: AppTextStyles.headline),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (loading)
              const Center(child: CupertinoActivityIndicator())
            else if (friends.isEmpty) ...[
              _OwnFocusHero(entry: ownEntry),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.noFriendsLeaderboard, style: AppTextStyles.bodyMuted),
            ] else ...[
              _LeaderboardPodium(entries: rankedEntries.take(3).toList()),
              if (ownRank > 3) ...[
                const SizedBox(height: AppSpacing.md),
                _OwnFocusHero(entry: ownEntry, compact: true),
              ],
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  l10n.viewLeaderboard,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: AppColors.grayWarm,
                  size: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsLeaderboardSheet extends StatelessWidget {
  const _FriendsLeaderboardSheet({
    required this.entries,
    required this.ownFocusSeconds,
  });

  final List<FriendsLeaderboardEntry> entries;
  final int ownFocusSeconds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rankedEntries = _rankedEntries(entries, ownFocusSeconds, l10n.you);
    final ownEntry = _ownEntry(rankedEntries, ownFocusSeconds, l10n.you);
    final friends = rankedEntries
        .where((entry) => !entry.isCurrentUser)
        .toList();
    final ownRank = _rankOfCurrentUser(rankedEntries);
    return FractionallySizedBox(
      heightFactor: .72,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            MediaQuery.paddingOf(context).bottom + AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F4FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.graySoft,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.friendsLeaderboard,
                      style: AppTextStyles.title.copyWith(fontSize: 28),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      if (friends.isEmpty) ...[
                        _OwnFocusHero(entry: ownEntry),
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xl),
                          child: Text(
                            l10n.noFriendsLeaderboard,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMuted,
                          ),
                        ),
                      ] else ...[
                        _LeaderboardPodium(
                          entries: rankedEntries.take(3).toList(),
                        ),
                        if (ownRank > 3) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _OwnFocusHero(entry: ownEntry, compact: true),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        for (
                          var index = 3;
                          index < rankedEntries.length;
                          index++
                        )
                          _LeaderboardRow(
                            rank: index + 1,
                            entry: rankedEntries[index],
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.rank, required this.entry});

  final int rank;
  final FriendsLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppColors.sageSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          _RankBadge(rank: rank),
          const SizedBox(width: AppSpacing.sm),
          _InitialAvatar(entry: entry, size: 32),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              entry.isCurrentUser ? l10n.you : entry.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                fontWeight: entry.isCurrentUser ? FontWeight.w700 : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            l10n.focusMinutes((entry.focusSeconds / 60).floor()),
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _OwnFocusHero extends StatelessWidget {
  const _OwnFocusHero({required this.entry, this.compact = false});

  final FriendsLeaderboardEntry entry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: compact ? AppSpacing.sm : AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.sageSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          _InitialAvatar(entry: entry, size: compact ? 36 : 46),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.you,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            l10n.focusMinutes((entry.focusSeconds / 60).floor()),
            style: (compact ? AppTextStyles.body : AppTextStyles.headline)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPodium extends StatelessWidget {
  const _LeaderboardPodium({required this.entries});

  final List<FriendsLeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    FriendsLeaderboardEntry? entryAt(int rank) {
      return entries.length >= rank ? entries[rank - 1] : null;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _PodiumPlace(entry: entryAt(2), rank: 2)),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: _PodiumPlace(entry: entryAt(1), rank: 1)),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: _PodiumPlace(entry: entryAt(3), rank: 3)),
      ],
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({required this.entry, required this.rank});

  final FriendsLeaderboardEntry? entry;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final currentEntry = entry;
    final l10n = AppLocalizations.of(context);
    final height = switch (rank) {
      1 => 88.0,
      2 => 68.0,
      _ => 52.0,
    };
    final color = _medalColor(rank);
    if (currentEntry == null) {
      return SizedBox(height: height + 72);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _InitialAvatar(entry: currentEntry, size: rank == 1 ? 48 : 40),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          currentEntry.isCurrentUser ? l10n.you : currentEntry.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          l10n.focusMinutes((currentEntry.focusSeconds / 60).floor()),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              '$rank',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.entry, required this.size});

  final FriendsLeaderboardEntry entry;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = entry.displayName.trim().isEmpty
        ? '?'
        : entry.displayName.trim().characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppColors.sage : AppColors.surfaceMuted,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: AppTextStyles.body.copyWith(
          color: AppColors.charcoal,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final highlighted = rank <= 3;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlighted ? _medalColor(rank) : AppColors.surfaceMuted,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.charcoal,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color _medalColor(int rank) {
  return switch (rank) {
    1 => const Color(0xFFF4CE3F),
    2 => const Color(0xFFD8DADD),
    3 => const Color(0xFFD9A070),
    _ => AppColors.surfaceMuted,
  };
}

FriendsLeaderboardEntry _ownEntry(
  List<FriendsLeaderboardEntry> entries,
  int ownFocusSeconds,
  String ownLabel,
) {
  for (final entry in entries) {
    if (entry.isCurrentUser) return entry;
  }
  return FriendsLeaderboardEntry(
    userId: 'current-user',
    displayName: ownLabel,
    focusSeconds: ownFocusSeconds,
    isCurrentUser: true,
  );
}

List<FriendsLeaderboardEntry> _rankedEntries(
  List<FriendsLeaderboardEntry> entries,
  int ownFocusSeconds,
  String ownLabel,
) {
  final rankedEntries = [...entries];
  if (!rankedEntries.any((entry) => entry.isCurrentUser)) {
    rankedEntries.add(_ownEntry(entries, ownFocusSeconds, ownLabel));
  }
  rankedEntries.sort((a, b) => b.focusSeconds.compareTo(a.focusSeconds));
  return rankedEntries;
}

int _rankOfCurrentUser(List<FriendsLeaderboardEntry> entries) {
  final index = entries.indexWhere((entry) => entry.isCurrentUser);
  return index == -1 ? entries.length + 1 : index + 1;
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
      animation: Listenable.merge([
        widget.historyController,
        widget.leaderboardController,
      ]),
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
                _FriendsLeaderboardCard(
                  entries: widget.leaderboardController.entries,
                  loading: widget.leaderboardController.loading,
                  ownFocusSeconds: widget.leaderboardController.ownFocusSeconds,
                  onPressed: () => _showLeaderboard(context),
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

  void _showLeaderboard(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FriendsLeaderboardSheet(
        entries: widget.leaderboardController.entries,
        ownFocusSeconds: widget.leaderboardController.ownFocusSeconds,
      ),
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
