import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.bottomNavigation,
    this.backgroundColor = AppColors.background,
    this.horizontalPadding = AppSpacing.screenHorizontal,
  });

  final Widget child;
  final Widget? bottomNavigation;
  final Color backgroundColor;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final maxContentWidth = tablet ? 1024.0 : AppSpacing.maxContentWidth;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  key: const ValueKey('app-scaffold-content'),
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
            if (bottomNavigation != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: bottomNavigation!,
              ),
          ],
        ),
      ),
    );
  }
}
