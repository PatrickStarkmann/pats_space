import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsEventNames {
  const AnalyticsEventNames._();

  static const focusStarted = 'focus_started';
  static const focusCompleted = 'focus_completed';
  static const focusCancelled = 'focus_cancelled';
  static const socialFocusJoined = 'social_focus_joined';
  static const socialFocusLeft = 'social_focus_left';
  static const gardenItemUnlocked = 'garden_item_unlocked';
  static const acquisitionSourceSelected = 'acquisition_source_selected';
  static const rewardedWaterEarned = 'rewarded_water_earned';
  static const paywallOpened = 'paywall_opened';
  static const purchaseStarted = 'pro_purchase_started';
  static const purchaseCompleted = 'pro_purchase_completed';
  static const purchaseCancelled = 'pro_purchase_cancelled';
  static const purchaseFailed = 'pro_purchase_failed';
  static const purchasesRestored = 'pro_purchases_restored';
}

class AppAnalytics {
  AppAnalytics({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  static final instance = AppAnalytics();

  final FirebaseAnalytics _analytics;
  String? _lastScreenName;

  bool get isSupported =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.macOS => true,
        TargetPlatform.fuchsia ||
        TargetPlatform.linux ||
        TargetPlatform.windows => false,
      };

  Future<void> enableCollection() async {
    if (!isSupported) {
      return;
    }

    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  Future<void> logScreen(String name) async {
    if (!isSupported || _lastScreenName == name) {
      return;
    }

    _lastScreenName = name;
    await _analytics.logScreenView(screenName: name, screenClass: name);
  }

  Future<void> logFocusStarted({
    required String mode,
    required int plannedSeconds,
    required bool groupFocus,
  }) {
    return _logEvent(AnalyticsEventNames.focusStarted, {
      'mode': mode,
      'planned_seconds': plannedSeconds,
      'group_focus': groupFocus.toString(),
    });
  }

  Future<void> logFocusCompleted({
    required String mode,
    required int durationSeconds,
    required bool groupFocus,
  }) {
    return _logEvent(AnalyticsEventNames.focusCompleted, {
      'mode': mode,
      'duration_seconds': durationSeconds,
      'group_focus': groupFocus.toString(),
    });
  }

  Future<void> logFocusCancelled({
    required String mode,
    required int durationSeconds,
    required bool groupFocus,
  }) {
    return _logEvent(AnalyticsEventNames.focusCancelled, {
      'mode': mode,
      'duration_seconds': durationSeconds,
      'group_focus': groupFocus.toString(),
    });
  }

  Future<void> logSocialFocusJoined({required bool createdRoom}) {
    return _logEvent(AnalyticsEventNames.socialFocusJoined, {
      'created_room': createdRoom.toString(),
    });
  }

  Future<void> logSocialFocusLeft() {
    return _logEvent(AnalyticsEventNames.socialFocusLeft, const {});
  }

  Future<void> logGardenItemUnlocked({required String itemType}) {
    return _logEvent(AnalyticsEventNames.gardenItemUnlocked, {
      'item_type': itemType,
    });
  }

  Future<void> logAcquisitionSourceSelected({required String source}) {
    return _logEvent(AnalyticsEventNames.acquisitionSourceSelected, {
      'source': source,
    });
  }

  Future<void> logRewardedWaterEarned({required int amount}) {
    return _logEvent(AnalyticsEventNames.rewardedWaterEarned, {
      'amount': amount,
    });
  }

  Future<void> logPaywallOpened({required String source}) {
    return _logEvent(AnalyticsEventNames.paywallOpened, {'source': source});
  }

  Future<void> logProPurchaseStarted({required String packageType}) {
    return _logEvent(AnalyticsEventNames.purchaseStarted, {
      'package_type': packageType,
    });
  }

  Future<void> logProPurchaseCompleted({required String packageType}) {
    return _logEvent(AnalyticsEventNames.purchaseCompleted, {
      'package_type': packageType,
    });
  }

  Future<void> logProPurchaseCancelled({required String packageType}) {
    return _logEvent(AnalyticsEventNames.purchaseCancelled, {
      'package_type': packageType,
    });
  }

  Future<void> logProPurchaseFailed({required String packageType}) {
    return _logEvent(AnalyticsEventNames.purchaseFailed, {
      'package_type': packageType,
    });
  }

  Future<void> logProPurchasesRestored({required bool proActive}) {
    return _logEvent(AnalyticsEventNames.purchasesRestored, {
      'pro_active': proActive.toString(),
    });
  }

  Future<void> _logEvent(String name, Map<String, Object> parameters) async {
    if (!isSupported) {
      return;
    }

    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
