abstract interface class TimerNotificationService {
  Future<void> initialize();

  Future<bool> permissionsGranted();

  Future<bool> requestPermissions();

  Future<void> schedule({
    required DateTime scheduledAt,
    required String title,
    required String body,
  });

  Future<void> cancel();
}
