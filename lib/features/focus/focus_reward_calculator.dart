class FocusRewardCalculator {
  const FocusRewardCalculator._();

  static const waterInterval = Duration(minutes: 5);

  static int waterForCompletedFocus(Duration focusDuration) {
    if (focusDuration <= Duration.zero) {
      return 0;
    }

    return focusDuration.inSeconds ~/ waterInterval.inSeconds;
  }

  static int waterForPartialFocus(Duration focusDuration) {
    if (focusDuration <= Duration.zero) {
      return 0;
    }

    return focusDuration.inSeconds ~/ waterInterval.inSeconds;
  }
}
