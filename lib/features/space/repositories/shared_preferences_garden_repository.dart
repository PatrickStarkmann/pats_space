import 'dart:convert';

import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/garden_repository.dart';
import 'package:pats_space/features/space/repositories/garden_state_json_codec.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesGardenRepository implements GardenRepository {
  const SharedPreferencesGardenRepository(this._preferences);

  static const _stateKey = 'garden_state_v1';
  static const _codec = GardenStateJsonCodec();

  final SharedPreferences _preferences;

  @override
  Future<GardenState?> loadState() async {
    final rawState = _preferences.getString(_stateKey);
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
      _stateKey,
      jsonEncode(_codec.stateToJson(state)),
    );
  }

  Future<void> clearState() {
    return _preferences.remove(_stateKey);
  }
}
