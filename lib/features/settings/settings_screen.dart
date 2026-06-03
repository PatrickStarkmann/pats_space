import 'package:flutter/cupertino.dart';
import 'package:pats_space/features/shared/placeholder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      icon: CupertinoIcons.gear_alt,
      title: 'Settings',
      subtitle: 'Preferences and account options will appear here.',
    );
  }
}
