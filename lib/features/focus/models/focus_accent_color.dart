import 'package:flutter/material.dart';

enum FocusAccentColor {
  sunshine,
  sage,
  coral,
  sky;

  Color get color {
    return switch (this) {
      FocusAccentColor.sunshine => const Color(0xFFF6D23A),
      FocusAccentColor.sage => const Color(0xFF9CAF88),
      FocusAccentColor.coral => const Color(0xFFF47C7C),
      FocusAccentColor.sky => const Color(0xFF8AB7D8),
    };
  }

  Color get softColor {
    return Color.lerp(color, Colors.white, 0.72)!;
  }
}
