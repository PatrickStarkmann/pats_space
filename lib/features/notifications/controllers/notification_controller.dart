import 'package:flutter/foundation.dart';
import 'package:pats_space/features/notifications/models/notification_settings.dart';
import 'package:pats_space/features/notifications/models/timer_notification_kind.dart';
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
  _ScheduledTimerNotification? _scheduledNotification;

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
    final eventEnabled = switch (kind) {
      TimerNotificationKind.focusEnd => focusEndEnabled,
      TimerNotificationKind.breakEnd ||
      TimerNotificationKind.roundEnd => breakEndEnabled,
      null => false,
    };
    if (!enabled ||
        _appForeground ||
        !eventEnabled ||
        remaining <= Duration.zero) {
      await cancelTimerNotification();
      return;
    }

    final scheduledAt = DateTime.now().add(remaining);
    final next = _ScheduledTimerNotification(
      kind: kind!,
      scheduledAt: scheduledAt,
      title: title,
      body: body,
    );
    final current = _scheduledNotification;
    if (current != null && current.matches(next)) {
      return;
    }

    _scheduledNotification = next;
    try {
      await _service.schedule(
        scheduledAt: scheduledAt,
        title: title,
        body: body,
      );
    } catch (_) {
      if (_scheduledNotification == next) {
        _scheduledNotification = null;
      }
    }
  }

  Future<void> cancelTimerNotification({bool force = false}) async {
    if (_scheduledNotification == null && !force) {
      return;
    }
    _scheduledNotification = null;
    try {
      await _service.cancel();
    } catch (_) {
      // Notification failures must not affect an active focus session.
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _repository.saveSettings(_settings);
    } catch (_) {
      // A local preference failure should not interrupt the settings UI.
    }
  }
}

class _ScheduledTimerNotification {
  const _ScheduledTimerNotification({
    required this.kind,
    required this.scheduledAt,
    required this.title,
    required this.body,
  });

  final TimerNotificationKind kind;
  final DateTime scheduledAt;
  final String title;
  final String body;

  bool matches(_ScheduledTimerNotification other) {
    return kind == other.kind &&
        title == other.title &&
        body == other.body &&
        scheduledAt.difference(other.scheduledAt).abs() <
            const Duration(seconds: 2);
  }
}
