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
  late final Future<_FocusPersistenceBundle> _persistenceFuture;
  FocusHistoryController? _historyController;

  @override
  void initState() {
    super.initState();
    _persistenceFuture = _loadPersistence();
  }

  @override
  void dispose() {
    _historyController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FocusPersistenceBundle>(
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

  Future<_FocusPersistenceBundle> _loadPersistence() async {
    final preferences = await SharedPreferences.getInstance();
    final settingsRepository = SharedPreferencesFocusSettingsRepository(
      preferences,
    );
    final historyRepository = SharedPreferencesFocusHistoryRepository(
      preferences,
    );
    final settings =
        await settingsRepository.loadSettings() ??
        FocusTimerController.defaultSettings;
    final records = await historyRepository.loadRecords();
    final historyController = FocusHistoryController(
      repository: historyRepository,
      initialRecords: records,
    );
    _historyController = historyController;

    return _FocusPersistenceBundle(
      settings: settings,
      settingsRepository: settingsRepository,
      historyController: historyController,
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
  final _FocusPersistenceBundle bundle;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: selectedTab == AppTab.stats
          ? const Color(0xFFF5F4FA)
          : AppColors.background,
      horizontalPadding: selectedTab == AppTab.stats
          ? AppSpacing.sm
          : AppSpacing.screenHorizontal,
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
          const SpaceScreen(),
          StatsScreen(historyController: bundle.historyController),
          const SettingsScreen(),
        ],
      ),
    );
  }
}

class _FocusPersistenceBundle {
  const _FocusPersistenceBundle({
    required this.settings,
    required this.settingsRepository,
    required this.historyController,
  });

  final FocusTimerSettings settings;
  final FocusSettingsRepository settingsRepository;
  final FocusHistoryController historyController;
}
