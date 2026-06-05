import 'package:flutter/material.dart';
import 'package:pats_space/app/navigation/app_tab.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/widgets/app_scaffold.dart';
import 'package:pats_space/core/widgets/patsspace_bottom_nav_bar.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/home/home_screen.dart';
import 'package:pats_space/features/settings/settings_screen.dart';
import 'package:pats_space/features/space/space_screen.dart';
import 'package:pats_space/features/stats/stats_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _selectedTab = AppTab.home;
  late final FocusHistoryController _historyController;

  @override
  void initState() {
    super.initState();
    _historyController = FocusHistoryController();
  }

  @override
  void dispose() {
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: _selectedTab == AppTab.stats
          ? const Color(0xFFF5F4FA)
          : AppColors.background,
      horizontalPadding: _selectedTab == AppTab.stats
          ? AppSpacing.sm
          : AppSpacing.screenHorizontal,
      bottomNavigation: PatsspaceBottomNavBar(
        selectedTab: _selectedTab,
        onTabSelected: (tab) {
          setState(() => _selectedTab = tab);
        },
      ),
      child: IndexedStack(
        index: _selectedTab.index,
        children: [
          HomeScreen(historyController: _historyController),
          const SpaceScreen(),
          StatsScreen(historyController: _historyController),
          const SettingsScreen(),
        ],
      ),
    );
  }
}
