import 'dart:convert';

import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/repositories/focus_history_json_codec.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingFocusReward {
  const PendingFocusReward({
    required this.id,
    required this.waterReward,
    this.record,
  });

  final String id;
  final int waterReward;
  final FocusSessionRecord? record;
}

class PendingFocusRewardRepository {
  const PendingFocusRewardRepository(this._preferences);

  static const _rewardsKey = 'pending_focus_rewards_v1';
  static const _codec = FocusHistoryJsonCodec();

  final SharedPreferences _preferences;

  Future<List<PendingFocusReward>> loadRewards() async {
    final rawRewards = _preferences.getString(_rewardsKey);
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

  Future<void> addSessionReward(FocusSessionRecord record) async {
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
        record: record,
      ),
    ]);
  }

  Future<void> addWaterReward(int waterReward) async {
    if (waterReward <= 0) {
      return;
    }

    final rewards = await loadRewards();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _saveRewards([
      ...rewards,
      PendingFocusReward(id: id, waterReward: waterReward),
    ]);
  }

  Future<void> clearRewards() {
    return _preferences.remove(_rewardsKey);
  }

  Future<void> _saveRewards(List<PendingFocusReward> rewards) {
    return _preferences.setString(
      _rewardsKey,
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
    return PendingFocusReward(id: id, waterReward: waterReward, record: record);
  }

  Map<String, Object?> _rewardToJson(PendingFocusReward reward) {
    return {
      'id': reward.id,
      'waterReward': reward.waterReward,
      if (reward.record != null) 'record': _codec.recordToJson(reward.record!),
    };
  }
}
