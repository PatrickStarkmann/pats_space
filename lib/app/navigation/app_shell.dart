import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pats_space/app/navigation/app_tab.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/widgets/app_scaffold.dart';
import 'package:pats_space/core/widgets/patsspace_bottom_nav_bar.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/focus/repositories/firebase_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/focus_settings_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_settings_repository.dart';
import 'package:pats_space/features/home/home_screen.dart';
import 'package:pats_space/features/settings/models/app_language.dart';
import 'package:pats_space/features/settings/settings_screen.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/firebase_garden_repository.dart';
import 'package:pats_space/features/space/repositories/shared_preferences_garden_repository.dart';
import 'package:pats_space/features/space/space_screen.dart';
import 'package:pats_space/features/stats/stats_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _selectedTab = AppTab.home;
  late Future<_AppPersistenceBundle> _persistenceFuture;
  StreamSubscription<User?>? _authSubscription;
  String? _requestedPersistenceUid;
  FocusHistoryController? _historyController;
  GardenController? _gardenController;

  @override
  void initState() {
    super.initState();
    _requestedPersistenceUid = FirebaseAuth.instance.currentUser?.uid;
    _persistenceFuture = _loadPersistence();
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
        if (bundle == null) {
          return const AppScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        return _AppShellContent(
          selectedTab: _selectedTab,
          onTabSelected: (tab) {
            setState(() => _selectedTab = tab);
          },
          bundle: bundle,
          language: widget.language,
          onLanguageChanged: widget.onLanguageChanged,
        );
      },
    );
  }

  Future<_AppPersistenceBundle> _loadPersistence() async {
    final preferences = await SharedPreferences.getInstance();
    final settingsRepository = SharedPreferencesFocusSettingsRepository(
      preferences,
    );
    final localHistoryRepository = SharedPreferencesFocusHistoryRepository(
      preferences,
    );
    final localGardenRepository = SharedPreferencesGardenRepository(
      preferences,
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
    final records = await _loadMigratedFocusHistory(
      localRepository: localHistoryRepository,
      firebaseRepository: historyRepository,
    );
    final gardenState = await _loadMigratedGardenState(
      localRepository: localGardenRepository,
      firebaseRepository: gardenRepository,
    );
    final historyController = FocusHistoryController(
      repository: historyRepository,
      initialRecords: records,
    );
    final gardenController = GardenController(
      repository: gardenRepository,
      initialState: gardenState,
    );
    _historyController = historyController;
    _gardenController = gardenController;

    return _AppPersistenceBundle(
      settings: settings,
      settingsRepository: settingsRepository,
      historyController: historyController,
      gardenController: gardenController,
    );
  }

  Future<List<FocusSessionRecord>> _loadMigratedFocusHistory({
    required SharedPreferencesFocusHistoryRepository localRepository,
    required FirebaseFocusHistoryRepository firebaseRepository,
  }) async {
    final localRecords = await localRepository.loadRecords();
    final firebaseRecords = await firebaseRepository.loadRecords();
    if (firebaseRecords.isNotEmpty) {
      if (localRecords.isNotEmpty) {
        await localRepository.clearRecords();
      }
      return firebaseRecords;
    }

    if (localRecords.isEmpty) {
      return const [];
    }

    await firebaseRepository.saveRecords(localRecords);
    await localRepository.clearRecords();
    return localRecords;
  }

  Future<GardenState?> _loadMigratedGardenState({
    required SharedPreferencesGardenRepository localRepository,
    required FirebaseGardenRepository firebaseRepository,
  }) async {
    final localState = await localRepository.loadState();
    final firebaseState = await firebaseRepository.loadState();
    if (firebaseState != null) {
      if (localState != null) {
        await localRepository.clearState();
      }
      return firebaseState;
    }

    if (localState == null) {
      return null;
    }

    await firebaseRepository.saveState(localState);
    await localRepository.clearState();
    return localState;
  }
}

class _AppShellContent extends StatelessWidget {
  const _AppShellContent({
    required this.selectedTab,
    required this.onTabSelected,
    required this.bundle,
    required this.language,
    required this.onLanguageChanged,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;
  final _AppPersistenceBundle bundle;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
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
        onTabSelected: onTabSelected,
      ),
      child: IndexedStack(
        index: selectedTab.index,
        children: [
          HomeScreen(
            historyController: bundle.historyController,
            gardenController: bundle.gardenController,
            initialSettings: bundle.settings,
            settingsRepository: bundle.settingsRepository,
            onOpenSpace: () => onTabSelected(AppTab.space),
          ),
          SpaceScreen(gardenController: bundle.gardenController),
          StatsScreen(historyController: bundle.historyController),
          SettingsScreen(
            language: language,
            onLanguageChanged: onLanguageChanged,
          ),
        ],
      ),
    );
  }
}

class _AppPersistenceBundle {
  const _AppPersistenceBundle({
    required this.settings,
    required this.settingsRepository,
    required this.historyController,
    required this.gardenController,
  });

  final FocusTimerSettings settings;
  final FocusSettingsRepository settingsRepository;
  final FocusHistoryController historyController;
  final GardenController gardenController;
}
