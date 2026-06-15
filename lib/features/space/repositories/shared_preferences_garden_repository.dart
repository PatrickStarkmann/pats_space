import 'dart:convert';
import 'dart:math' as math;

import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/garden_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesGardenRepository implements GardenRepository {
  const SharedPreferencesGardenRepository(this._preferences);

  static const _stateKey = 'garden_state_v1';

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

    final potsJson = json['pots'];
    if (potsJson is! List) {
      return null;
    }

    final decodedPots = potsJson
        .whereType<Map<String, dynamic>>()
        .map(_potFromJson)
        .whereType<GardenPot>()
        .toList();

    if (decodedPots.isEmpty) {
      return null;
    }
    final pots = _normalizedPots(decodedPots);

    return GardenState(
      water: math.max(
        _intValue(json['water']) ?? GardenState.defaultWater,
        GardenState.defaultWater,
      ),
      coins: _intValue(json['coins']) ?? GardenState.defaultCoins,
      pots: pots,
    );
  }

  @override
  Future<void> saveState(GardenState state) {
    return _preferences.setString(
      _stateKey,
      jsonEncode({
        'water': state.water,
        'coins': state.coins,
        'pots': state.pots.map(_potToJson).toList(),
      }),
    );
  }

  GardenPot? _potFromJson(Map<String, dynamic> json) {
    return GardenPot(
      stage:
          _enumValue(GardenGrowthStage.values, json['stage']) ??
          GardenGrowthStage.empty,
      plantName: json['plantName'] as String? ?? 'Daisy',
      coinReward: _intValue(json['coinReward']) ?? 5,
      waterProgress: _intValue(json['waterProgress']) ?? 0,
      bloomCollections: _intValue(json['bloomCollections']) ?? 0,
    );
  }

  Map<String, Object?> _potToJson(GardenPot pot) {
    return {
      'stage': pot.stage.name,
      'plantName': pot.plantName,
      'coinReward': pot.coinReward,
      'waterProgress': pot.waterProgress,
      'bloomCollections': pot.bloomCollections,
    };
  }

  List<GardenPot> _normalizedPots(List<GardenPot> pots) {
    final normalized = pots.take(GardenState.defaultPotCount).toList();
    while (normalized.length < GardenState.defaultPotCount) {
      normalized.add(const GardenPot.empty());
    }
    return normalized;
  }

  T? _enumValue<T extends Enum>(List<T> values, Object? name) {
    if (name is! String) {
      return null;
    }

    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }

  int? _intValue(Object? value) {
    return switch (value) {
      int() => value,
      num() => value.toInt(),
      _ => null,
    };
  }
}
