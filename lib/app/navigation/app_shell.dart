import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pats_space/app/navigation/app_tab.dart';
import 'package:pats_space/core/auth/account_auth_service.dart';
import 'package:pats_space/core/auth/auth_session.dart';
import 'package:pats_space/core/auth/firebase_account_auth_service.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/network/remote_availability_service.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/app_scaffold.dart';
import 'package:pats_space/core/widgets/app_loading_screen.dart';
import 'package:pats_space/core/widgets/patsspace_bottom_nav_bar.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/focus/repositories/firebase_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/focus_settings_repository.dart';
import 'package:pats_space/features/focus/repositories/mirrored_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/pending_focus_reward_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_settings_repository.dart';
import 'package:pats_space/features/home/home_screen.dart';
import 'package:pats_space/features/onboarding/onboarding_screen.dart';
import 'package:pats_space/features/settings/models/app_language.dart';
import 'package:pats_space/features/settings/models/week_start_day.dart';
import 'package:pats_space/features/settings/settings_screen.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/firebase_garden_repository.dart';
import 'package:pats_space/features/space/repositories/mirrored_garden_repository.dart';
import 'package:pats_space/features/space/repositories/shared_preferences_garden_repository.dart';
import 'package:pats_space/features/space/space_screen.dart';
import 'package:pats_space/features/stats/stats_screen.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    this.showInitialLoadingScreen = true,
    this.onInitialPersistenceLoaded,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final bool showInitialLoadingScreen;
  final VoidCallback? onInitialPersistenceLoaded;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _onboardingCompletedKey = 'onboarding.completed.v1';
  static const _gardenTutorialCompletedKey =
      'onboarding.garden_tutorial_completed.v1';
  static const _weekStartDayKey = 'settings.week_start_day.v1';

  AppTab _selectedTab = AppTab.home;
  late Future<_AppPersistenceBundle> _persistenceFuture;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<bool>? _networkSubscription;
  Timer? _remoteAvailabilityTimer;
  Timer? _connectivityNoticeTimer;
  Timer? _connectivityNoticeReadinessTimer;
  Timer? _networkOfflineConfirmationTimer;
  String? _requestedPersistenceUid;
  FocusHistoryController? _historyController;
  GardenController? _gardenController;
  _ConnectivityNotice? _connectivityNotice;
  bool _gardenTutorialActive = false;
  bool _hasLoadedPersistence = false;
  bool _reportedInitialPersistenceLoaded = false;
  bool _connectivityNoticesReady = false;
  bool _showedOfflineNoticeInSession = false;
  bool _syncingPendingRewards = false;
  WeekStartDay _weekStartDay = WeekStartDay.defaultValue;
  late final AccountAuthService _accountAuthService =
      FirebaseAccountAuthService(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      );
  late final RemoteAvailabilityService _remoteAvailabilityService =
      RemoteAvailabilityService(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        connectivity: Connectivity(),
      );

  @override
  void initState() {
    super.initState();
    _requestedPersistenceUid = FirebaseAuth.instance.currentUser?.uid;
    _persistenceFuture = _loadPersistence();
    _remoteAvailabilityTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshRemoteAvailability(),
    );
    _networkSubscription = _remoteAvailabilityService.hasNetworkConnection
        .listen(_handleNetworkConnectionChanged);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      final uid = user?.uid;
      if (uid == null) {
        return;
      }
      if (uid == _requestedPersistenceUid) {
        return;
      }

      _requestedPersistenceUid = uid;
      _historyController?.dispose();
      _gardenController?.dispose();
      _historyController = null;
      _gardenController = null;
      setState(() {
        _persistenceFuture = _loadPersistence();
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _networkSubscription?.cancel();
    _remoteAvailabilityTimer?.cancel();
    _connectivityNoticeTimer?.cancel();
    _connectivityNoticeReadinessTimer?.cancel();
    _networkOfflineConfirmationTimer?.cancel();
    _historyController?.dispose();
    _gardenController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppPersistenceBundle>(
      future: _persistenceFuture,
      builder: (context, snapshot) {
        final bundle = snapshot.connectionState == ConnectionState.done
            ? snapshot.data
            : null;
        if (bundle != null) {
          _hasLoadedPersistence = true;
          _reportInitialPersistenceLoaded();
          _scheduleConnectivityNoticeReadiness();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: _fullscreenSwitcherLayout,
          transitionBuilder: _fadeInOnlyTransition,
          child: bundle == null
              ? _buildPersistenceFallback()
              : _AppShellContent(
                  key: const ValueKey('app-shell-content'),
                  selectedTab: _selectedTab,
                  onTabSelected: (tab) {
                    setState(() => _selectedTab = tab);
                  },
                  onOnboardingFinished: _handleOnboardingFinished,
                  gardenTutorialActive: _gardenTutorialActive,
                  onGardenTutorialCompleted: () {
                    _handleGardenTutorialCompleted();
                  },
                  onAccountDeleted: _handleAccountDeleted,
                  onSignedOutToGuest: _handleSignedOutToGuest,
                  connectivityNotice: _connectivityNotice,
                  onConnectivityNoticeDismissed: _dismissConnectivityNotice,
                  onEnsureGardenActionOnline:
                      _ensureRemoteAvailableForGardenAction,
                  bundle: bundle,
                  language: widget.language,
                  onLanguageChanged: widget.onLanguageChanged,
                  weekStartDay: _weekStartDay,
                  onWeekStartDayChanged: _handleWeekStartDayChanged,
                ),
        );
      },
    );
  }

  Widget _buildPersistenceFallback() {
    if (!_hasLoadedPersistence && !widget.showInitialLoadingScreen) {
      return const ColoredBox(
        key: ValueKey('initial-persistence-background'),
        color: AppColors.background,
      );
    }

    return const AppLoadingScreen(
      key: ValueKey('persistence-loading'),
      animateEntrance: false,
    );
  }

  void _reportInitialPersistenceLoaded() {
    if (_reportedInitialPersistenceLoaded) {
      return;
    }

    _reportedInitialPersistenceLoaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onInitialPersistenceLoaded?.call();
    });
  }

  void _scheduleConnectivityNoticeReadiness() {
    if (_connectivityNoticesReady ||
        _connectivityNoticeReadinessTimer != null) {
      return;
    }

    _connectivityNoticeReadinessTimer = Timer(
      const Duration(seconds: 2),
      () async {
        if (!mounted) {
          return;
        }

        await _persistenceFuture;
        var hasNetworkConnection = await _remoteAvailabilityService
            .checkNetworkConnection();
        if (!hasNetworkConnection) {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          hasNetworkConnection = await _remoteAvailabilityService
              .checkNetworkConnection();
        }
        if (!mounted) {
          return;
        }

        setState(() {
          _connectivityNoticesReady = true;
        });
      },
    );
  }

  Widget _fullscreenSwitcherLayout(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        const ColoredBox(color: AppColors.background),
        ...previousChildren,
        ?currentChild,
      ],
    );
  }

  Widget _fadeInOnlyTransition(Widget child, Animation<double> animation) {
    if (animation.status == AnimationStatus.reverse) {
      return child;
    }

    return FadeTransition(opacity: animation, child: child);
  }

  Future<_AppPersistenceBundle> _loadPersistence() async {
    final preferences = await SharedPreferences.getInstance();
    final userId = requireCurrentUser(FirebaseAuth.instance).uid;
    final settingsRepository = SharedPreferencesFocusSettingsRepository(
      preferences,
    );
    final localHistoryRepository = SharedPreferencesFocusHistoryRepository(
      preferences,
      userId: userId,
    );
    final localGardenRepository = SharedPreferencesGardenRepository(
      preferences,
      userId: userId,
    );
    final pendingRewardRepository = PendingFocusRewardRepository(
      preferences,
      userId: userId,
    );
    final historyRepository = FirebaseFocusHistoryRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
    final gardenRepository = FirebaseGardenRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
    final settings =
        await settingsRepository.loadSettings() ??
        FocusTimerController.defaultSettings;
    _weekStartDay = WeekStartDay.fromStoredName(
      preferences.getString(_weekStartDayKey),
    );
    final remoteAvailable = await _checkRemoteAvailable();
    final records = await _loadMigratedFocusHistory(
      localRepository: localHistoryRepository,
      firebaseRepository: historyRepository,
      remoteAvailable: remoteAvailable,
    );
    final gardenState = await _loadMigratedGardenState(
      localRepository: localGardenRepository,
      firebaseRepository: gardenRepository,
      remoteAvailable: remoteAvailable,
    );
    final historyController = FocusHistoryController(
      repository: MirroredFocusHistoryRepository(
        localRepository: localHistoryRepository,
        remoteRepository: historyRepository,
      ),
      initialRecords: records,
    );
    final gardenController = GardenController(
      repository: MirroredGardenRepository(
        localRepository: localGardenRepository,
        remoteRepository: gardenRepository,
      ),
      initialState: gardenState,
    );
    var onboardingCompleted = await _loadScopedBool(
      preferences,
      key: _onboardingCompletedKey,
      userId: userId,
    );
    var gardenTutorialCompleted = await _loadScopedBool(
      preferences,
      key: _gardenTutorialCompletedKey,
      userId: userId,
    );
    final hasExistingProgress = records.isNotEmpty || gardenState != null;
    if (hasExistingProgress && !onboardingCompleted) {
      onboardingCompleted = true;
      gardenTutorialCompleted = true;
      await _setScopedBool(
        preferences,
        key: _onboardingCompletedKey,
        userId: userId,
        value: true,
      );
      await _setScopedBool(
        preferences,
        key: _gardenTutorialCompletedKey,
        userId: userId,
        value: true,
      );
    }
    _gardenTutorialActive = onboardingCompleted && !gardenTutorialCompleted;
    _historyController = historyController;
    _gardenController = gardenController;

    final bundle = _AppPersistenceBundle(
      preferences: preferences,
      onboardingCompleted: onboardingCompleted,
      settings: settings,
      settingsRepository: settingsRepository,
      historyController: historyController,
      gardenController: gardenController,
      pendingRewardRepository: pendingRewardRepository,
      remoteAvailable: remoteAvailable,
      userId: userId,
    );
    unawaited(_syncPendingFocusRewardsIfPossible(bundle));
    return bundle;
  }

  Future<void> _handleWeekStartDayChanged(WeekStartDay weekStartDay) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_weekStartDayKey, weekStartDay.name);
    if (!mounted) {
      return;
    }

    setState(() => _weekStartDay = weekStartDay);
  }

  Future<bool> _loadScopedBool(
    SharedPreferences preferences, {
    required String key,
    required String userId,
  }) async {
    final scopedKey = _scopedPreferenceKey(key, userId);
    final scopedValue = preferences.getBool(scopedKey);
    if (scopedValue != null) {
      return scopedValue;
    }

    final legacyValue = preferences.getBool(key);
    if (legacyValue == null) {
      return false;
    }

    await preferences.setBool(scopedKey, legacyValue);
    await preferences.remove(key);
    return legacyValue;
  }

  Future<void> _setScopedBool(
    SharedPreferences preferences, {
    required String key,
    required String userId,
    required bool value,
  }) {
    return preferences.setBool(_scopedPreferenceKey(key, userId), value);
  }

  Future<void> _removeScopedBool(
    SharedPreferences preferences, {
    required String key,
    required String userId,
  }) {
    return preferences.remove(_scopedPreferenceKey(key, userId));
  }

  String _scopedPreferenceKey(String key, String userId) => '$key:$userId';

  Future<List<FocusSessionRecord>> _loadMigratedFocusHistory({
    required SharedPreferencesFocusHistoryRepository localRepository,
    required FirebaseFocusHistoryRepository firebaseRepository,
    required bool remoteAvailable,
  }) async {
    final localRecords = await localRepository.loadRecords();
    if (!remoteAvailable) {
      return localRecords;
    }

    final firebaseRecords = await _loadRemoteFocusHistory(firebaseRepository);
    if (firebaseRecords.isNotEmpty) {
      await localRepository.saveRecords(firebaseRecords);
      return firebaseRecords;
    }

    if (localRecords.isEmpty) {
      return const [];
    }

    await firebaseRepository.saveRecords(localRecords);
    return localRecords;
  }

  Future<GardenState?> _loadMigratedGardenState({
    required SharedPreferencesGardenRepository localRepository,
    required FirebaseGardenRepository firebaseRepository,
    required bool remoteAvailable,
  }) async {
    final localState = await localRepository.loadState();
    if (!remoteAvailable) {
      return localState;
    }

    final firebaseState = await _loadRemoteGardenState(firebaseRepository);
    if (firebaseState != null) {
      await localRepository.saveState(firebaseState);
      return firebaseState;
    }

    if (localState == null) {
      return null;
    }

    await firebaseRepository.saveState(localState);
    return localState;
  }

  Future<List<FocusSessionRecord>> _loadRemoteFocusHistory(
    FirebaseFocusHistoryRepository repository,
  ) async {
    try {
      return await repository.loadRecords();
    } catch (error, stackTrace) {
      debugPrint('Could not load remote focus history: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const [];
    }
  }

  Future<GardenState?> _loadRemoteGardenState(
    FirebaseGardenRepository repository,
  ) async {
    try {
      return await repository.loadState();
    } catch (error, stackTrace) {
      debugPrint('Could not load remote garden state: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> _checkRemoteAvailable() async {
    return _remoteAvailabilityService.checkRemoteAvailable();
  }

  Future<void> _refreshRemoteAvailability() async {
    final bundle = await _persistenceFuture;
    final remoteAvailable = await _checkRemoteAvailable();
    if (remoteAvailable) {
      await _syncPendingFocusRewardsIfPossible(
        bundle,
        remoteAvailableOverride: true,
      );
      if (!mounted || bundle.remoteAvailable) {
        return;
      }

      setState(() {
        if (_shouldShowConnectivityNotice(_ConnectivityNotice.online)) {
          _showConnectivityNotice(_ConnectivityNotice.online);
        }
        _persistenceFuture = Future.value(bundle.copyWithRemoteAvailable(true));
      });
    }
  }

  Future<void> _handleNetworkConnectionChanged(bool hasConnection) async {
    if (!hasConnection) {
      _networkOfflineConfirmationTimer?.cancel();
      _networkOfflineConfirmationTimer = Timer(
        const Duration(milliseconds: 1200),
        () async {
          final stillOffline = !await _remoteAvailabilityService
              .checkNetworkConnection();
          if (!mounted || !stillOffline) {
            return;
          }

          await _updateRemoteAvailability(false, showNotice: true);
        },
      );
      return;
    }

    _networkOfflineConfirmationTimer?.cancel();
    await _updateRemoteAvailability(true, showNotice: true);
    await _refreshRemoteAvailability();
  }

  Future<bool> _ensureRemoteAvailableForGardenAction() async {
    var remoteAvailable = await _remoteAvailabilityService
        .checkNetworkConnection();
    if (!remoteAvailable) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      remoteAvailable = await _remoteAvailabilityService
          .checkNetworkConnection();
    }

    await _updateRemoteAvailability(
      remoteAvailable,
      showNotice: true,
      forceNotice: true,
    );
    return remoteAvailable;
  }

  Future<void> _updateRemoteAvailability(
    bool remoteAvailable, {
    required bool showNotice,
    bool forceNotice = false,
  }) async {
    final bundle = await _persistenceFuture;
    if (!mounted || remoteAvailable == bundle.remoteAvailable) {
      if (mounted && remoteAvailable) {
        _clearStaleOfflineNotice();
      }
      if (mounted &&
          !remoteAvailable &&
          showNotice &&
          _shouldShowConnectivityNotice(
            _ConnectivityNotice.offline,
            force: forceNotice,
          )) {
        setState(() {
          _showConnectivityNotice(_ConnectivityNotice.offline);
        });
      }
      return;
    }

    setState(() {
      if (showNotice) {
        if (_shouldShowConnectivityNotice(
          remoteAvailable
              ? _ConnectivityNotice.online
              : _ConnectivityNotice.offline,
          force: forceNotice,
        )) {
          _showConnectivityNotice(
            remoteAvailable
                ? _ConnectivityNotice.online
                : _ConnectivityNotice.offline,
          );
        }
      }
      _persistenceFuture = Future.value(
        bundle.copyWithRemoteAvailable(remoteAvailable),
      );
    });
  }

  bool _shouldShowConnectivityNotice(
    _ConnectivityNotice notice, {
    bool force = false,
  }) {
    if (!_connectivityNoticesReady && !force) {
      return false;
    }

    return notice == _ConnectivityNotice.offline ||
        _showedOfflineNoticeInSession;
  }

  void _showConnectivityNotice(_ConnectivityNotice notice) {
    _connectivityNoticeTimer?.cancel();
    _connectivityNotice = notice;
    if (notice == _ConnectivityNotice.offline) {
      _showedOfflineNoticeInSession = true;
    }
    if (notice == _ConnectivityNotice.online) {
      _connectivityNoticeTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted || _connectivityNotice != _ConnectivityNotice.online) {
          return;
        }
        setState(() {
          _connectivityNotice = null;
        });
      });
    }
  }

  void _clearStaleOfflineNotice() {
    if (_connectivityNotice != _ConnectivityNotice.offline) {
      return;
    }

    _connectivityNoticeTimer?.cancel();
    setState(() {
      _connectivityNotice = null;
    });
  }

  void _dismissConnectivityNotice() {
    _connectivityNoticeTimer?.cancel();
    setState(() {
      _connectivityNotice = null;
    });
  }

  Future<void> _syncPendingFocusRewardsIfPossible(
    _AppPersistenceBundle bundle, {
    bool? remoteAvailableOverride,
  }) async {
    final remoteAvailable = remoteAvailableOverride ?? bundle.remoteAvailable;
    if (!remoteAvailable || _syncingPendingRewards) {
      return;
    }

    _syncingPendingRewards = true;
    try {
      final rewards = await bundle.pendingRewardRepository.loadRewards();
      if (rewards.isEmpty) {
        return;
      }

      final knownRecordIds = bundle.historyController.records
          .map((record) => record.id)
          .toSet();
      var unappliedWaterReward = 0;
      var shouldPersistHistory = false;
      for (final reward in rewards) {
        if (!reward.appliedLocally) {
          unappliedWaterReward += reward.waterReward;
        }
        final record = reward.record;
        if (record != null) {
          shouldPersistHistory = true;
          if (!knownRecordIds.contains(record.id)) {
            bundle.historyController.addRecord(record);
            knownRecordIds.add(record.id);
          }
        }
      }

      if (shouldPersistHistory) {
        await bundle.historyController.persist();
      }
      if (unappliedWaterReward > 0) {
        bundle.gardenController.addWater(unappliedWaterReward);
      }
      await bundle.gardenController.persist();
      await bundle.pendingRewardRepository.clearRewards();
    } finally {
      _syncingPendingRewards = false;
    }
  }

  Future<void> _handleOnboardingFinished(
    String? source,
    int waterReward,
  ) async {
    final bundle = await _persistenceFuture;
    if (source != null) {
      await _saveOnboardingSource(source);
    }
    await _setScopedBool(
      bundle.preferences,
      key: _onboardingCompletedKey,
      userId: bundle.userId,
      value: true,
    );
    await _setScopedBool(
      bundle.preferences,
      key: _gardenTutorialCompletedKey,
      userId: bundle.userId,
      value: false,
    );
    bundle.gardenController.addWater(waterReward);

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedTab = AppTab.space;
      _gardenTutorialActive = true;
      _persistenceFuture = Future.value(bundle.copyWithOnboardingCompleted());
    });
  }

  Future<void> _saveOnboardingSource(String source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Could not save onboarding source: no Firebase user.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'onboardingSource': source,
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      debugPrint('Could not save onboarding source: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _handleGardenTutorialCompleted() async {
    final bundle = await _persistenceFuture;
    await _setScopedBool(
      bundle.preferences,
      key: _gardenTutorialCompletedKey,
      userId: bundle.userId,
      value: true,
    );
    if (!mounted) {
      return;
    }

    setState(() => _gardenTutorialActive = false);
    await _showSaveSpacePromptIfNeeded();
  }

  Future<void> _handleAccountDeleted(String deletedUserId) async {
    final preferences = await SharedPreferences.getInstance();
    await _removeScopedBool(
      preferences,
      key: _onboardingCompletedKey,
      userId: deletedUserId,
    );
    await _removeScopedBool(
      preferences,
      key: _gardenTutorialCompletedKey,
      userId: deletedUserId,
    );
    await preferences.remove(_onboardingCompletedKey);
    await preferences.remove(_gardenTutorialCompletedKey);
    await SharedPreferencesFocusHistoryRepository.clearRecordsForUser(
      preferences,
      userId: deletedUserId,
    );
    await SharedPreferencesGardenRepository.clearStateForUser(
      preferences,
      userId: deletedUserId,
    );
    await PendingFocusRewardRepository.clearRewardsForUser(
      preferences,
      userId: deletedUserId,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedTab = AppTab.home;
      _gardenTutorialActive = false;
      _persistenceFuture = _loadPersistence();
    });
  }

  Future<void> _handleSignedOutToGuest() async {
    final preferences = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _removeScopedBool(
        preferences,
        key: _onboardingCompletedKey,
        userId: userId,
      );
      await _removeScopedBool(
        preferences,
        key: _gardenTutorialCompletedKey,
        userId: userId,
      );
    }
    await preferences.remove(_onboardingCompletedKey);
    await preferences.remove(_gardenTutorialCompletedKey);
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedTab = AppTab.home;
      _gardenTutorialActive = false;
      _persistenceFuture = _loadPersistence();
    });
  }

  Future<void> _showSaveSpacePromptIfNeeded() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !user.isAnonymous) {
      return;
    }

    final method = await showCupertinoModalPopup<_SaveSpaceAuthMethod>(
      context: context,
      builder: (context) {
        return _SaveSpaceSheet(
          appleAvailable: _accountAuthService.isAppleSignInAvailable,
        );
      },
    );

    if (method == null) {
      return;
    }

    switch (method) {
      case _SaveSpaceAuthMethod.apple:
        await _secureAccount(_accountAuthService.secureWithApple);
      case _SaveSpaceAuthMethod.google:
        await _secureAccount(_accountAuthService.secureWithGoogle);
    }
  }

  Future<void> _secureAccount(
    Future<AccountAuthResult> Function() secure,
  ) async {
    try {
      final result = await secure();
      final resolvedResult = await _resolveAccountAuthResult(result);
      if (!mounted) {
        return;
      }

      await _showMessage(_successMessage(resolvedResult));
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      await _showMessage(
        _messageForAuthError(error, AppLocalizations.of(context)),
      );
    } on GoogleSignInException catch (error) {
      if (!mounted) {
        return;
      }

      if (error.code != GoogleSignInExceptionCode.canceled) {
        await _showMessage(AppLocalizations.of(context).accountSecureFailed);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      await _showMessage(AppLocalizations.of(context).accountSecureFailed);
    }
  }

  Future<AccountAuthResult> _resolveAccountAuthResult(
    AccountAuthResult result,
  ) async {
    if (result is! GuestReplacementRequired) {
      return result;
    }

    final shouldReplace = await _confirmReplaceGuestAccount();
    if (shouldReplace != true) {
      throw FirebaseAuthException(code: 'canceled');
    }

    return _accountAuthService.replaceGuestWithExistingAccount(result);
  }

  Future<bool?> _confirmReplaceGuestAccount() {
    final l10n = AppLocalizations.of(context);
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.replaceGuestAccountTitle),
          content: Text(l10n.replaceGuestAccountMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.replaceGuestAccountAction),
            ),
          ],
        );
      },
    );
  }

  String _successMessage(AccountAuthResult result) {
    final l10n = AppLocalizations.of(context);
    return switch (result) {
      ExistingAccountSignedIn() => l10n.existingAccountSignInSuccess,
      _ => l10n.accountSecureSuccess,
    };
  }

  String _messageForAuthError(
    FirebaseAuthException error,
    AppLocalizations l10n,
  ) {
    return switch (error.code) {
      'provider-already-linked' => l10n.providerAlreadyLinked,
      'credential-already-in-use' ||
      'account-exists-with-different-credential' ||
      'email-already-in-use' => l10n.accountProviderInUse,
      'operation-not-allowed' => l10n.providerNotEnabled,
      'web-context-cancelled' ||
      'popup-closed-by-user' ||
      'canceled' ||
      'cancelled' => l10n.signInCancelled,
      _ => l10n.accountSecureFailed,
    };
  }

  Future<void> _showMessage(String message) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

