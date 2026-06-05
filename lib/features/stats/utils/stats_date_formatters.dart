String formatMonthTitle(DateTime month) {
  return '${month.year} / ${month.month.toString().padLeft(2, '0')}';
}

String formatMonthShortTitle(DateTime month) {
  return '${_monthNames[month.month - 1]} ${month.year}';
}

String formatWeekRange(DateTime date) {
  final startOfWeek = DateTime(
    date.year,
    date.month,
    date.day - (date.weekday - 1),
  );
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  if (startOfWeek.month == endOfWeek.month) {
    return '${_monthNames[startOfWeek.month - 1]}, ${startOfWeek.day} - ${endOfWeek.day}';
  }

  return '${_monthNames[startOfWeek.month - 1]} ${startOfWeek.day} - ${_monthNames[endOfWeek.month - 1]} ${endOfWeek.day}';
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

const _monthNames = [
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
