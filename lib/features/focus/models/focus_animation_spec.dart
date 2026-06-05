import 'package:flutter/widgets.dart';

class FocusAnimationSpec {
  const FocusAnimationSpec({
    required this.frames,
    this.visualScale = 1,
    this.alignment = Alignment.center,
    this.verticalOffset = 0,
  });

  final List<String> frames;
  final double visualScale;
  final Alignment alignment;
  final double verticalOffset;
}
