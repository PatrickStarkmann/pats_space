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
import 'package:pats_space/core/analytics/app_analytics.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/network/remote_availability_service.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/app_scaffold.dart';
import 'package:pats_space/core/widgets/app_loading_screen.dart';
import 'package:pats_space/core/widgets/patsspace_bottom_nav_bar.dart';
import 'package:pats_space/features/ads/controllers/rewarded_water_controller.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/active_timer_state.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/focus/repositories/firebase_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/focus_settings_repository.dart';
import 'package:pats_space/features/focus/repositories/mirrored_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/pending_focus_reward_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_settings_repository.dart';
import 'package:pats_space/features/focus/repositories/active_timer_state_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_active_timer_state_repository.dart';
import 'package:pats_space/features/focus_blocking/controllers/focus_blocking_controller.dart';
import 'package:pats_space/features/home/home_screen.dart';
import 'package:pats_space/features/leaderboard/controllers/friends_leaderboard_controller.dart';
import 'package:pats_space/features/leaderboard/repositories/firebase_friends_leaderboard_repository.dart';
import 'package:pats_space/features/notifications/controllers/notification_controller.dart';
import 'package:pats_space/features/notifications/repositories/shared_preferences_notification_settings_repository.dart';
import 'package:pats_space/features/notifications/services/flutter_local_timer_notification_service.dart';
import 'package:pats_space/features/onboarding/onboarding_screen.dart';
import 'package:pats_space/features/settings/models/app_language.dart';
import 'package:pats_space/features/settings/models/week_start_day.dart';
import 'package:pats_space/features/settings/settings_screen.dart';
import 'package:pats_space/features/sounds/controllers/sound_controller.dart';
import 'package:pats_space/features/sounds/repositories/shared_preferences_sound_settings_repository.dart';
import 'package:pats_space/features/sounds/services/audioplayers_app_sound_player.dart';
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
  static const _onboardingFocusChallengeDuration = Duration(seconds: 30);
  static const _onboardingFocusChallengeWaterReward = 10;

  AppTab _selectedTab = AppTab.home;
  late Future<_AppPersistenceBundle> _persistenceFuture;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _incomingFriendRequestsSubscription;
  StreamSubscription<bool>? _networkSubscription;
  Timer? _remoteAvailabilityTimer;
  Timer? _connectivityNoticeTimer;
  Timer? _connectivityNoticeReadinessTimer;
  Timer? _networkOfflineConfirmationTimer;
  String? _requestedPersistenceUid;
  FocusHistoryController? _historyController;
  GardenController? _gardenController;
  SoundController? _soundController;
  NotificationController? _notificationController;
  RewardedWaterController? _rewardedWaterController;
  RewardedWaterController? _adsInitializedForController;
  late final FriendsLeaderboardController _leaderboardController =
      FriendsLeaderboardController(
        repository: FirebaseFriendsLeaderboardRepository(
          auth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
        ),
      );
  _ConnectivityNotice? _connectivityNotice;
  bool _gardenTutorialActive = false;
  bool _onboardingFocusChallengeActive = false;
  bool _finishingOnboardingFocusChallenge = false;
  String? _onboardingSource;
  bool _hasLoadedPersistence = false;
  bool _reportedInitialPersistenceLoaded = false;
  bool _connectivityNoticesReady = false;
  bool _showedOfflineNoticeInSession = false;
  bool _syncingPendingRewards = false;
  bool _hasIncomingFriendRequests = false;
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
  late final FocusBlockingController _focusBlockingController =
      FocusBlockingController();

  @override
  void initState() {
    super.initState();
    unawaited(
      _focusBlockingController.initialize(languageCode: _blockingLanguageCode),
    );
    _requestedPersistenceUid = FirebaseAuth.instance.currentUser?.uid;
    _watchIncomingFriendRequests(FirebaseAuth.instance.currentUser);
    _persistenceFuture = _loadPersistence();
    _remoteAvailabilityTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshRemoteAvailability(),
    );
    _networkSubscription = _remoteAvailabilityService.hasNetworkConnection
        .listen(_handleNetworkConnectionChanged);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _watchIncomingFriendRequests(user);
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
      _rewardedWaterController?.dispose();
      _soundController?.dispose();
      unawaited(_notificationController?.cancelTimerNotification());
      _notificationController?.dispose();
      _historyController = null;
      _gardenController = null;
      _rewardedWaterController = null;
      _adsInitializedForController = null;
      _soundController = null;
      _notificationController = null;
      setState(() {
        _persistenceFuture = _loadPersistence();
      });
    });
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      unawaited(_focusBlockingController.setLanguage(_blockingLanguageCode));
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (!_onboardingFocusChallengeActive) {
      return;
    }

    setState(() {
      _onboardingFocusChallengeActive = false;
      _finishingOnboardingFocusChallenge = false;
      _onboardingSource = null;
      _selectedTab = AppTab.home;
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _incomingFriendRequestsSubscription?.cancel();
    _networkSubscription?.cancel();
    _remoteAvailabilityTimer?.cancel();
    _connectivityNoticeTimer?.cancel();
    _connectivityNoticeReadinessTimer?.cancel();
    _networkOfflineConfirmationTimer?.cancel();
    _historyController?.dispose();
    _gardenController?.dispose();
    _rewardedWaterController?.dispose();
    _soundController?.dispose();
    _notificationController?.dispose();
    _leaderboardController.dispose();
    _focusBlockingController.dispose();
    super.dispose();
  }

  void _watchIncomingFriendRequests(User? user) {
    _incomingFriendRequestsSubscription?.cancel();
    if (user == null) {
      if (_hasIncomingFriendRequests && mounted) {
        setState(() => _hasIncomingFriendRequests = false);
      }
      return;
    }

    _incomingFriendRequestsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('friend_requests')
        .snapshots()
        .listen((snapshot) {
          final hasIncomingRequests = snapshot.docs.isNotEmpty;
          if (!mounted || hasIncomingRequests == _hasIncomingFriendRequests) {
            return;
          }
          setState(() => _hasIncomingFriendRequests = hasIncomingRequests);
        }, onError: (_, _) {});
  }

  String get _blockingLanguageCode =>
      widget.language.storageCode ??
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;

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
          _initializeAdsAfterFirstFrame(bundle.rewardedWaterController);
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
                    if (tab == _selectedTab) {
                      return;
                    }
                    setState(() => _selectedTab = tab);
                    unawaited(AppAnalytics.instance.logScreen(tab.name));
                  },
                  onOnboardingFocusChallengeStarted:
                      _startOnboardingFocusChallenge,
                  onboardingFocusChallengeActive:
                      _onboardingFocusChallengeActive,
                  onOnboardingFocusChallengeCompleted:
                      _completeOnboardingFocusChallenge,
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
                  focusBlockingController: _focusBlockingController,
                  leaderboardController: _leaderboardController,
                  hasIncomingFriendRequests: _hasIncomingFriendRequests,
                ),
        );
      },
    );
  }

  void _initializeAdsAfterFirstFrame(RewardedWaterController controller) {
    if (identical(_adsInitializedForController, controller)) {
      return;
    }

    _adsInitializedForController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !identical(_rewardedWaterController, controller)) {
        return;
      }

      await controller.initialize();
      if (mounted && identical(_rewardedWaterController, controller)) {
        setState(() {});
      }
    });
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
      userId: userId,
    );
    final activeTimerStateRepository =
        SharedPreferencesActiveTimerStateRepository(
          preferences,
          userId: userId,
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
    final soundSettingsRepository = SharedPreferencesSoundSettingsRepository(
      preferences,
    );
    final soundSettings = await soundSettingsRepository.loadSettings();
    final soundController = SoundController(
      initialSettings: soundSettings,
      repository: soundSettingsRepository,
      player: AudioplayersAppSoundPlayer(),
    );
    final notificationSettingsRepository =
        SharedPreferencesNotificationSettingsRepository(preferences);
    final notificationSettings = await notificationSettingsRepository
        .loadSettings();
    final notificationController = NotificationController(
      initialSettings: notificationSettings,
      repository: notificationSettingsRepository,
      service: FlutterLocalTimerNotificationService(),
    );
    await notificationController.initialize();
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
    final activeTimerState = await activeTimerStateRepository.load();
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
    final rewardedWaterController = RewardedWaterController(
      preferences: preferences,
      userId: userId,
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
    if (_gardenTutorialActive) {
      _selectedTab = AppTab.space;
    }
    _historyController = historyController;
    _gardenController = gardenController;
    _rewardedWaterController = rewardedWaterController;
    _soundController = soundController;
    _notificationController = notificationController;
    unawaited(_leaderboardController.initialize(records));

    final bundle = _AppPersistenceBundle(
      preferences: preferences,
      onboardingCompleted: onboardingCompleted,
      settings: settings,
      settingsRepository: settingsRepository,
      activeTimerStateRepository: activeTimerStateRepository,
      activeTimerState: activeTimerState,
      historyController: historyController,
      gardenController: gardenController,
      pendingRewardRepository: pendingRewardRepository,
      soundController: soundController,
      notificationController: notificationController,
      rewardedWaterController: rewardedWaterController,
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

  void _startOnboardingFocusChallenge(String? source) {
    setState(() {
      _onboardingSource = source;
      _onboardingFocusChallengeActive = true;
      _selectedTab = AppTab.home;
    });
  }

  Future<void> _completeOnboardingFocusChallenge() async {
    if (_finishingOnboardingFocusChallenge) {
      return;
    }

    _finishingOnboardingFocusChallenge = true;
    await _handleOnboardingFinished(
      _onboardingSource,
      _onboardingFocusChallengeWaterReward,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingFocusChallengeActive = false;
      _finishingOnboardingFocusChallenge = false;
      _onboardingSource = null;
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
      unawaited(
        AppAnalytics.instance.logAcquisitionSourceSelected(source: source),
      );
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
    await SharedPreferencesFocusSettingsRepository.clearSettingsForUser(
      preferences,
      userId: deletedUserId,
    );
    await SharedPreferencesActiveTimerStateRepository.clearStateForUser(
      preferences,
      userId: deletedUserId,
    );
    if (!mounted) {
      return;
    }

    _soundController?.dispose();
    _soundController = null;
    unawaited(_notificationController?.cancelTimerNotification());
    _notificationController?.dispose();
    _notificationController = null;
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

    _soundController?.dispose();
    _soundController = null;
    unawaited(_notificationController?.cancelTimerNotification());
    _notificationController?.dispose();
    _notificationController = null;
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
    required this.onOnboardingFocusChallengeStarted,
    required this.onboardingFocusChallengeActive,
    required this.onOnboardingFocusChallengeCompleted,
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
    required this.focusBlockingController,
    required this.leaderboardController,
    required this.hasIncomingFriendRequests,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;
  final ValueChanged<String?> onOnboardingFocusChallengeStarted;
  final bool onboardingFocusChallengeActive;
  final Future<void> Function() onOnboardingFocusChallengeCompleted;
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
  final FocusBlockingController focusBlockingController;
  final FriendsLeaderboardController leaderboardController;
  final bool hasIncomingFriendRequests;

  @override
  Widget build(BuildContext context) {
    if (!bundle.onboardingCompleted && !onboardingFocusChallengeActive) {
      return OnboardingScreen(
        onStartFocusChallenge: onOnboardingFocusChallengeStarted,
      );
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
        enabled: !gardenTutorialActive && !onboardingFocusChallengeActive,
        showSettingsIndicator: hasIncomingFriendRequests,
        onTabSelected: onTabSelected,
      ),
      child: Stack(
        children: [
          IndexedStack(
            index: selectedTab.index,
            children: [
              HomeScreen(
                key: ValueKey(
                  'home-${onboardingFocusChallengeActive ? 'tutorial' : 'standard'}',
                ),
                historyController: bundle.historyController,
                gardenController: bundle.gardenController,
                initialSettings: bundle.settings,
                settingsRepository: bundle.settingsRepository,
                activeTimerStateRepository: bundle.activeTimerStateRepository,
                initialActiveTimerState: bundle.activeTimerState,
                pendingRewardRepository: bundle.pendingRewardRepository,
                gardenOnline: bundle.remoteAvailable,
                onEnsureOnlineAction: onEnsureGardenActionOnline,
                onOpenSpace: () => onTabSelected(AppTab.space),
                focusBlockingController: focusBlockingController,
                soundController: bundle.soundController,
                notificationController: bundle.notificationController,
                leaderboardController: leaderboardController,
                rewardedWaterController: bundle.rewardedWaterController,
                tutorialFocusDuration: onboardingFocusChallengeActive
                    ? _AppShellState._onboardingFocusChallengeDuration
                    : null,
                tutorialFocusWaterReward: onboardingFocusChallengeActive
                    ? _AppShellState._onboardingFocusChallengeWaterReward
                    : 0,
                onTutorialFocusCompleted: onboardingFocusChallengeActive
                    ? onOnboardingFocusChallengeCompleted
                    : null,
              ),
              SpaceScreen(
                gardenController: bundle.gardenController,
                gardenOnline: bundle.remoteAvailable,
                onEnsureGardenActionOnline: onEnsureGardenActionOnline,
                rewardedWaterController: bundle.rewardedWaterController,
                tutorialActive: gardenTutorialActive,
                onTutorialCompleted: onGardenTutorialCompleted,
              ),
              StatsScreen(
                historyController: bundle.historyController,
                weekStartDay: weekStartDay,
                leaderboardController: leaderboardController,
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
                focusBlockingController: focusBlockingController,
                soundController: bundle.soundController,
                notificationController: bundle.notificationController,
                rewardedWaterController: bundle.rewardedWaterController,
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
    required this.activeTimerStateRepository,
    required this.activeTimerState,
    required this.historyController,
    required this.gardenController,
    required this.pendingRewardRepository,
    required this.soundController,
    required this.notificationController,
    required this.rewardedWaterController,
    required this.remoteAvailable,
    required this.userId,
  });

  final SharedPreferences preferences;
  final bool onboardingCompleted;
  final FocusTimerSettings settings;
  final FocusSettingsRepository settingsRepository;
  final ActiveTimerStateRepository activeTimerStateRepository;
  final ActiveTimerState? activeTimerState;
  final FocusHistoryController historyController;
  final GardenController gardenController;
  final PendingFocusRewardRepository pendingRewardRepository;
  final SoundController soundController;
  final NotificationController notificationController;
  final RewardedWaterController rewardedWaterController;
  final bool remoteAvailable;
  final String userId;

  _AppPersistenceBundle copyWithOnboardingCompleted() {
    return _AppPersistenceBundle(
      preferences: preferences,
      onboardingCompleted: true,
      settings: settings,
      settingsRepository: settingsRepository,
      activeTimerStateRepository: activeTimerStateRepository,
      activeTimerState: activeTimerState,
      historyController: historyController,
      gardenController: gardenController,
      pendingRewardRepository: pendingRewardRepository,
      soundController: soundController,
      notificationController: notificationController,
      rewardedWaterController: rewardedWaterController,
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
      activeTimerStateRepository: activeTimerStateRepository,
      activeTimerState: activeTimerState,
      historyController: historyController,
      gardenController: gardenController,
      pendingRewardRepository: pendingRewardRepository,
      soundController: soundController,
      notificationController: notificationController,
      rewardedWaterController: rewardedWaterController,
      remoteAvailable: remoteAvailable,
      userId: userId,
    );
  }
}
