import 'package:flutter/foundation.dart';
import 'package:pats_space/features/notifications/models/notification_settings.dart';
import 'package:pats_space/features/notifications/models/timer_notification_kind.dart';
import 'package:pats_space/features/notifications/models/timer_notification_request.dart';
import 'package:pats_space/features/notifications/repositories/notification_settings_repository.dart';
import 'package:pats_space/features/notifications/services/timer_notification_service.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({
    required NotificationSettings initialSettings,
    required NotificationSettingsRepository repository,
    required TimerNotificationService service,
  }) : _settings = initialSettings,
       _repository = repository,
       _service = service;

  final NotificationSettingsRepository _repository;
  final TimerNotificationService _service;

  NotificationSettings _settings;
  bool _permissionGranted = false;
  bool _appForeground = true;
  bool _permissionDenied = false;
  List<TimerNotificationRequest> _scheduledNotifications = const [];
  Future<void> _timerNotificationQueue = Future.value();

  static const _notificationIdStart = 41001;
  static const _notificationIdCount = 24;

  NotificationSettings get settings => _settings;
  bool get enabled => _settings.enabled && _permissionGranted;
  bool get focusEndEnabled => _settings.focusEndEnabled;
  bool get breakEndEnabled => _settings.breakEndEnabled;
  bool get permissionDenied => _permissionDenied;

  Future<void> initialize() async {
    try {
      await _service.initialize();
      _permissionGranted = await _service.permissionsGranted();
      await cancelTimerNotification(force: true);
    } catch (_) {
      _permissionGranted = false;
    }
  }

  Future<void> setEnabled(bool value) async {
    _permissionDenied = false;
    if (value) {
      try {
        _permissionGranted = await _service.requestPermissions();
      } catch (_) {
        _permissionGranted = false;
      }
      if (!_permissionGranted) {
        _permissionDenied = true;
        _settings = _settings.copyWith(enabled: false);
        notifyListeners();
        await _saveSettings();
        return;
      }
    }

    _settings = _settings.copyWith(enabled: value);
    notifyListeners();
    await _saveSettings();
    if (!value) {
      await cancelTimerNotification();
    }
  }

  Future<void> setFocusEndEnabled(bool value) async {
    if (_settings.focusEndEnabled == value) {
      return;
    }
    _settings = _settings.copyWith(focusEndEnabled: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setBreakEndEnabled(bool value) async {
    if (_settings.breakEndEnabled == value) {
      return;
    }
    _settings = _settings.copyWith(breakEndEnabled: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setAppForeground(bool foreground) async {
    if (_appForeground == foreground) {
      return;
    }
    _appForeground = foreground;
    if (foreground) {
      await cancelTimerNotification();
    }
  }

  Future<void> syncTimerNotification({
    required TimerNotificationKind? kind,
    required Duration remaining,
    required String title,
    required String body,
  }) async {
    if (kind == null) {
      await syncTimerNotifications(const []);
      return;
    }
    await syncTimerNotifications([
      TimerNotificationRequest(
        kind: kind,
        scheduledAt: DateTime.now().add(remaining),
        title: title,
        body: body,
      ),
    ]);
  }

  Future<void> syncTimerNotifications(List<TimerNotificationRequest> requests) {
    // Calls originate from lifecycle callbacks and timer updates. Keep them in
    // order so an older schedule request can never finish after a newer cancel.
    final requestSnapshot = List<TimerNotificationRequest>.unmodifiable(
      requests,
    );
    return _enqueueTimerNotificationOperation(() async {
      await _syncTimerNotifications(requestSnapshot);
    });
  }

  Future<void> _syncTimerNotifications(
    List<TimerNotificationRequest> requests,
  ) async {
    final enabledRequests = requests
        .where((request) {
          return switch (request.kind) {
            TimerNotificationKind.focusEnd => focusEndEnabled,
            TimerNotificationKind.breakEnd ||
            TimerNotificationKind.roundEnd => breakEndEnabled,
          };
        })
        .toList(growable: false);
    if (!enabled || _appForeground || enabledRequests.isEmpty) {
      await _cancelTimerNotification();
      return;
    }
    if (_sameRequests(_scheduledNotifications, enabledRequests)) {
      return;
    }
    try {
      await _service.cancel(_notificationIds);
      for (var index = 0; index < enabledRequests.length; index += 1) {
        final request = enabledRequests[index];
        await _service.schedule(
          id: _notificationIdStart + index,
          scheduledAt: request.scheduledAt,
          title: request.title,
          body: request.body,
        );
      }
      _scheduledNotifications = enabledRequests;
    } catch (_) {
      _scheduledNotifications = const [];
    }
  }

  Future<void> cancelTimerNotification({bool force = false}) {
    return _enqueueTimerNotificationOperation(() async {
      await _cancelTimerNotification(force: force);
    });
  }

  Future<void> _cancelTimerNotification({bool force = false}) async {
    if (_scheduledNotifications.isEmpty && !force) {
      return;
    }
    _scheduledNotifications = const [];
    try {
      await _service.cancel(_notificationIds);
    } catch (_) {
      // Notification failures must not affect an active focus session.
    }
  }

  Future<void> _enqueueTimerNotificationOperation(
    Future<void> Function() operation,
  ) {
    final queuedOperation = _timerNotificationQueue.then((_) => operation());
    _timerNotificationQueue = queuedOperation.catchError((_) {});
    return queuedOperation;
  }

  Iterable<int> get _notificationIds => Iterable<int>.generate(
    _notificationIdCount,
    (index) => _notificationIdStart + index,
  );

  bool _sameRequests(
    List<TimerNotificationRequest> first,
    List<TimerNotificationRequest> second,
  ) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index += 1) {
      if (!first[index].matches(second[index])) return false;
    }
    return true;
  }

  Future<void> _saveSettings() async {
    try {
      await _repository.saveSettings(_settings);
    } catch (_) {
      // A local preference failure should not interrupt the settings UI.
    }
  }
}
