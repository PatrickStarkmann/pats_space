import 'package:flutter/cupertino.dart';
import 'package:pats_space/features/shared/placeholder_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      icon: CupertinoIcons.chart_bar_alt_fill,
      title: 'Stats',
      subtitle: 'A calm view for focus history and progress.',
    );
  }
}
