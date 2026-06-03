import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = '.SF Pro Display';

  static const timer = TextStyle(
    color: AppColors.charcoal,
    fontSize: 96,
    fontWeight: FontWeight.w200,
    height: 1,
    letterSpacing: 0,
  );

  static const title = TextStyle(
    color: AppColors.charcoal,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.16,
    letterSpacing: 0,
  );

  static const headline = TextStyle(
    color: AppColors.charcoal,
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    color: AppColors.charcoal,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0,
  );

  static const bodyMuted = TextStyle(
    color: AppColors.grayWarm,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0,
  );

  static const caption = TextStyle(
    color: AppColors.grayWarm,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
  );

  static const button = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 0,
  );
}
