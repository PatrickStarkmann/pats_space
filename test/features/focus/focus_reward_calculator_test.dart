import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/focus/focus_reward_calculator.dart';

void main() {
  group('FocusRewardCalculator', () {
    test('does not reward focus below five minutes', () {
      expect(
        FocusRewardCalculator.waterForCompletedFocus(
          const Duration(minutes: 4, seconds: 59),
        ),
        0,
      );
      expect(
        FocusRewardCalculator.waterForPartialFocus(
          const Duration(minutes: 4, seconds: 59),
        ),
        0,
      );
    });

    test('rewards one water per full five minute block', () {
      expect(
        FocusRewardCalculator.waterForCompletedFocus(
          const Duration(minutes: 5),
        ),
        1,
      );
      expect(
        FocusRewardCalculator.waterForCompletedFocus(
          const Duration(minutes: 14, seconds: 59),
        ),
        2,
      );
      expect(
        FocusRewardCalculator.waterForPartialFocus(const Duration(minutes: 25)),
        5,
      );
    });
  });
}
