import 'dart:convert';
import 'dart:math' as math;

import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_decoration_placement.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';
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
    final ownedDecorations = _decorationsFromJson(json['ownedDecorations']);
    final placedDecorations = json.containsKey('placedDecorations')
        ? _decorationsFromJson(json['placedDecorations'])
        : ownedDecorations;

    return GardenState(
      water: math.max(
        _intValue(json['water']) ?? GardenState.defaultWater,
        GardenState.defaultWater,
      ),
      coins: math.max(
        _intValue(json['coins']) ?? GardenState.defaultCoins,
        GardenState.defaultCoins,
      ),
      unlockedPlantTypes: _plantTypesFromJson(json['unlockedPlantTypes']),
      ownedPotStyles: _potStylesFromJson(json['ownedPotStyles']),
      selectedPotStyle: _storedGroundPotStyle(json['selectedPotStyle']),
      ownedDecorations: ownedDecorations,
      placedDecorations: placedDecorations,
      decorationPlacements: _decorationPlacementsFromJson(
        json['decorationPlacements'],
      ),
      potPlacements: _potPlacementsFromJson(json['potPlacements']),
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
        'unlockedPlantTypes': state.unlockedPlantTypes
            .map((plantType) => plantType.name)
            .toList(),
        'ownedPotStyles': state.ownedPotStyles
            .map((potStyle) => potStyle.name)
            .toList(),
        'selectedPotStyle': state.selectedPotStyle.name,
        'ownedDecorations': state.ownedDecorations
            .map((decoration) => decoration.name)
            .toList(),
        'placedDecorations': state.placedDecorations
            .map((decoration) => decoration.name)
            .toList(),
        'decorationPlacements': state.decorationPlacements.map(
          (decoration, placement) => MapEntry(decoration.name, {
            'x': placement.alignmentX,
            'y': placement.alignmentY,
            'scale': placement.scale,
            'inFront': placement.inFront,
          }),
        ),
        'potPlacements': state.potPlacements.map(
          (index, placement) => MapEntry('$index', {
            'x': placement.alignmentX,
            'y': placement.alignmentY,
          }),
        ),
        'pots': state.pots.map(_potToJson).toList(),
      }),
    );
  }

  GardenPot? _potFromJson(Map<String, dynamic> json) {
    final plantType =
        GardenPlantType.fromStoredName(json['plantType']) ??
        GardenPlantType.fromStoredName(json['plantName']) ??
        GardenPlantType.daisy;

    return GardenPot(
      stage:
          _enumValue(GardenGrowthStage.values, json['stage']) ??
          GardenGrowthStage.empty,
      plantType: plantType,
      coinReward: _intValue(json['coinReward']) ?? plantType.coinReward,
      waterProgress: _intValue(json['waterProgress']) ?? 0,
      bloomCollections: _intValue(json['bloomCollections']) ?? 0,
      bloomCharges: _intValue(json['bloomCharges']) ?? 0,
      lastBloomChargeAtMillis: _intValue(json['lastBloomChargeAtMillis']),
      potStyle: _storedPotStyle(json['potStyle']),
    );
  }

  Map<String, Object?> _potToJson(GardenPot pot) {
    return {
      'stage': pot.stage.name,
      'plantType': pot.plantType.name,
      'plantName': pot.plantName,
      'coinReward': pot.coinReward,
      'waterProgress': pot.waterProgress,
      'bloomCollections': pot.bloomCollections,
      'bloomCharges': pot.bloomCharges,
      'lastBloomChargeAtMillis': pot.lastBloomChargeAtMillis,
      'potStyle': pot.potStyle.name,
    };
  }

  List<GardenPot> _normalizedPots(List<GardenPot> pots) {
    final normalized = pots
        .where((pot) => pot.potStyle != GardenPotStyle.hanging)
        .take(GardenState.maxPotCount)
        .toList();

    while (normalized.length < GardenState.defaultPotCount) {
      normalized.add(const GardenPot.empty());
    }
    return normalized;
  }

  Set<GardenPlantType> _plantTypesFromJson(Object? json) {
    if (json is! List) {
      return GardenPlantType.initiallyUnlocked;
    }

    final plantTypes = json
        .map(GardenPlantType.fromStoredName)
        .whereType<GardenPlantType>()
        .toSet();
    return {...GardenPlantType.initiallyUnlocked, ...plantTypes};
  }

  Set<GardenPotStyle> _potStylesFromJson(Object? json) {
    if (json is! List) {
      return GardenPotStyle.initiallyOwned;
    }

    final potStyles = json
        .map(GardenPotStyle.fromStoredName)
        .whereType<GardenPotStyle>()
        .where(
          (style) =>
              style == GardenPotStyle.classic ||
              GardenPotStyle.shopStyles.contains(style),
        )
        .toSet();
    return {...GardenPotStyle.initiallyOwned, ...potStyles};
  }

  GardenPotStyle _storedGroundPotStyle(Object? json) {
    final style = GardenPotStyle.fromStoredName(json);
    if (style == null || !GardenPotStyle.shopStyles.contains(style)) {
      return GardenPotStyle.classic;
    }

    return style;
  }

  GardenPotStyle _storedPotStyle(Object? json) {
    final style = GardenPotStyle.fromStoredName(json);
    if (style == null) {
      return GardenPotStyle.classic;
    }

    if (GardenPotStyle.shopStyles.contains(style)) {
      return style;
    }

    return GardenPotStyle.classic;
  }

  Set<GardenDecoration> _decorationsFromJson(Object? json) {
    if (json is! List) {
      return {};
    }

    return json
        .map(GardenDecoration.fromStoredName)
        .whereType<GardenDecoration>()
        .toSet();
  }

  Map<GardenDecoration, GardenDecorationPlacement>
  _decorationPlacementsFromJson(Object? json) {
    if (json is! Map) {
      return {};
    }

    final placements = <GardenDecoration, GardenDecorationPlacement>{};
    for (final entry in json.entries) {
      final decoration = GardenDecoration.fromStoredName(entry.key);
      final value = entry.value;
      if (decoration == null || value is! Map) {
        continue;
      }

      final x = _doubleValue(value['x']);
      final y = _doubleValue(value['y']);
      final scale = _doubleValue(value['scale']);
      final inFront = value['inFront'];
      if (x == null || y == null) {
        continue;
      }

      placements[decoration] = GardenDecorationPlacement(
        alignmentX: x.clamp(.08, .92).toDouble(),
        alignmentY: y.clamp(.34, .98).toDouble(),
        scale: (scale ?? 1).clamp(.65, 1.75).toDouble(),
        inFront: inFront is bool ? inFront : false,
      );
    }

    return placements;
  }

  Map<int, GardenDecorationPlacement> _potPlacementsFromJson(Object? json) {
    if (json is! Map) {
      return {};
    }

    final placements = <int, GardenDecorationPlacement>{};
    for (final entry in json.entries) {
      final index = int.tryParse('${entry.key}');
      final value = entry.value;
      if (index == null || value is! Map) {
        continue;
      }

      final x = _doubleValue(value['x']);
      final y = _doubleValue(value['y']);
      if (x == null || y == null) {
        continue;
      }

      placements[index] = GardenDecorationPlacement(
        alignmentX: x.clamp(.08, .92).toDouble(),
        alignmentY: y.clamp(.55, .98).toDouble(),
      );
    }

    return placements;
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

  double? _doubleValue(Object? value) {
    return switch (value) {
      int() => value.toDouble(),
      double() => value,
      _ => null,
    };
  }
}
