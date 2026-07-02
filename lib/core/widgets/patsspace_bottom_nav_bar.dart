import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pats_space/app/navigation/app_tab.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.08),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.xs,
              AppSpacing.screenHorizontal,
              bottomInset + AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: AppTab.values.map((tab) {
                final selected = selectedTab == tab;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!selected) {
                      AppHaptics.selection();
                    }
                    onTabSelected(tab);
                  },
                  child: SizedBox(
                    width: 52,
                    height: 44,
                    child: PhosphorIcon(
                      selected ? tab.selectedIcon : tab.icon,
                      color: selected ? AppColors.charcoal : AppColors.grayWarm,
                      size: selected ? 28 : 26,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
