import 'dart:convert';

import 'package:pats_space/features/focus/models/active_timer_state.dart';
import 'package:pats_space/features/focus/repositories/active_timer_state_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesActiveTimerStateRepository
    implements ActiveTimerStateRepository {
  SharedPreferencesActiveTimerStateRepository(
    this._preferences, {
    required this.userId,
  });

  static const _keyPrefix = 'focus.active_timer.v1';

  final SharedPreferences _preferences;
  final String userId;

  String get _key => '$_keyPrefix.$userId';

  @override
  Future<ActiveTimerState?> load() async {
    final raw = _preferences.getString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic>
          ? ActiveTimerState.fromJson(json)
          : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(ActiveTimerState state) =>
      _preferences.setString(_key, jsonEncode(state.toJson()));

  @override
  Future<void> clear() => _preferences.remove(_key);
}
