import 'dart:ui';

import 'package:flutter/cupertino.dart';
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
    this.enabled = true,
    this.showSettingsIndicator = false,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;
  final bool enabled;
  final bool showSettingsIndicator;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.08),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: tablet ? 600 : AppSpacing.maxContentWidth,
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
                      onTap: enabled
                          ? () {
                              if (!selected) {
                                AppHaptics.selection();
                              }
                              onTabSelected(tab);
                            }
                          : null,
                      child: SizedBox(
                        width: 52,
                        height: 44,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            PhosphorIcon(
                              selected ? tab.selectedIcon : tab.icon,
                              color: selected
                                  ? AppColors.charcoal
                                  : AppColors.grayWarm,
                              size: selected ? 28 : 26,
                            ),
                            if (tab == AppTab.settings && showSettingsIndicator)
                              Positioned(
                                top: 2,
                                right: 5,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemRed,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.surface,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
