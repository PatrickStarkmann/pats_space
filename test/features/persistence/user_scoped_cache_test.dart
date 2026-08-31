import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_tag.dart';
import 'package:pats_space/features/focus/repositories/focus_history_json_codec.dart';
import 'package:pats_space/features/focus/repositories/pending_focus_reward_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_history_repository.dart';
import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/garden_state_json_codec.dart';
import 'package:pats_space/features/space/repositories/shared_preferences_garden_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('user-scoped local cache', () {
    test(
      'focus history migrates legacy data to the current user only',
      () async {
        final record = FocusSessionRecord(
          id: 'record-1',
          tag: const FocusTag(
            name: 'Study',
            accentColor: FocusAccentColor.sunshine,
            badgeIcon: FocusBadgeIcon.character,
          ),
          mode: FocusMode.pomodoro,
          focusDuration: const Duration(minutes: 25),
          startedAt: DateTime(2026, 7, 20, 9),
          completedAt: DateTime(2026, 7, 20, 9, 25),
          animationPair: FocusAnimationPair.standard,
          waterReward: 5,
        );
        const codec = FocusHistoryJsonCodec();
        SharedPreferences.setMockInitialValues({
          'focus_history_records_v1': jsonEncode([codec.recordToJson(record)]),
        });
        final preferences = await SharedPreferences.getInstance();

        final userARepository = SharedPreferencesFocusHistoryRepository(
          preferences,
          userId: 'user-a',
        );
        final userBRepository = SharedPreferencesFocusHistoryRepository(
          preferences,
          userId: 'user-b',
        );

        expect(await userARepository.loadRecords(), hasLength(1));
        expect(await userBRepository.loadRecords(), isEmpty);
        expect(preferences.containsKey('focus_history_records_v1'), isFalse);
      },
    );

    test(
      'garden state is isolated per user and clears only one user',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final userARepository = SharedPreferencesGardenRepository(
          preferences,
          userId: 'user-a',
        );
        final userBRepository = SharedPreferencesGardenRepository(
          preferences,
          userId: 'user-b',
        );

        await userARepository.saveState(
          GardenState.initial().copyWith(water: 12, totalBlooms: 4),
        );

        expect((await userARepository.loadState())?.water, 12);
        expect(await userBRepository.loadState(), isNull);

        await SharedPreferencesGardenRepository.clearStateForUser(
          preferences,
          userId: 'user-a',
        );

        expect(await userARepository.loadState(), isNull);
      },
    );

    test('clearing a deleted garden also removes the legacy cache', () async {
      const codec = GardenStateJsonCodec();
      SharedPreferences.setMockInitialValues({
        'garden_state_v1': jsonEncode(codec.stateToJson(GardenState.initial())),
      });
      final preferences = await SharedPreferences.getInstance();

      await SharedPreferencesGardenRepository.clearLegacyState(preferences);

      final newUserRepository = SharedPreferencesGardenRepository(
        preferences,
        userId: 'new-user',
      );
      expect(await newUserRepository.loadState(), isNull);
    });

    test('pending rewards migrate legacy data to scoped storage', () async {
      const codec = GardenStateJsonCodec();
      SharedPreferences.setMockInitialValues({
        'pending_focus_rewards_v1': jsonEncode([
          {'id': 'reward-1', 'waterReward': 3},
        ]),
        'garden_state_v1': jsonEncode(
          codec.stateToJson(GardenState.initial().copyWith(coins: 7)),
        ),
      });
      final preferences = await SharedPreferences.getInstance();
      final rewardsRepository = PendingFocusRewardRepository(
        preferences,
        userId: 'user-a',
      );
      final gardenRepository = SharedPreferencesGardenRepository(
        preferences,
        userId: 'user-a',
      );

      expect(await rewardsRepository.loadRewards(), hasLength(1));
      expect((await gardenRepository.loadState())?.coins, 7);
      expect(preferences.containsKey('pending_focus_rewards_v1'), isFalse);
      expect(preferences.containsKey('garden_state_v1'), isFalse);
    });

    test(
      'pending rewards keep whether water was already applied locally',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final rewardsRepository = PendingFocusRewardRepository(
          preferences,
          userId: 'user-a',
        );

        await rewardsRepository.addWaterReward(2, appliedLocally: true);

        final rewards = await rewardsRepository.loadRewards();
        expect(rewards, hasLength(1));
        expect(rewards.single.waterReward, 2);
        expect(rewards.single.appliedLocally, isTrue);
      },
    );
  });
}
