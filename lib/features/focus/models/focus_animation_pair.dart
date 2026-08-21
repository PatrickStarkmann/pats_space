enum FocusAnimationPair {
  shuffle,
  standard,
  pair02,
  pair03,
  pair04,
  pair05,
  pair06;

  String get label {
    return switch (this) {
      FocusAnimationPair.shuffle => 'Shuffle',
      FocusAnimationPair.standard => 'Standard',
      FocusAnimationPair.pair02 => 'Set 2',
      FocusAnimationPair.pair03 => 'Set 3',
      FocusAnimationPair.pair04 => 'Set 4',
      FocusAnimationPair.pair05 => 'Set 5',
      FocusAnimationPair.pair06 => 'Set 6',
    };
  }
}