enum _SaveSpaceAuthMethod { apple, google }

class _SaveSpaceSheet extends StatelessWidget {
  const _SaveSpaceSheet({required this.appleAvailable});

  final bool appleAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.graySoft.withValues(alpha: .5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: .12),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.saveYourSpaceTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline.copyWith(
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.saveYourSpaceBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted.copyWith(
                    height: 1.28,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (appleAvailable) ...[
                  _SaveSpaceAuthButton(
                    mark: '',
                    label: l10n.continueWithApple,
                    onTap: () {
                      Navigator.of(context).pop(_SaveSpaceAuthMethod.apple);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                _SaveSpaceAuthButton(
                  mark: 'G',
                  label: l10n.continueWithGoogle,
                  onTap: () {
                    Navigator.of(context).pop(_SaveSpaceAuthMethod.google);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      l10n.notNow,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.grayWarm,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveSpaceAuthButton extends StatefulWidget {
  const _SaveSpaceAuthButton({
    required this.mark,
    required this.label,
    required this.onTap,
  });

  final String mark;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SaveSpaceAuthButton> createState() => _SaveSpaceAuthButtonState();
}

class _SaveSpaceAuthButtonState extends State<_SaveSpaceAuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        scale: _pressed ? .985 : 1,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: .16),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                child: widget.mark == 'G'
                    ? Center(
                        child: Image.asset(
                          AppAssets.googleLogo,
                          width: 18,
                          height: 18,
                        ),
                      )
                    : Text(
                        widget.mark,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.surface,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.surface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppShellContent extends StatelessWidget {
  const _AppShellContent({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.onOnboardingFinished,
    required this.gardenTutorialActive,
    required this.onGardenTutorialCompleted,
    required this.onAccountDeleted,
    required this.onSignedOutToGuest,
    required this.connectivityNotice,
    required this.onConnectivityNoticeDismissed,
    required this.onEnsureGardenActionOnline,
    required this.bundle,
    required this.language,
    required this.onLanguageChanged,
    required this.weekStartDay,
    required this.onWeekStartDayChanged,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;
  final Future<void> Function(String? source, int waterReward)
  onOnboardingFinished;
  final bool gardenTutorialActive;
  final VoidCallback onGardenTutorialCompleted;
  final Future<void> Function(String deletedUserId) onAccountDeleted;
  final Future<void> Function() onSignedOutToGuest;
  final _ConnectivityNotice? connectivityNotice;
  final VoidCallback onConnectivityNoticeDismissed;
  final Future<bool> Function() onEnsureGardenActionOnline;
  final _AppPersistenceBundle bundle;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final WeekStartDay weekStartDay;
  final ValueChanged<WeekStartDay> onWeekStartDayChanged;

  @override
  Widget build(BuildContext context) {
    if (!bundle.onboardingCompleted) {
      return OnboardingScreen(onFinished: onOnboardingFinished);
    }

    return AppScaffold(
      backgroundColor:
          selectedTab == AppTab.stats || selectedTab == AppTab.settings
          ? const Color(0xFFF5F4FA)
          : AppColors.background,
      horizontalPadding: switch (selectedTab) {
        AppTab.stats => 0,
        AppTab.settings => 0,
        AppTab.space => 0,
        _ => AppSpacing.screenHorizontal,
      },
      bottomNavigation: PatsspaceBottomNavBar(
        selectedTab: selectedTab,
        enabled: !gardenTutorialActive,
        onTabSelected: onTabSelected,
      ),
      child: Stack(
        children: [
          IndexedStack(
            index: selectedTab.index,
            children: [
              HomeScreen(
                historyController: bundle.historyController,
                gardenController: bundle.gardenController,
                initialSettings: bundle.settings,
                settingsRepository: bundle.settingsRepository,
                pendingRewardRepository: bundle.pendingRewardRepository,
                gardenOnline: bundle.remoteAvailable,
                onEnsureOnlineAction: onEnsureGardenActionOnline,
                onOpenSpace: () => onTabSelected(AppTab.space),
              ),
              SpaceScreen(
                gardenController: bundle.gardenController,
                gardenOnline: bundle.remoteAvailable,
                onEnsureGardenActionOnline: onEnsureGardenActionOnline,
                tutorialActive: gardenTutorialActive,
                onTutorialCompleted: onGardenTutorialCompleted,
              ),
              StatsScreen(
                historyController: bundle.historyController,
                weekStartDay: weekStartDay,
              ),
              SettingsScreen(
                language: language,
                onLanguageChanged: onLanguageChanged,
                weekStartDay: weekStartDay,
                onWeekStartDayChanged: onWeekStartDayChanged,
                onAccountDeleted: onAccountDeleted,
                onSignedOutToGuest: onSignedOutToGuest,
                remoteAvailable: bundle.remoteAvailable,
                onEnsureOnlineAction: onEnsureGardenActionOnline,
              ),
            ],
          ),
          Positioned(
            top: selectedTab == AppTab.space ? 128 : AppSpacing.md,
            left: selectedTab == AppTab.space ? AppSpacing.xl : 0,
            right: selectedTab == AppTab.space ? AppSpacing.xl : 0,
            child: _ConnectivityNoticeBanner(
              notice: connectivityNotice,
              onDismissed: onConnectivityNoticeDismissed,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ConnectivityNotice { offline, online }

class _ConnectivityNoticeBanner extends StatelessWidget {
  const _ConnectivityNoticeBanner({
    required this.notice,
    required this.onDismissed,
  });

  final _ConnectivityNotice? notice;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final currentNotice = notice;
    final l10n = AppLocalizations.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: currentNotice == null
          ? const SizedBox.shrink(key: ValueKey('connection-none'))
          : Align(
              key: ValueKey(currentNotice),
              alignment: Alignment.topCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDismissed,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: .95),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: AppColors.graySoft.withValues(alpha: .54),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withValues(alpha: .09),
                          blurRadius: 18,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            currentNotice == _ConnectivityNotice.offline
                                ? CupertinoIcons.wifi_slash
                                : CupertinoIcons.checkmark_alt_circle,
                            color: currentNotice == _ConnectivityNotice.offline
                                ? AppColors.grayWarm
                                : AppColors.sage,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              currentNotice == _ConnectivityNotice.offline
                                  ? l10n.connectionOfflineMessage
                                  : l10n.connectionOnlineMessage,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.charcoal.withValues(
                                  alpha: .78,
                                ),
                                fontWeight: FontWeight.w900,
                                height: 1.18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _AppPersistenceBundle {
  const _AppPersistenceBundle({
    required this.preferences,
    required this.onboardingCompleted,
    required this.settings,
    required this.settingsRepository,
    required this.historyController,
    required this.gardenController,
    required this.pendingRewardRepository,
    required this.remoteAvailable,
    required this.userId,
  });

  final SharedPreferences preferences;
  final bool onboardingCompleted;
  final FocusTimerSettings settings;
  final FocusSettingsRepository settingsRepository;
  final FocusHistoryController historyController;
  final GardenController gardenController;
  final PendingFocusRewardRepository pendingRewardRepository;
  final bool remoteAvailable;
  final String userId;

  _AppPersistenceBundle copyWithOnboardingCompleted() {
    return _AppPersistenceBundle(
      preferences: preferences,
      onboardingCompleted: true,
      settings: settings,
      settingsRepository: settingsRepository,
      historyController: historyController,
      gardenController: gardenController,
      pendingRewardRepository: pendingRewardRepository,
      remoteAvailable: remoteAvailable,
      userId: userId,
    );
  }

  _AppPersistenceBundle copyWithRemoteAvailable(bool remoteAvailable) {
    return _AppPersistenceBundle(
      preferences: preferences,
      onboardingCompleted: onboardingCompleted,
      settings: settings,
      settingsRepository: settingsRepository,
      historyController: historyController,
      gardenController: gardenController,
      pendingRewardRepository: pendingRewardRepository,
      remoteAvailable: remoteAvailable,
      userId: userId,
    );
  }
}
