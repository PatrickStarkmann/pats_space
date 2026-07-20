import 'dart:math' as math;

import 'package:pats_space/features/space/models/garden_area.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_decoration_placement.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';
import 'package:pats_space/features/space/models/garden_state.dart';

class GardenStateJsonCodec {
  const GardenStateJsonCodec();

  GardenState? stateFromJson(Map<String, dynamic> json) {
    final potsJson = json['pots'];
    final decodedPots = potsJson is List
        ? potsJson
              .whereType<Map<String, dynamic>>()
              .map(_potFromJson)
              .whereType<GardenPot>()
              .toList()
        : const <GardenPot>[];
    final pots = decodedPots.isEmpty
        ? _defaultPots(GardenArea.main)
        : _normalizedPots(decodedPots, GardenArea.main);
    final activeArea =
        GardenArea.fromStoredName(json['activeArea']) ?? GardenArea.main;
    final ownedDecorations = _decorationsFromJson(json['ownedDecorations']);
    final placedDecorations = json.containsKey('placedDecorations')
        ? _decorationsFromJson(json['placedDecorations'])
        : ownedDecorations;
    final potsByArea = _potsByAreaFromJson(json['potsByArea'], pots);
    final placedDecorationsByArea = _decorationsByAreaFromJson(
      json['placedDecorationsByArea'],
      placedDecorations,
    );
    final decorationPlacementsByArea = _decorationPlacementsByAreaFromJson(
      json['decorationPlacementsByArea'],
      _decorationPlacementsFromJson(json['decorationPlacements']),
    );
    final potPlacementsByArea = _potPlacementsByAreaFromJson(
      json['potPlacementsByArea'],
      _potPlacementsFromJson(json['potPlacements']),
    );

    return GardenState(
      water: math.max(
        _intValue(json['water']) ?? GardenState.defaultWater,
        GardenState.defaultWater,
      ),
      coins: math.max(
        _intValue(json['coins']) ?? GardenState.defaultCoins,
        GardenState.defaultCoins,
      ),
      totalBlooms: math.max(_intValue(json['totalBlooms']) ?? 0, 0),
      activeArea: activeArea,
      unlockedPlantTypes: _plantTypesFromJson(json['unlockedPlantTypes']),
      ownedPotStyles: _potStylesFromJson(json['ownedPotStyles']),
      ownedDecorations: ownedDecorations,
      placedDecorations: placedDecorations,
      placedDecorationsByArea: placedDecorationsByArea,
      decorationPlacements: _decorationPlacementsFromJson(
        json['decorationPlacements'],
      ),
      decorationPlacementsByArea: decorationPlacementsByArea,
      potPlacements: _potPlacementsFromJson(json['potPlacements']),
      potPlacementsByArea: potPlacementsByArea,
      pots: pots,
      potsByArea: potsByArea,
    );
  }

  Map<String, Object?> stateToJson(GardenState state) {
    return {
      'water': state.water,
      'coins': state.coins,
      'totalBlooms': state.totalBlooms,
      'activeArea': state.activeArea.name,
      'unlockedPlantTypes': state.unlockedPlantTypes
          .map((plantType) => plantType.name)
          .toList(),
      'ownedPotStyles': state.ownedPotStyles
          .map((potStyle) => potStyle.name)
          .toList(),
      'ownedDecorations': state.ownedDecorations
          .map((decoration) => decoration.name)
          .toList(),
      'placedDecorationsByArea': state.placedDecorationsByArea.map(
        (area, decorations) => MapEntry(
          area.name,
          decorations.map((decoration) => decoration.name).toList(),
        ),
      ),
      'decorationPlacementsByArea': state.decorationPlacementsByArea.map(
        (area, placements) => MapEntry(
          area.name,
          placements.map(
            (decoration, placement) =>
                MapEntry(decoration.name, _placementToJson(placement)),
          ),
        ),
      ),
      'potPlacementsByArea': state.potPlacementsByArea.map(
        (area, placements) => MapEntry(
          area.name,
          placements.map(
            (index, placement) => MapEntry('$index', {
              'x': placement.alignmentX,
              'y': placement.alignmentY,
            }),
          ),
        ),
      ),
      'potsByArea': state.potsByArea.map(
        (area, pots) => MapEntry(area.name, pots.map(_potToJson).toList()),
      ),
    };
  }

