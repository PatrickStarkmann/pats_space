import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Coordinates the optional Patsspace rating prompts after positive milestones.
/// Apple's native prompt remains system-controlled and may not be displayed.
class AppRatingService {
  AppRatingService({
    Future<SharedPreferences>? preferences,
    AppReviewRequester? requester,
    DateTime Function()? now,
  }) : _preferences = preferences ?? SharedPreferences.getInstance(),
       _requester = requester ?? const _InAppReviewRequester(),
       _now = now ?? DateTime.now;

  static const _iosAppStoreId = '6806823049';

  static const _customFocusSessionsKey = 'app_rating_custom_focus_sessions_v1';
  static const _nativeFocusSessionsKey = 'app_rating_native_focus_sessions_v1';
  static const _customBloomsKey = 'app_rating_custom_blooms_v1';
  static const _nativeBloomsKey = 'app_rating_native_blooms_v1';
  static const _customLastPromptAtKey = 'app_rating_custom_last_prompt_at_v1';
  static const _nativeLastPromptAtKey = 'app_rating_native_last_prompt_at_v1';

  static const _customMinimumFocusSessions = 2;
  static const _nativeMinimumFocusSessions = 3;
  static const _minimumCompletedBlooms = 2;
  static const _cooldown = Duration(days: 14);

  final Future<SharedPreferences> _preferences;
  final AppReviewRequester _requester;
  final DateTime Function() _now;

  Future<bool> shouldShowCustomPromptAfterFocusSession() async {
    final preferences = await _preferences;
    await _increment(preferences, _customFocusSessionsKey);
    return _shouldShowCustomPrompt(preferences);
  }

  Future<bool> shouldShowCustomPromptAfterBloom(int totalBlooms) async {
    final preferences = await _preferences;
    await _storeHighestBloomCount(
      preferences,
      key: _customBloomsKey,
      totalBlooms: totalBlooms,
    );
    return _shouldShowCustomPrompt(preferences);
  }

  Future<void> maybeRequestNativeReviewAfterFocusSession({
    bool suppressPrompt = false,
  }) async {
    final preferences = await _preferences;
    await _increment(preferences, _nativeFocusSessionsKey);
    await _maybeRequestNativeReview(
      preferences,
      suppressPrompt: suppressPrompt,
    );
  }

  Future<void> maybeRequestNativeReviewAfterBloom(
    int totalBlooms, {
    bool suppressPrompt = false,
  }) async {
    final preferences = await _preferences;
    await _storeHighestBloomCount(
      preferences,
      key: _nativeBloomsKey,
      totalBlooms: totalBlooms,
    );
    await _maybeRequestNativeReview(
      preferences,
      suppressPrompt: suppressPrompt,
    );
  }

  Future<bool> openStoreReviewPage() async {
    try {
      await _requester.openStoreListing(appStoreId: _iosAppStoreId);
      return true;
    } catch (error) {
      debugPrint('APP_RATING openStoreListing skipped -> $error');
      return false;
    }
  }

  Future<void> _increment(SharedPreferences preferences, String key) async {
    await preferences.setInt(key, (preferences.getInt(key) ?? 0) + 1);
  }

  Future<void> _storeHighestBloomCount(
    SharedPreferences preferences, {
    required String key,
    required int totalBlooms,
  }) async {
    if (totalBlooms <= (preferences.getInt(key) ?? 0)) {
      return;
    }
    await preferences.setInt(key, totalBlooms);
  }

  Future<bool> _shouldShowCustomPrompt(SharedPreferences preferences) async {
    if (!_hasReachedCustomMilestone(preferences) ||
        !_isCooldownComplete(preferences, _customLastPromptAtKey)) {
      return false;
    }
    await preferences.setInt(
      _customLastPromptAtKey,
      _now().millisecondsSinceEpoch,
    );
    return true;
  }

  Future<void> _maybeRequestNativeReview(
    SharedPreferences preferences, {
    required bool suppressPrompt,
  }) async {
    if (suppressPrompt ||
        !_hasReachedNativeMilestone(preferences) ||
        !_isCooldownComplete(preferences, _nativeLastPromptAtKey)) {
      return;
    }
    try {
      if (!await _requester.isAvailable()) {
        return;
      }
      await preferences.setInt(
        _nativeLastPromptAtKey,
        _now().millisecondsSinceEpoch,
      );
      await _requester.requestReview();
    } catch (error) {
      debugPrint('APP_RATING requestReview skipped -> $error');
    }
  }

  bool _hasReachedCustomMilestone(SharedPreferences preferences) {
    return (preferences.getInt(_customFocusSessionsKey) ?? 0) >=
            _customMinimumFocusSessions ||
        (preferences.getInt(_customBloomsKey) ?? 0) >= _minimumCompletedBlooms;
  }

  bool _hasReachedNativeMilestone(SharedPreferences preferences) {
    return (preferences.getInt(_nativeFocusSessionsKey) ?? 0) >=
            _nativeMinimumFocusSessions ||
        (preferences.getInt(_nativeBloomsKey) ?? 0) >= _minimumCompletedBlooms;
  }

  bool _isCooldownComplete(SharedPreferences preferences, String key) {
    final lastPromptAt = preferences.getInt(key);
    return lastPromptAt == null ||
        _now().difference(DateTime.fromMillisecondsSinceEpoch(lastPromptAt)) >=
            _cooldown;
  }
}

abstract interface class AppReviewRequester {
  Future<bool> isAvailable();
  Future<void> requestReview();
  Future<void> openStoreListing({required String appStoreId});
}

class _InAppReviewRequester implements AppReviewRequester {
  const _InAppReviewRequester();

  @override
  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  @override
  Future<void> requestReview() => InAppReview.instance.requestReview();

  @override
  Future<void> openStoreListing({required String appStoreId}) =>
      InAppReview.instance.openStoreListing(appStoreId: appStoreId);
}
