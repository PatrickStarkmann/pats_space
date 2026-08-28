import 'dart:io';

import 'package:flutter/foundation.dart';

class AdsConfig {
  const AdsConfig._();

  static const rewardedWaterAmount = 2;
  static const maxRewardedAdsPerDay = 3;

  static const _androidTestRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const _iosTestRewardedAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';

  // Debug builds always use Google's official test units. Production IDs are
  // safe to keep here; they identify the ad placement, not an account secret.
  static const _androidProductionRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_AD_UNIT_ID',
  );
  static const _iosProductionRewardedAdUnitId =
      'ca-app-pub-6349447773462495/8092912273';

  static bool get usingTestAdUnits => kDebugMode;

  static String get rewardedWaterAdUnitId {
    if (Platform.isAndroid) {
      return usingTestAdUnits
          ? _androidTestRewardedAdUnitId
          : _androidProductionRewardedAdUnitId;
    }
    if (Platform.isIOS) {
      return usingTestAdUnits
          ? _iosTestRewardedAdUnitId
          : _iosProductionRewardedAdUnitId;
    }
    return '';
  }

  static bool get hasProductionRewardedWaterAdUnit =>
      rewardedWaterAdUnitId.isNotEmpty;
}
