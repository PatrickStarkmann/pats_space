import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/focus_blocking/controllers/focus_blocking_controller.dart';
import 'package:pats_space/features/focus_blocking/models/focus_blocking_status.dart';
import 'package:pats_space/features/focus_blocking/services/focus_blocking_platform_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const unprepared = FocusBlockingStatus(
    platform: FocusBlockingPlatform.ios,
    authorization: FocusBlockingAuthorization.notDetermined,
    hasSelection: false,
    isActive: false,
    selectionCount: 0,
  );
  const authorized = FocusBlockingStatus(
    platform: FocusBlockingPlatform.ios,
    authorization: FocusBlockingAuthorization.approved,
    hasSelection: false,
    isActive: false,
    selectionCount: 0,
  );
  const ready = FocusBlockingStatus(
    platform: FocusBlockingPlatform.ios,
    authorization: FocusBlockingAuthorization.approved,
    hasSelection: true,
    isActive: false,
    selectionCount: 4,
  );
  const active = FocusBlockingStatus(
    platform: FocusBlockingPlatform.ios,
    authorization: FocusBlockingAuthorization.approved,
    hasSelection: true,
    isActive: true,
    selectionCount: 4,
  );

  test('prepare requests authorization and selection', () async {
    final service = _FakeFocusBlockingService(
      statusValue: unprepared,
      authorizationValue: authorized,
      selectionValue: ready,
      activeValue: active,
    );
    final controller = FocusBlockingController(service: service);
    addTearDown(controller.dispose);

    expect(await controller.prepare(), isTrue);
    expect(service.authorizationRequests, 1);
    expect(service.selectionRequests, 1);
    expect(controller.status, same(ready));
  });

  test(
    'initialize clears an active native session from a prior restart',
    () async {
      final service = _FakeFocusBlockingService(
        statusValue: active,
        authorizationValue: authorized,
        selectionValue: ready,
        activeValue: active,
      );
      final controller = FocusBlockingController(service: service);
      addTearDown(controller.dispose);

      await controller.initialize(languageCode: 'de');

      expect(service.endSessionRequests, 1);
      expect(controller.status.isActive, isFalse);
    },
  );

  test('start passes the expected end and activates blocking', () async {
    final expectedEnd = DateTime(2026, 8, 1, 12);
    final service = _FakeFocusBlockingService(
      statusValue: ready,
      authorizationValue: ready,
      selectionValue: ready,
      activeValue: active,
    );
    final controller = FocusBlockingController(service: service);
    addTearDown(controller.dispose);
    await controller.refresh();

    expect(await controller.startSession(expectedEnd: expectedEnd), isTrue);
    expect(service.startedWith, expectedEnd);
    expect(controller.status.isActive, isTrue);
  });

  test('platform errors are exposed without activating the session', () async {
    final service = _FakeFocusBlockingService(
      statusValue: ready,
      authorizationValue: ready,
      selectionValue: ready,
      activeValue: active,
      startError: const FocusBlockingPlatformException('start_failed'),
    );
    final controller = FocusBlockingController(service: service);
    addTearDown(controller.dispose);
    await controller.refresh();

    expect(await controller.startSession(), isFalse);
    expect(controller.lastErrorCode, 'start_failed');
  });
}

class _FakeFocusBlockingService extends FocusBlockingPlatformService {
  _FakeFocusBlockingService({
    required this.statusValue,
    required this.authorizationValue,
    required this.selectionValue,
    required this.activeValue,
    this.startError,
  });

  final FocusBlockingStatus statusValue;
  final FocusBlockingStatus authorizationValue;
  final FocusBlockingStatus selectionValue;
  final FocusBlockingStatus activeValue;
  final FocusBlockingPlatformException? startError;

  int authorizationRequests = 0;
  int selectionRequests = 0;
  int endSessionRequests = 0;
  DateTime? startedWith;

  @override
  Future<FocusBlockingStatus> status() async => statusValue;

  @override
  Future<FocusBlockingStatus> recover() async => statusValue;

  @override
  Future<FocusBlockingStatus> endSession() async {
    endSessionRequests += 1;
    return FocusBlockingStatus(
      platform: statusValue.platform,
      authorization: statusValue.authorization,
      hasSelection: statusValue.hasSelection,
      isActive: false,
      selectionCount: statusValue.selectionCount,
    );
  }

  @override
  Future<FocusBlockingStatus> requestAuthorization() async {
    authorizationRequests += 1;
    return authorizationValue;
  }

  @override
  Future<FocusBlockingStatus> configureSelection() async {
    selectionRequests += 1;
    return selectionValue;
  }

  @override
  Future<FocusBlockingStatus> startSession({DateTime? expectedEnd}) async {
    if (startError case final error?) {
      throw error;
    }
    startedWith = expectedEnd;
    return activeValue;
  }
}
