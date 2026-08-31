import 'package:flutter/foundation.dart';

/// Store credentials are public SDK keys.
///
/// The Test Store key is intentionally a debug-only fallback so a normal IDE
/// run can exercise purchases before the App Store products exist. A profile
/// or release build can never use it; those builds require a platform key.
class ProConfig {
  const ProConfig._();

  /// Must match the active RevenueCat entitlement identifier exactly.
  static const entitlementId = 'patsspace_pro';
  static const defaultOfferingId = 'default';

  static const _iosApiKey = String.fromEnvironment('REVENUECAT_IOS_API_KEY');
  static const _androidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
  );
  static const _testStoreApiKey = String.fromEnvironment(
    'REVENUECAT_TESTSTORE_API_KEY',
    defaultValue: 'test_xsaaokDtoURpwcqjZyfLNeHRjHS',
  );

  /// Test Store can only ever be selected in a debug build. Release and
  /// TestFlight builds always use the platform-specific production key.
  static bool get isUsingTestStore =>
      kDebugMode && _platformApiKey.isEmpty && _testStoreApiKey.isNotEmpty;

  static String get apiKey {
    if (_platformApiKey.isNotEmpty) {
      return _platformApiKey;
    }
    return isUsingTestStore ? _testStoreApiKey : '';
  }

  static String get _platformApiKey => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => _iosApiKey,
    TargetPlatform.android => _androidApiKey,
    _ => '',
  };

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
}
