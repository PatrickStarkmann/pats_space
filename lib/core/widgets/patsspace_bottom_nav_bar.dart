import 'package:flutter/material.dart';
import 'package:pats_space/app/navigation/app_tab.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';

class PatsspaceBottomNavBar extends StatelessWidget {
  const PatsspaceBottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: AppTab.values.map((tab) {
          final selected = selectedTab == tab;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTabSelected(tab),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Icon(
                tab.icon,
                color: selected ? AppColors.charcoal : AppColors.grayWarm,
                size: selected ? 28 : 26,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
