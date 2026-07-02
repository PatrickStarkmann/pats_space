import 'package:phosphor_flutter/phosphor_flutter.dart';

enum AppTab {
  home(
    label: 'Home',
    icon: PhosphorIconsRegular.timer,
    selectedIcon: PhosphorIconsFill.timer,
  ),
  space(
    label: 'Space',
    icon: PhosphorIconsRegular.plant,
    selectedIcon: PhosphorIconsFill.plant,
  ),
  stats(
    label: 'Stats',
    icon: PhosphorIconsRegular.chartBar,
    selectedIcon: PhosphorIconsFill.chartBar,
  ),
  settings(
    label: 'Settings',
    icon: PhosphorIconsRegular.gear,
    selectedIcon: PhosphorIconsFill.gear,
  );

  const AppTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final PhosphorIconData icon;
  final PhosphorIconData selectedIcon;
}
