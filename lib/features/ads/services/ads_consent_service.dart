import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsConsentService {
  static const _trackingConsentChannel = MethodChannel(
    'pats_space/tracking_consent',
  );

  bool _initialized = false;
  bool _initializing = false;
  bool _canRequestAds = false;
  PrivacyOptionsRequirementStatus _privacyOptionsStatus =
      PrivacyOptionsRequirementStatus.unknown;

  bool get initialized => _initialized;
  bool get canRequestAds => _canRequestAds;
  bool get isPrivacyOptionsRequired =>
      _privacyOptionsStatus == PrivacyOptionsRequirementStatus.required;

  Future<void> initialize() async {
    if (_initialized || _initializing || !_isSupportedPlatform) {
      return;
    }

    _initializing = true;
    try {
      await _requestConsentInfoUpdate();
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) {
          debugPrint('Ads consent form error: ${error.message}');
        }
      });
      // UMP can show its own IDFA explainer before this system prompt when an
      // IDFA message is configured in AdMob.
      await _requestTrackingAuthorizationIfNeeded();
      await _refreshState();
    } catch (error) {
      debugPrint('Ads consent initialization failed: $error');
      await _refreshState();
    } finally {
      _initializing = false;
      _initialized = true;
    }
  }

  Future<bool> showPrivacyOptions() async {
    await initialize();
    _privacyOptionsStatus = await _safePrivacyOptionsStatus();
    if (!isPrivacyOptionsRequired) {
      return false;
    }

    FormError? formError;
    await ConsentForm.showPrivacyOptionsForm((error) {
      formError = error;
      if (error != null) {
        debugPrint('Ads privacy options error: ${error.message}');
      }
    });
    await _refreshState();
    return formError == null;
  }

  Future<void> _requestConsentInfoUpdate() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => completer.complete(),
      (error) => completer.completeError(error),
    );
    return completer.future;
  }

  Future<void> _refreshState() async {
    _canRequestAds = await _safeCanRequestAds();
    _privacyOptionsStatus = await _safePrivacyOptionsStatus();
  }

  Future<bool> _safeCanRequestAds() async {
    try {
      return ConsentInformation.instance.canRequestAds();
    } catch (_) {
      return false;
    }
  }

  Future<PrivacyOptionsRequirementStatus> _safePrivacyOptionsStatus() async {
    try {
      return ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    } catch (_) {
      return PrivacyOptionsRequirementStatus.unknown;
    }
  }

  Future<void> _requestTrackingAuthorizationIfNeeded() async {
    if (!Platform.isIOS) {
      return;
    }
    try {
      await _trackingConsentChannel.invokeMethod<void>(
        'requestTrackingAuthorization',
      );
    } catch (error) {
      debugPrint('Tracking authorization request failed: $error');
    }
  }

  bool get _isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
