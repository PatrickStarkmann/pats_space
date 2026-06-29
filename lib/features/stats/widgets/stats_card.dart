import 'package:flutter/widgets.dart';
import 'package:pats_space/core/theme/app_colors.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class CardTitleMarker extends StatelessWidget {
  const CardTitleMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const SizedBox(width: 6, height: 24),
    );
  }
}
