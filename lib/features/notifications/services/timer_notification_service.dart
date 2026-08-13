abstract interface class TimerNotificationService {
  Future<void> initialize();

  Future<bool> permissionsGranted();

  Future<bool> requestPermissions();

  Future<void> schedule({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
  });

  Future<void> cancel(Iterable<int> ids);
}