  Map<String, Object?> _placementToJson(GardenDecorationPlacement placement) {
    return {
      'x': placement.alignmentX,
      'y': placement.alignmentY,
      'scale': placement.scale,
      'inFront': placement.inFront,
    };
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
    if (pot.stage.isEmpty) {
      return {'stage': pot.stage.name, 'potStyle': pot.potStyle.name};
    }

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

  List<GardenPot> _normalizedPots(List<GardenPot> pots, GardenArea area) {
    final normalized = pots
        .where((pot) => pot.potStyle != GardenPotStyle.hanging)
        .take(area.potCount)
        .toList();

    while (normalized.length < area.potCount) {
      normalized.add(const GardenPot.empty());
    }
    return normalized;
  }

  List<GardenPot> _defaultPots(GardenArea area) {
    return List.generate(area.potCount, (_) => const GardenPot.empty());
  }

  Map<GardenArea, List<GardenPot>> _potsByAreaFromJson(
    Object? json,
    List<GardenPot> legacyPots,
  ) {
    final potsByArea = <GardenArea, List<GardenPot>>{
      GardenArea.main: legacyPots,
    };
    if (json is! Map) {
      return potsByArea;
    }

    for (final entry in json.entries) {
      final area = GardenArea.fromStoredName(entry.key);
      final value = entry.value;
      if (area == null || value is! List) {
        continue;
      }

      final pots = value
          .whereType<Map<String, dynamic>>()
          .map(_potFromJson)
          .whereType<GardenPot>()
          .toList();
      potsByArea[area] = _normalizedPots(pots, area);
    }
    return potsByArea;
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

  Map<GardenArea, Set<GardenDecoration>> _decorationsByAreaFromJson(
    Object? json,
    Set<GardenDecoration> legacyDecorations,
  ) {
    final decorationsByArea = <GardenArea, Set<GardenDecoration>>{
      GardenArea.main: legacyDecorations,
    };
    if (json is! Map) {
      return decorationsByArea;
    }

    for (final entry in json.entries) {
      final area = GardenArea.fromStoredName(entry.key);
      if (area == null) {
        continue;
      }

      decorationsByArea[area] = _decorationsFromJson(entry.value);
    }
    return decorationsByArea;
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

  Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>
  _decorationPlacementsByAreaFromJson(
    Object? json,
    Map<GardenDecoration, GardenDecorationPlacement> legacyPlacements,
  ) {
    final placementsByArea =
        <GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>{
          GardenArea.main: legacyPlacements,
        };
    if (json is! Map) {
      return placementsByArea;
    }

    for (final entry in json.entries) {
      final area = GardenArea.fromStoredName(entry.key);
      if (area == null) {
        continue;
      }

      placementsByArea[area] = _decorationPlacementsFromJson(entry.value);
    }
    return placementsByArea;
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

  Map<GardenArea, Map<int, GardenDecorationPlacement>>
  _potPlacementsByAreaFromJson(
    Object? json,
    Map<int, GardenDecorationPlacement> legacyPlacements,
  ) {
    final placementsByArea = <GardenArea, Map<int, GardenDecorationPlacement>>{
      GardenArea.main: legacyPlacements,
    };
    if (json is! Map) {
      return placementsByArea;
    }

    for (final entry in json.entries) {
      final area = GardenArea.fromStoredName(entry.key);
      if (area == null) {
        continue;
      }

      placementsByArea[area] = _potPlacementsFromJson(entry.value);
    }
    return placementsByArea;
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
