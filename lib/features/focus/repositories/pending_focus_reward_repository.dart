import 'dart:convert';

import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/repositories/focus_history_json_codec.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingFocusReward {
  const PendingFocusReward({
    required this.id,
    required this.waterReward,
    this.appliedLocally = false,
    this.record,
  });

  final String id;
  final int waterReward;
  final bool appliedLocally;
  final FocusSessionRecord? record;
}

class PendingFocusRewardRepository {
  const PendingFocusRewardRepository(
    this._preferences, {
    required String userId,
  }) : _userId = userId;

  static const _rewardsKey = 'pending_focus_rewards_v1';
  static const _codec = FocusHistoryJsonCodec();

  final SharedPreferences _preferences;
  final String _userId;

  String get _scopedRewardsKey => '$_rewardsKey:$_userId';

  Future<List<PendingFocusReward>> loadRewards() async {
    await migrateLegacyRewardsIfNeeded(_preferences, userId: _userId);
    final rawRewards = _preferences.getString(_scopedRewardsKey);
    if (rawRewards == null) {
      return const [];
    }

    final json = jsonDecode(rawRewards);
    if (json is! List) {
      return const [];
    }

    return json
        .whereType<Map<String, dynamic>>()
        .map(_rewardFromJson)
        .whereType<PendingFocusReward>()
        .toList();
  }

  Future<void> addSessionReward(
    FocusSessionRecord record, {
    bool appliedLocally = false,
  }) async {
    if (record.waterReward <= 0) {
      return;
    }

    final rewards = await loadRewards();
    if (rewards.any((reward) => reward.id == record.id)) {
      return;
    }

    await _saveRewards([
      ...rewards,
      PendingFocusReward(
        id: record.id,
        waterReward: record.waterReward,
        appliedLocally: appliedLocally,
        record: record,
      ),
    ]);
  }

  Future<void> addWaterReward(
    int waterReward, {
    bool appliedLocally = false,
  }) async {
    if (waterReward <= 0) {
      return;
    }

    final rewards = await loadRewards();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _saveRewards([
      ...rewards,
      PendingFocusReward(
        id: id,
        waterReward: waterReward,
        appliedLocally: appliedLocally,
      ),
    ]);
  }

  Future<void> clearRewards() {
    return clearRewardsForUser(_preferences, userId: _userId);
  }

  Future<void> _saveRewards(List<PendingFocusReward> rewards) {
    return _preferences.setString(
      _scopedRewardsKey,
      jsonEncode(rewards.map(_rewardToJson).toList()),
    );
  }

  PendingFocusReward? _rewardFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final waterReward = json['waterReward'];
    if (id is! String || waterReward is! int || waterReward <= 0) {
      return null;
    }

    final recordJson = json['record'];
    final record = recordJson is Map<String, dynamic>
        ? _codec.recordFromJson(recordJson)
        : null;
    return PendingFocusReward(
      id: id,
      waterReward: waterReward,
      appliedLocally: json['appliedLocally'] == true,
      record: record,
    );
  }

  Map<String, Object?> _rewardToJson(PendingFocusReward reward) {
    return {
      'id': reward.id,
      'waterReward': reward.waterReward,
      'appliedLocally': reward.appliedLocally,
      if (reward.record != null) 'record': _codec.recordToJson(reward.record!),
    };
  }

  static Future<void> migrateLegacyRewardsIfNeeded(
    SharedPreferences preferences, {
    required String userId,
  }) async {
    final scopedKey = '$_rewardsKey:$userId';
    if (preferences.containsKey(scopedKey)) {
      return;
    }

    final legacyRewards = preferences.getString(_rewardsKey);
    if (legacyRewards == null) {
      return;
    }

    await preferences.setString(scopedKey, legacyRewards);
    await preferences.remove(_rewardsKey);
  }

  static Future<void> clearRewardsForUser(
    SharedPreferences preferences, {
    required String userId,
  }) {
    return preferences.remove('$_rewardsKey:$userId');
  }
}
