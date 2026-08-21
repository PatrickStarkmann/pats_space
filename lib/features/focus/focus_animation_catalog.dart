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

  static const pair03Focus = FocusAnimationSpec(
    frames: AppAssets.focusPair03Focus,
    visualScale: 1.08,
    alignment: Alignment.center,
  );

  static const pair03Break = FocusAnimationSpec(
    frames: AppAssets.focusPair03Break,
    visualScale: 1.08,
    alignment: Alignment.center,
  );

  static const pair04Focus = FocusAnimationSpec(
    frames: AppAssets.focusPair04Focus,
    visualScale: 1.08,
    alignment: Alignment.center,
  );

  static const pair04Break = FocusAnimationSpec(
    frames: AppAssets.focusPair04Break,
    visualScale: 1.08,
    alignment: Alignment.center,
  );

  static const pair05Focus = FocusAnimationSpec(
    frames: AppAssets.focusPair05Focus,
    visualScale: 1.08,
    alignment: Alignment.center,
  );

  static const pair05Break = FocusAnimationSpec(
    frames: AppAssets.focusPair05Break,
    visualScale: 1.08,
    alignment: Alignment.center,
  );

  static const pair06Focus = FocusAnimationSpec(
    frames: AppAssets.focusPair06Focus,
    visualScale: 1.24,
    alignment: Alignment.center,
  );

  static const pair06Break = FocusAnimationSpec(
    frames: AppAssets.focusPair06Break,
    visualScale: 1.24,
    alignment: Alignment.center,
  );

  static FocusAnimationSpec focusSpec(FocusAnimationPair pair) {
    return switch (pair) {
      FocusAnimationPair.shuffle => pair01Focus,
      FocusAnimationPair.standard => pair01Focus,
      FocusAnimationPair.pair02 => pair02Focus,
      FocusAnimationPair.pair03 => pair03Focus,
      FocusAnimationPair.pair04 => pair04Focus,
      FocusAnimationPair.pair05 => pair05Focus,
      FocusAnimationPair.pair06 => pair06Focus,
    };
  }

  static FocusAnimationSpec breakSpec(FocusAnimationPair pair) {
    return switch (pair) {
      FocusAnimationPair.shuffle => pair01Break,
      FocusAnimationPair.standard => pair01Break,
      FocusAnimationPair.pair02 => pair02Break,
      FocusAnimationPair.pair03 => pair03Break,
      FocusAnimationPair.pair04 => pair04Break,
      FocusAnimationPair.pair05 => pair05Break,
      FocusAnimationPair.pair06 => pair06Break,
    };
  }

  static List<String> get allFrames {
    return [
      ...pair01Focus.frames,
      ...pair01Break.frames,
      ...pair02Focus.frames,
      ...pair02Break.frames,
      ...pair03Focus.frames,
      ...pair03Break.frames,
      ...pair04Focus.frames,
      ...pair04Break.frames,
      ...pair05Focus.frames,
      ...pair05Break.frames,
      ...pair06Focus.frames,
      ...pair06Break.frames,
    ];
  }
}
