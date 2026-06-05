import 'package:flutter/widgets.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_animation_spec.dart';

class FocusAnimationCatalog {
  const FocusAnimationCatalog._();

  static const pair01Focus = FocusAnimationSpec(
    frames: AppAssets.focusPair01Focus,
    visualScale: 1.32,
    alignment: Alignment.center,
    verticalOffset: 24,
  );

  static const pair01Break = FocusAnimationSpec(
    frames: AppAssets.focusPair01Break,
    visualScale: 1.1,
    alignment: Alignment.center,
    verticalOffset: 24,
  );

  static const pair02Focus = FocusAnimationSpec(
    frames: AppAssets.focusPair02Focus,
    visualScale: 1.08,
    alignment: Alignment.center,
  );

  static const pair02Break = FocusAnimationSpec(
    frames: AppAssets.focusPair02Break,
    visualScale: 1.08,
    alignment: Alignment.center,
  );

  static FocusAnimationSpec focusSpec(FocusAnimationPair pair) {
    return switch (pair) {
      FocusAnimationPair.standard => pair01Focus,
      FocusAnimationPair.pair02 => pair02Focus,
    };
  }

  static FocusAnimationSpec breakSpec(FocusAnimationPair pair) {
    return switch (pair) {
      FocusAnimationPair.standard => pair01Break,
      FocusAnimationPair.pair02 => pair02Break,
    };
  }

  static List<String> get allFrames {
    return [
      ...pair01Focus.frames,
      ...pair01Break.frames,
      ...pair02Focus.frames,
      ...pair02Break.frames,
    ];
  }
}
