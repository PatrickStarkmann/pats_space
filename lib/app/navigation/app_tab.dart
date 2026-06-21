import 'package:flutter/cupertino.dart';

enum AppTab {
  home(label: 'Home', icon: CupertinoIcons.timer),
  space(label: 'Space', icon: CupertinoIcons.sparkles),
  shop(label: 'Shop', icon: CupertinoIcons.bag_fill),
  stats(label: 'Stats', icon: CupertinoIcons.chart_bar_alt_fill),
  settings(label: 'Settings', icon: CupertinoIcons.gear_alt);

  const AppTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
