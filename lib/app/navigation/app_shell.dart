import 'package:flutter/material.dart';
import 'package:pats_space/app/navigation/app_tab.dart';
import 'package:pats_space/core/widgets/app_scaffold.dart';
import 'package:pats_space/core/widgets/patsspace_bottom_nav_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigation: PatsspaceBottomNavBar(
        selectedTab: _selectedTab,
        onTabSelected: (tab) {
          setState(() => _selectedTab = tab);
        },
      ),
      child: IndexedStack(
        index: _selectedTab.index,
        children: const [
          HomeScreen(),
          SpaceScreen(),
          StatsScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }
}
