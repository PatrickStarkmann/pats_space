import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/notifications/controllers/notification_controller.dart';
import 'package:pats_space/features/notifications/models/notification_settings.dart';
import 'package:pats_space/features/notifications/models/timer_notification_kind.dart';
import 'package:pats_space/features/notifications/models/timer_notification_request.dart';
import 'package:pats_space/features/notifications/repositories/notification_settings_repository.dart';
import 'package:pats_space/features/notifications/services/timer_notification_service.dart';

void main() {
  group('NotificationController', () {
    late _MemoryNotificationSettingsRepository repository;
    late _FakeTimerNotificationService service;

    NotificationController createController({
      NotificationSettings settings = const NotificationSettings(),
    }) {
      return NotificationController(
        initialSettings: settings,
        repository: repository,
        service: service,
      );
    }

    setUp(() {
      repository = _MemoryNotificationSettingsRepository();
      service = _FakeTimerNotificationService();
    });

    test('requests permission when timer notifications are enabled', () async {
      final controller = createController();
      addTearDown(controller.dispose);
      await controller.initialize();

      await controller.setEnabled(true);

      expect(service.permissionRequestCount, 1);
      expect(controller.enabled, isTrue);
      expect(repository.savedSettings.last.enabled, isTrue);
    });

    test('keeps notifications disabled when permission is denied', () async {
      service.permissionRequestResult = false;
      final controller = createController();
      addTearDown(controller.dispose);
      await controller.initialize();

      await controller.setEnabled(true);

      expect(controller.enabled, isFalse);
      expect(controller.permissionDenied, isTrue);
      expect(repository.savedSettings.last.enabled, isFalse);
    });

    test('schedules only while the app is in the background', () async {
      service.permissionsGrantedResult = true;
      final controller = createController(
        settings: const NotificationSettings(enabled: true),
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      await controller.syncTimerNotification(
        kind: TimerNotificationKind.focusEnd,
        remaining: const Duration(minutes: 5),
        title: 'Focus complete',
        body: 'Take a break',
      );
      expect(service.scheduled, isEmpty);

      await controller.setAppForeground(false);
      await controller.syncTimerNotification(
        kind: TimerNotificationKind.focusEnd,
        remaining: const Duration(minutes: 5),
        title: 'Focus complete',
        body: 'Take a break',
      );

      expect(service.scheduled, hasLength(1));
    });

    test('does not reschedule the same ticking timer', () async {
      service.permissionsGrantedResult = true;
      final controller = createController(
        settings: const NotificationSettings(enabled: true),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.setAppForeground(false);

      await controller.syncTimerNotification(
        kind: TimerNotificationKind.breakEnd,
        remaining: const Duration(seconds: 60),
        title: 'Break complete',
        body: 'Focus again',
      );
      await controller.syncTimerNotification(
        kind: TimerNotificationKind.breakEnd,
        remaining: const Duration(seconds: 59),
        title: 'Break complete',
        body: 'Focus again',
      );

      expect(service.scheduled, hasLength(1));
    });

    test('schedules each future transition while auto continue is active', () async {
      service.permissionsGrantedResult = true;
      final controller = createController(
        settings: const NotificationSettings(enabled: true),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.setAppForeground(false);
      final now = DateTime.now();

      await controller.syncTimerNotifications([
        TimerNotificationRequest(
          kind: TimerNotificationKind.focusEnd,
          scheduledAt: now.add(const Duration(seconds: 30)),
          title: 'Focus complete',
          body: 'Take a break',
        ),
        TimerNotificationRequest(
          kind: TimerNotificationKind.breakEnd,
          scheduledAt: now.add(const Duration(seconds: 60)),
          title: 'Break complete',
          body: 'Focus again',
        ),
      ]);

      expect(service.scheduled, hasLength(2));
    });

    test('cancels a pending notification when foregrounded', () async {
      service.permissionsGrantedResult = true;
      final controller = createController(
        settings: const NotificationSettings(enabled: true),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.setAppForeground(false);
      await controller.syncTimerNotification(
        kind: TimerNotificationKind.roundEnd,
        remaining: const Duration(minutes: 1),
        title: 'Round complete',
        body: 'Well done',
      );

      await controller.setAppForeground(true);

      expect(service.cancelCount, 3);
    });

    test('respects individual focus notification setting', () async {
      service.permissionsGrantedResult = true;
      final controller = createController(
        settings: const NotificationSettings(
          enabled: true,
          focusEndEnabled: false,
        ),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.setAppForeground(false);

      await controller.syncTimerNotification(
        kind: TimerNotificationKind.focusEnd,
        remaining: const Duration(minutes: 5),
        title: 'Focus complete',
        body: 'Take a break',
      );

      expect(service.scheduled, isEmpty);
    });
  });
}

class _MemoryNotificationSettingsRepository
    implements NotificationSettingsRepository {
  final List<NotificationSettings> savedSettings = [];

  @override
  Future<NotificationSettings> loadSettings() async {
    return const NotificationSettings();
  }

  @override
  Future<void> saveSettings(NotificationSettings settings) async {
    savedSettings.add(settings);
  }
}

class _FakeTimerNotificationService implements TimerNotificationService {
  bool permissionsGrantedResult = false;
  bool permissionRequestResult = true;
  int permissionRequestCount = 0;
  int cancelCount = 0;
  final List<({DateTime scheduledAt, String title, String body})> scheduled =
      [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> permissionsGranted() async => permissionsGrantedResult;

  @override
  Future<bool> requestPermissions() async {
    permissionRequestCount += 1;
    return permissionRequestResult;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    scheduled.add((scheduledAt: scheduledAt, title: title, body: body));
  }

  @override
  Future<void> cancel(Iterable<int> ids) async {
    cancelCount += 1;
  }
}
