import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child, this.bottomNavigation});

  final Widget child;
  final Widget? bottomNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                children: [
                  Expanded(child: child),
                  ?bottomNavigation,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
