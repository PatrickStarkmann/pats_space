enum FocusAnimationPair {
  standard,
  pair02;

  String get label {
    return switch (this) {
      FocusAnimationPair.standard => 'Standard',
      FocusAnimationPair.pair02 => 'Set 2',
    };
  }
}
