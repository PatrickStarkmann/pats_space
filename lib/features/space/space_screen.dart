import 'package:flutter/cupertino.dart';
import 'package:pats_space/features/shared/placeholder_screen.dart';

class SpaceScreen extends StatelessWidget {
  const SpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      icon: CupertinoIcons.sparkles,
      title: 'Space',
      subtitle: 'Your quiet focus space will live here.',
    );
  }
}
