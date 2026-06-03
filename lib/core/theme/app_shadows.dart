import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';

class AppShadows {
  const AppShadows._();

  static const soft = [
    BoxShadow(color: Color(0x1A202124), blurRadius: 24, offset: Offset(0, 12)),
  ];

  static const button = [
    BoxShadow(color: Color(0x269CAF88), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const none = <BoxShadow>[];

  static BoxBorder hairlineBorder = Border.all(color: AppColors.graySoft);
}
