import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pats_space/features/focus_blocking/models/focus_blocking_status.dart';

class FocusBlockingPlatformException implements Exception {
  const FocusBlockingPlatformException(this.code, [this.message]);

  final String code;
  final String? message;

  @override
  String toString() => message ?? code;
}

class FocusBlockingPlatformService {
  const FocusBlockingPlatformService();

  static const _channel = MethodChannel('pats_space/focus_blocking');

  Future<FocusBlockingStatus> status() => _statusMethod('status');

  Future<FocusBlockingStatus> recover() => _statusMethod('recover');

  Future<FocusBlockingStatus> requestAuthorization() =>
      _statusMethod('requestAuthorization');

  Future<FocusBlockingStatus> configureSelection() =>
      _statusMethod('configureSelection');

  Future<FocusBlockingStatus> startSession({DateTime? expectedEnd}) {
    return _statusMethod(
      'startSession',
      arguments: {
        if (expectedEnd != null)
          'expectedEndMilliseconds': expectedEnd.millisecondsSinceEpoch,
      },
    );
  }

  Future<FocusBlockingStatus> endSession() => _statusMethod('endSession');

  Future<void> setLanguage(String languageCode) async {
    if (!_supportsNativeChannel) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('setLanguage', {
        'languageCode': languageCode,
      });
    } on MissingPluginException {
      return;
    } on PlatformException catch (error) {
      throw FocusBlockingPlatformException(error.code, error.message);
    }
  }

  Future<FocusBlockingStatus> _statusMethod(
    String method, {
    Map<String, Object>? arguments,
  }) async {
    if (!_supportsNativeChannel) {
      return FocusBlockingStatus(
        platform: defaultTargetPlatform == TargetPlatform.android
            ? FocusBlockingPlatform.android
            : FocusBlockingPlatform.unsupported,
        authorization: FocusBlockingAuthorization.unknown,
        hasSelection: false,
        isActive: false,
        selectionCount: 0,
      );
    }

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        method,
        arguments,
      );
      return FocusBlockingStatus.fromMap(result);
    } on MissingPluginException {
      return const FocusBlockingStatus.initial();
    } on PlatformException catch (error) {
      throw FocusBlockingPlatformException(error.code, error.message);
    }
  }

  bool get _supportsNativeChannel =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
}
