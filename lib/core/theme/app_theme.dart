import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sage,
        brightness: Brightness.light,
        primary: AppColors.sage,
        surface: AppColors.surface,
      ),
      fontFamily: AppTextStyles.fontFamily,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.timer,
        titleLarge: AppTextStyles.title,
        headlineMedium: AppTextStyles.headline,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodyMuted,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.caption,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.sage,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: CupertinoTextThemeData(primaryColor: AppColors.charcoal),
      ),
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      useMaterial3: true,
    );
  }
}
