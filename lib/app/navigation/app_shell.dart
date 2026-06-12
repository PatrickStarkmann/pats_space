import 'package:flutter/cupertino.dart';
import 'package:pats_space/app/navigation/app_tab.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/widgets/app_scaffold.dart';
import 'package:pats_space/core/widgets/patsspace_bottom_nav_bar.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/focus/repositories/focus_settings_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_settings_repository.dart';
import 'package:pats_space/features/home/home_screen.dart';
import 'package:pats_space/features/settings/settings_screen.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/repositories/shared_preferences_garden_repository.dart';
import 'package:pats_space/features/space/space_screen.dart';
import 'package:pats_space/features/stats/stats_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _selectedTab = AppTab.home;
  late final Future<_AppPersistenceBundle> _persistenceFuture;
  FocusHistoryController? _historyController;
  GardenController? _gardenController;

  @override
  void initState() {
    super.initState();
    _persistenceFuture = _loadPersistence();
  }

  @override
  void dispose() {
    _historyController?.dispose();
    _gardenController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppPersistenceBundle>(
      future: _persistenceFuture,
      builder: (context, snapshot) {
        final bundle = snapshot.data;
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
        );
      },
    );
  }

  Future<_AppPersistenceBundle> _loadPersistence() async {
    final preferences = await SharedPreferences.getInstance();
    final settingsRepository = SharedPreferencesFocusSettingsRepository(
      preferences,
    );
    final historyRepository = SharedPreferencesFocusHistoryRepository(
      preferences,
    );
    final gardenRepository = SharedPreferencesGardenRepository(preferences);
    final settings =
        await settingsRepository.loadSettings() ??
        FocusTimerController.defaultSettings;
    final records = await historyRepository.loadRecords();
    final gardenState = await gardenRepository.loadState();
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
}

class _AppShellContent extends StatelessWidget {
  const _AppShellContent({
    required this.selectedTab,
    required this.onTabSelected,
    required this.bundle,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;
  final _AppPersistenceBundle bundle;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: selectedTab == AppTab.stats
          ? const Color(0xFFF5F4FA)
          : AppColors.background,
      horizontalPadding: switch (selectedTab) {
        AppTab.stats => AppSpacing.sm,
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
            initialSettings: bundle.settings,
            settingsRepository: bundle.settingsRepository,
          ),
          SpaceScreen(gardenController: bundle.gardenController),
          StatsScreen(historyController: bundle.historyController),
          const SettingsScreen(),
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
