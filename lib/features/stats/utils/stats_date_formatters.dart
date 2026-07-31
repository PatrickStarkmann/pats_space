import 'package:pats_space/features/settings/models/week_start_day.dart';
import 'package:pats_space/features/stats/utils/stats_aggregations.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

String formatMonthTitle(DateTime month) {
  return '${month.year} / ${month.month.toString().padLeft(2, '0')}';
}

String formatMonthShortTitle(DateTime month, AppLocalizations l10n) {
  return '${_monthName(month.month, l10n)} ${month.year}';
}

String formatWeekRange(
  DateTime date,
  AppLocalizations l10n,
  WeekStartDay weekStartDay,
) {
  final firstDayOfWeek = startOfWeek(date, weekStartDay);
  final endOfWeek = firstDayOfWeek.add(const Duration(days: 6));
  if (firstDayOfWeek.month == endOfWeek.month) {
    return '${_monthName(firstDayOfWeek.month, l10n)} ${firstDayOfWeek.day} - ${endOfWeek.day}';
  }

  return '${_monthName(firstDayOfWeek.month, l10n)} ${firstDayOfWeek.day} - ${_monthName(endOfWeek.month, l10n)} ${endOfWeek.day}';
}

String formatDuration(Duration duration) {
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

String _monthName(int month, AppLocalizations l10n) {
  return switch (month) {
    1 => l10n.monthJan,
    2 => l10n.monthFeb,
    3 => l10n.monthMar,
    4 => l10n.monthApr,
    5 => l10n.monthMay,
    6 => l10n.monthJun,
    7 => l10n.monthJul,
    8 => l10n.monthAug,
    9 => l10n.monthSep,
    10 => l10n.monthOct,
    11 => l10n.monthNov,
    12 => l10n.monthDec,
    _ => '',
  };
}
