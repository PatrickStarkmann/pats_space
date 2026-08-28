import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pats_space/core/analytics/app_analytics.dart';
import 'package:pats_space/features/ads/services/ads_config.dart';
import 'package:pats_space/features/ads/services/ads_consent_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RewardedWaterClaimResult { earned, unavailable, dailyLimitReached }

class RewardedWaterController extends ChangeNotifier {
  RewardedWaterController({
    required SharedPreferences preferences,
    required String userId,
    AdsConsentService? consentService,
  }) : _preferences = preferences,
       _userId = userId,
       _consentService = consentService ?? AdsConsentService();

  static const _dayKey = 'rewarded_water.day.v1';
  static const _countKey = 'rewarded_water.count.v1';

  final SharedPreferences _preferences;
  final String _userId;
  final AdsConsentService _consentService;
  RewardedAd? _rewardedAd;
  bool _initialized = false;
  bool _initializing = false;
  bool _loadingAd = false;
  Completer<bool>? _loadCompleter;
  Timer? _retryTimer;
  int _loadFailureCount = 0;
  int _claimsToday = 0;

  bool get isInitialized => _initialized;
  bool get isLoadingAd => _loadingAd;
  bool get isReady => _rewardedAd != null;
  bool get isPrivacyOptionsRequired => _consentService.isPrivacyOptionsRequired;
  bool get hasReachedDailyLimit =>
      _claimsToday >= AdsConfig.maxRewardedAdsPerDay;
  int get remainingClaimsToday =>
      (AdsConfig.maxRewardedAdsPerDay - _claimsToday).clamp(
        0,
        AdsConfig.maxRewardedAdsPerDay,
      );

  Future<void> initialize() async {
    if (_initialized || _initializing) {
      return;
    }
    _initializing = true;
    try {
      await _syncDailyLimit();
      await _consentService.initialize();
      if (_canLoadAds && !hasReachedDailyLimit) {
        await MobileAds.instance.initialize();
        unawaited(_loadRewardedAd());
      }
    } catch (error) {
      debugPrint('Rewarded water initialization failed: $error');
    } finally {
      _initializing = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<RewardedWaterClaimResult> claimWater() async {
    await initialize();
    await _syncDailyLimit();
    if (hasReachedDailyLimit) {
      notifyListeners();
      return RewardedWaterClaimResult.dailyLimitReached;
    }

    if (!_canLoadAds) {
      return RewardedWaterClaimResult.unavailable;
    }

    if (_rewardedAd == null) {
      final loaded = await _loadRewardedAd();
      if (!loaded || _rewardedAd == null) {
        return RewardedWaterClaimResult.unavailable;
      }
    }

    final completer = Completer<RewardedWaterClaimResult>();
    var rewardEarned = false;
    final ad = _rewardedAd!;
    _rewardedAd = null;
    notifyListeners();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(
            rewardEarned
                ? RewardedWaterClaimResult.earned
                : RewardedWaterClaimResult.unavailable,
          );
        }
        unawaited(_loadRewardedAd());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded water ad failed to show: $error');
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(RewardedWaterClaimResult.unavailable);
        }
        unawaited(_loadRewardedAd());
      },
    );
    ad.setImmersiveMode(true);
    ad.show(
      onUserEarnedReward: (ad, reward) async {
        rewardEarned = true;
        await _recordClaim();
        unawaited(
          AppAnalytics.instance.logRewardedWaterEarned(
            amount: AdsConfig.rewardedWaterAmount,
          ),
        );
      },
    );
    return completer.future;
  }

  Future<bool> showPrivacyOptions() async {
    final shown = await _consentService.showPrivacyOptions();
    if (shown) {
      _rewardedAd?.dispose();
      _rewardedAd = null;
      if (_canLoadAds && !hasReachedDailyLimit) {
        unawaited(_loadRewardedAd());
      }
    }
    notifyListeners();
    return shown;
  }

  Future<bool> _loadRewardedAd() {
    if (!_canLoadAds ||
        _loadingAd ||
        _rewardedAd != null ||
        hasReachedDailyLimit ||
        _retryTimer != null) {
      return _loadCompleter?.future ?? Future.value(_rewardedAd != null);
    }
    _loadingAd = true;
    _loadCompleter = Completer<bool>();
    notifyListeners();
    RewardedAd.load(
      adUnitId: AdsConfig.rewardedWaterAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingAd = false;
          _rewardedAd = ad;
          _loadFailureCount = 0;
          _loadCompleter?.complete(true);
          _loadCompleter = null;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded water ad failed to load: $error');
          _loadingAd = false;
          _scheduleRetry();
          _loadCompleter?.complete(false);
          _loadCompleter = null;
          notifyListeners();
        },
      ),
    );
    return _loadCompleter!.future;
  }

  void _scheduleRetry() {
    final delays = <Duration>[
      const Duration(seconds: 5),
      const Duration(seconds: 30),
      const Duration(minutes: 2),
      const Duration(minutes: 5),
    ];
    final delay = delays[_loadFailureCount.clamp(0, delays.length - 1)];
    _loadFailureCount += 1;
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      unawaited(_loadRewardedAd());
    });
  }

  Future<void> _syncDailyLimit() async {
    final today = _localDayKey(DateTime.now());
    if (_preferences.getString(_scopedKey(_dayKey)) == today) {
      _claimsToday = _preferences.getInt(_scopedKey(_countKey)) ?? 0;
      return;
    }
    _claimsToday = 0;
    await _preferences.setString(_scopedKey(_dayKey), today);
    await _preferences.setInt(_scopedKey(_countKey), 0);
  }

  Future<void> _recordClaim() async {
    _claimsToday += 1;
    await _preferences.setInt(_scopedKey(_countKey), _claimsToday);
    notifyListeners();
  }

  String _scopedKey(String key) => '$key:$_userId';

  String _localDayKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  bool get _canLoadAds =>
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS) &&
      _consentService.canRequestAds &&
      AdsConfig.hasProductionRewardedWaterAdUnit;

  @override
  void dispose() {
    _retryTimer?.cancel();
    _rewardedAd?.dispose();
    super.dispose();
  }
}
