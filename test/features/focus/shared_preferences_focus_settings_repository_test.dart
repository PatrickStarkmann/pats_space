import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('keeps focus settings isolated between users', () async {
    final preferences = await SharedPreferences.getInstance();
    final firstUser = SharedPreferencesFocusSettingsRepository(
      preferences,
      userId: 'first-user',
    );
    final secondUser = SharedPreferencesFocusSettingsRepository(
      preferences,
      userId: 'second-user',
    );
    final firstUserSettings = FocusTimerController.defaultSettings.copyWith(
      mode: FocusMode.stopwatch,
      animationPair: FocusAnimationPair.shuffle,
    );

    await firstUser.saveSettings(firstUserSettings);

    expect((await firstUser.loadSettings())?.mode, FocusMode.stopwatch);
    expect(
      (await firstUser.loadSettings())?.animationPair,
      FocusAnimationPair.shuffle,
    );
    expect(await secondUser.loadSettings(), isNull);
  });

  test('does not assign legacy global settings to a new user', () async {
    SharedPreferences.setMockInitialValues({
      'focus_settings_v1': '{"mode":"stopwatch","animationPair":"shuffle"}',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesFocusSettingsRepository(
      preferences,
      userId: 'new-user',
    );

    expect(await repository.loadSettings(), isNull);
  });
}
