import 'dart:convert';

import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/garden_repository.dart';
import 'package:pats_space/features/space/repositories/garden_state_json_codec.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesGardenRepository implements GardenRepository {
  const SharedPreferencesGardenRepository(
    this._preferences, {
    required String userId,
  }) : _userId = userId;

  static const _stateKey = 'garden_state_v1';
  static const _codec = GardenStateJsonCodec();

  final SharedPreferences _preferences;
  final String _userId;

  String get _scopedStateKey => '$_stateKey:$_userId';

  @override
  Future<GardenState?> loadState() async {
    await migrateLegacyStateIfNeeded(_preferences, userId: _userId);
    final rawState = _preferences.getString(_scopedStateKey);
    if (rawState == null) {
      return null;
    }

    final json = jsonDecode(rawState);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    return _codec.stateFromJson(json);
  }

  @override
  Future<void> saveState(GardenState state) {
    return _preferences.setString(
      _scopedStateKey,
      jsonEncode(_codec.stateToJson(state)),
    );
  }

  Future<void> clearState() {
    return clearStateForUser(_preferences, userId: _userId);
  }

  static Future<void> migrateLegacyStateIfNeeded(
    SharedPreferences preferences, {
    required String userId,
  }) async {
    final scopedKey = '$_stateKey:$userId';
    if (preferences.containsKey(scopedKey)) {
      return;
    }

    final legacyState = preferences.getString(_stateKey);
    if (legacyState == null) {
      return;
    }

    await preferences.setString(scopedKey, legacyState);
    await preferences.remove(_stateKey);
  }

  static Future<void> clearStateForUser(
    SharedPreferences preferences, {
    required String userId,
  }) {
    return preferences.remove('$_stateKey:$userId');
  }

  /// Removes the pre-account cache format as part of a full account wipe.
  ///
  /// Legacy data had no user id in its key. Leaving it behind could otherwise
  /// be migrated into the next anonymous account created on this device.
  static Future<void> clearLegacyState(SharedPreferences preferences) {
    return preferences.remove(_stateKey);
  }
}
