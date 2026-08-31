import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pats_space/core/analytics/app_analytics.dart';
import 'package:pats_space/features/pro/services/pro_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// One source of truth for the RevenueCat Pro entitlement.
///
/// A Firebase UID is always used as RevenueCat's app user ID. Linking a guest
/// account keeps the same UID; replacing or deleting an account deliberately
/// starts a fresh RevenueCat customer so access cannot leak to the next user.
class ProController extends ChangeNotifier {
  static const _missingEntitlementError = 'missing_pro_entitlement';
  static const _noRestorablePurchaseError = 'no_restorable_pro_purchase';

  ProController({required FirebaseAuth auth}) : _auth = auth;

  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSubscription;
  CustomerInfoUpdateListener? _customerInfoListener;
  Offering? _offering;
  String? _activeUserId;
  bool _initialized = false;
  bool _isPro = false;
  bool _busy = false;
  String? _error;
  String? _managementUrl;
  String? _productId;
  DateTime? _expiresAt;
  bool _willRenew = false;
  bool _isInBillingRetry = false;

  bool get initialized => _initialized;
  bool get isPro => _isPro;
  bool get isBusy => _busy;
  String? get error => _error;
  bool get isEntitlementMissingError => _error == _missingEntitlementError;
  bool get isNoRestorablePurchaseError => _error == _noRestorablePurchaseError;
  bool get isStoreConfigured => ProConfig.apiKey.isNotEmpty;
  bool get canPurchase =>
      ProConfig.isSupportedPlatform && isStoreConfigured && _offering != null;
  String? get productId => _productId;
  DateTime? get expiresAt => _expiresAt;
  bool get willRenew => _willRenew;
  bool get isInBillingRetry => _isInBillingRetry;

  Package? get monthlyPackage => _packageOfType(PackageType.monthly);
  Package? get annualPackage => _packageOfType(PackageType.annual);
  Package? get lifetimePackage => _packageOfType(PackageType.lifetime);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _authSubscription = _auth.authStateChanges().listen(_syncUser);
    await _syncUser(_auth.currentUser);
  }

  Future<void> refresh() async {
    if (!isStoreConfigured || !ProConfig.isSupportedPlatform) return;
    try {
      await _loadCustomerInfo();
      await _loadOffering();
    } on PlatformException catch (error) {
      _error = error.message ?? error.code;
      notifyListeners();
    }
  }

  Future<bool> purchase(Package package) async {
    if (!canPurchase || _busy) return false;
    final packageType = package.packageType.name;
    _busy = true;
    _error = null;
    notifyListeners();
    unawaited(
      AppAnalytics.instance.logProPurchaseStarted(packageType: packageType),
    );
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _applyCustomerInfo(result.customerInfo);
      // StoreKit can complete before RevenueCat has refreshed its cached
      // customer info. Fetch once more so the app state follows the
      // entitlement, not merely the purchase dialog result.
      await _loadCustomerInfo();
      if (_isPro) {
        unawaited(
          AppAnalytics.instance.logProPurchaseCompleted(
            packageType: packageType,
          ),
        );
      } else {
        _error = _missingEntitlementError;
        unawaited(
          AppAnalytics.instance.logProPurchaseFailed(packageType: packageType),
        );
      }
      return _isPro;
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        unawaited(
          AppAnalytics.instance.logProPurchaseCancelled(
            packageType: packageType,
          ),
        );
      } else {
        _error = error.message ?? error.code;
        unawaited(
          AppAnalytics.instance.logProPurchaseFailed(packageType: packageType),
        );
      }
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> restorePurchases() async {
    if (!isStoreConfigured || !ProConfig.isSupportedPlatform || _busy) {
      return false;
    }
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final customerInfo = await Purchases.restorePurchases();
      _applyCustomerInfo(customerInfo);
      await _loadCustomerInfo();
      if (!_isPro) {
        _error = _noRestorablePurchaseError;
      }
      unawaited(
        AppAnalytics.instance.logProPurchasesRestored(proActive: _isPro),
      );
      return _isPro;
    } on PlatformException catch (error) {
      _error = error.message ?? error.code;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> openSubscriptionManagement() async {
    if (!isPro || !ProConfig.isSupportedPlatform) {
      return false;
    }
    final uri = Uri.tryParse(
      _managementUrl ??
          (defaultTargetPlatform == TargetPlatform.iOS
              ? 'https://apps.apple.com/account/subscriptions'
              : 'https://play.google.com/store/account/subscriptions'),
    );
    if (uri == null) {
      return false;
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _syncUser(User? user) async {
    if (!isStoreConfigured || !ProConfig.isSupportedPlatform) {
      _activeUserId = user?.uid;
      _isPro = false;
      notifyListeners();
      return;
    }

    final userId = user?.uid;
    final previousUserId = _activeUserId;
    if (userId == previousUserId) return;
    _activeUserId = userId;
    _isPro = false;
    _offering = null;
    _clearSubscriptionDetails();
    notifyListeners();
    if (userId == null) {
      if (previousUserId != null && await Purchases.isConfigured) {
        try {
          await Purchases.logOut();
        } on PlatformException {
          // RevenueCat may already be anonymous after a Firebase sign-out.
        }
      }
      return;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      if (!await Purchases.isConfigured) {
        await Purchases.configure(
          PurchasesConfiguration(ProConfig.apiKey)..appUserID = userId,
        );
        _customerInfoListener = _applyCustomerInfo;
        Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);
      } else {
        // A UID switch means a different Patsspace account. Do not alias a
        // deleted/replaced guest account to the selected existing account.
        try {
          await Purchases.logOut();
        } on PlatformException {
          // Already anonymous is a valid state.
        }
        final result = await Purchases.logIn(userId);
        _applyCustomerInfo(result.customerInfo);
      }
      await _loadCustomerInfo();
      await _loadOffering();
    } on PlatformException catch (error) {
      _error = error.message ?? error.code;
      notifyListeners();
    }
  }

  Future<void> _loadCustomerInfo() async {
    _applyCustomerInfo(await Purchases.getCustomerInfo());
  }

  Future<void> _loadOffering() async {
    final offerings = await Purchases.getOfferings();
    _offering = offerings.current ?? offerings.all[ProConfig.defaultOfferingId];
    notifyListeners();
  }

  Package? _packageOfType(PackageType type) {
    return _offering?.availablePackages
        .where((item) => item.packageType == type)
        .firstOrNull;
  }

  void _applyCustomerInfo(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[ProConfig.entitlementId];
    _isPro = entitlement?.isActive ?? false;
    if (kDebugMode) {
      debugPrint(
        'RevenueCat Pro: active=$_isPro, '
        'activeEntitlements=${customerInfo.entitlements.active.keys.toList()}',
      );
    }
    _managementUrl = customerInfo.managementURL;
    _productId = entitlement?.productIdentifier;
    _expiresAt = DateTime.tryParse(entitlement?.expirationDate ?? '');
    _willRenew = entitlement?.willRenew ?? false;
    _isInBillingRetry = entitlement?.billingIssueDetectedAt != null;
    notifyListeners();
  }

  void _clearSubscriptionDetails() {
    _managementUrl = null;
    _productId = null;
    _expiresAt = null;
    _willRenew = false;
    _isInBillingRetry = false;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    final listener = _customerInfoListener;
    if (listener != null) {
      Purchases.removeCustomerInfoUpdateListener(listener);
    }
    super.dispose();
  }
}
