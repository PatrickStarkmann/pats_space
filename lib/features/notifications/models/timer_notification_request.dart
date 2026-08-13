import 'package:pats_space/features/notifications/models/timer_notification_kind.dart';

class TimerNotificationRequest {
  const TimerNotificationRequest({
    required this.kind,
    required this.scheduledAt,
    required this.title,
    required this.body,
  });

  final TimerNotificationKind kind;
  final DateTime scheduledAt;
  final String title;
  final String body;

  bool matches(TimerNotificationRequest other) =>
      kind == other.kind &&
      title == other.title &&
      body == other.body &&
      scheduledAt.difference(other.scheduledAt).abs() <
          const Duration(seconds: 2);
}
