import 'package:flutter/foundation.dart';
import 'package:pats_space/features/focus_blocking/models/focus_blocking_status.dart';
import 'package:pats_space/features/focus_blocking/services/focus_blocking_platform_service.dart';

class FocusBlockingController extends ChangeNotifier {
  FocusBlockingController({
    FocusBlockingPlatformService service = const FocusBlockingPlatformService(),
  }) : _service = service;

  final FocusBlockingPlatformService _service;

  FocusBlockingStatus _status = const FocusBlockingStatus.initial();
  bool _isBusy = false;
  String? _lastErrorCode;

  FocusBlockingStatus get status => _status;
  bool get isBusy => _isBusy;
  String? get lastErrorCode => _lastErrorCode;

  Future<void> initialize({required String languageCode}) async {
    await _run(() async {
      await _service.setLanguage(languageCode);
      _status = await _service.recover();
      // Timer state is intentionally not restored across a Flutter restart.
      // Clear a native shield that belongs to an abandoned in-memory session.
      if (_status.isActive) {
        _status = await _service.endSession();
      }
    });
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      await _service.setLanguage(languageCode);
    } on FocusBlockingPlatformException catch (error) {
      _lastErrorCode = error.code;
      notifyListeners();
    }
  }

  Future<void> refresh() => _run(() async {
    _status = await _service.status();
  });

  Future<bool> prepare() async {
    await _run(() async {
      var current = await _service.requestAuthorization();
      if (current.authorization == FocusBlockingAuthorization.approved &&
          !current.hasSelection) {
        current = await _service.configureSelection();
      }
      _status = current;
    });
    return _status.isReady;
  }

  Future<bool> configureSelection() async {
    await _run(() async {
      var current = _status;
      if (current.authorization != FocusBlockingAuthorization.approved) {
        current = await _service.requestAuthorization();
      }
      if (current.authorization == FocusBlockingAuthorization.approved) {
        current = await _service.configureSelection();
      }
      _status = current;
    });
    return _status.isReady;
  }

  Future<bool> startSession({DateTime? expectedEnd}) async {
    if (!_status.isReady && !await prepare()) {
      return false;
    }

    await _run(() async {
      _status = await _service.startSession(expectedEnd: expectedEnd);
    });
    return _status.isActive;
  }

  Future<void> endSession() => _run(() async {
    _status = await _service.endSession();
  });

  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) {
      return;
    }

    _isBusy = true;
    _lastErrorCode = null;
    notifyListeners();
    try {
      await action();
    } on FocusBlockingPlatformException catch (error) {
      _lastErrorCode = error.code;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
