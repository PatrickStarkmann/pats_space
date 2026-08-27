import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_area.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_decoration_placement.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';
import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/garden_repository.dart';

class GardenController extends ChangeNotifier {
  GardenController({
    GardenRepository? repository,
    GardenState? initialState,
    double Function()? randomDouble,
  }) : _randomDouble = randomDouble ?? math.Random().nextDouble,
       _repository = repository,
       _state = initialState ?? GardenState.initial() {
    _state = _stateWithoutRetiredItems(_state);
    _state = _stateWithBloomCharges(_state, DateTime.now());
    _bloomChargeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshBloomCharges();
    });
  }

  static const bloomChargeInterval = Duration(hours: 8);
  static const maxBloomCharges = 1;
  static const maxBloomCollections = 3;
  static const cloverDoubleDropChance = .2;

  final GardenRepository? _repository;
  final double Function() _randomDouble;

  GardenState _state;
  Timer? _bloomChargeTimer;
  GardenDecoration? _requestedDecorationArrangement;

  GardenState get state => _state;
  GardenDecoration? get requestedDecorationArrangement =>
      _requestedDecorationArrangement;

  void selectArea(GardenArea area) {
    if (_state.activeArea == area) {
      return;
    }

    _setState(_state.copyWith(activeArea: area, clearSelectedPot: true));
  }

  @override
  void dispose() {
    _bloomChargeTimer?.cancel();
    super.dispose();
  }

  void selectPot(int index) {
    if (!_state.isAreaUnlocked(_state.activeArea)) {
      return;
    }

    if (index < 0 || index >= _state.pots.length) {
      return;
    }

    _setState(_state.copyWith(selectedPotIndex: index), persist: false);
  }

  void closeSelectedPot() {
    _setState(_state.copyWith(clearSelectedPot: true), persist: false);
  }

  void addWater(int amount) {
    if (amount <= 0) {
      return;
    }

    _setState(_state.copyWith(water: _state.water + amount));
  }

  void addCoins(int amount) {
    if (amount <= 0) {
      return;
    }

    _setState(_state.copyWith(coins: _state.coins + amount));
  }

  Future<void> persist() async {
    await _repository?.saveState(_state);
  }

  bool buyNextPotSlot() {
    return false;
  }

  bool buyPotStyle(GardenPotStyle style) {
    if (!GardenPotStyle.shopStyles.contains(style)) {
      return false;
    }

    if (_state.ownedPotStyles.contains(style) || _state.coins < style.cost) {
      return false;
    }

    _setState(
      _state.copyWith(
        coins: _state.coins - style.cost,
        ownedPotStyles: {..._state.ownedPotStyles, style},
      ),
    );
    return true;
  }

  bool styleSelectedPot(GardenPotStyle style) {
    final index = _state.selectedPotIndex;
    if (index == null) {
      return false;
    }

    if (_state.activeArea.isHangingPotSlot(index)) {
      return false;
    }

    if (!_state.ownedPotStyles.contains(style)) {
      return false;
    }

    final updatedPots = [..._state.pots]
      ..[index] = _state.pots[index].copyWith(potStyle: style);
    _setState(_state.copyWith(pots: updatedPots, selectedPotIndex: index));
    return true;
  }

  bool buyDecoration(GardenDecoration decoration) {
    if (!GardenDecoration.shopDecorations.contains(decoration)) {
      return false;
    }

    final requirement = decoration.requirement;
    if (requirement != null && !_state.ownedDecorations.contains(requirement)) {
      return false;
    }

    final owned = _state.ownedDecorations.contains(decoration);
    final placed = _state.placedDecorations.contains(decoration);
    if (placed || (!owned && _state.coins < decoration.cost)) {
      return false;
    }

    _setState(
      _state.copyWith(
        coins: owned ? _state.coins : _state.coins - decoration.cost,
        ownedDecorations: owned
            ? _state.ownedDecorations
            : {..._state.ownedDecorations, decoration},
        placedDecorations: {..._state.placedDecorations, decoration},
      ),
    );
    return true;
  }

  void requestDecorationArrangement(GardenDecoration decoration) {
    if (!_state.placedDecorations.contains(decoration)) {
      return;
    }

    _requestedDecorationArrangement = decoration;
    notifyListeners();
  }

  GardenDecoration? consumeDecorationArrangementRequest() {
    final decoration = _requestedDecorationArrangement;
    _requestedDecorationArrangement = null;
    return decoration;
  }

  void removeDecoration(GardenDecoration decoration) {
    if (!_state.placedDecorations.contains(decoration)) {
      return;
    }

    final decorations = {..._state.placedDecorations}..remove(decoration);
    final placements = {..._state.decorationPlacements}..remove(decoration);

    _setState(
      _state.copyWith(
        placedDecorations: decorations,
        decorationPlacements: placements,
      ),
    );
  }

  void moveDecoration(
    GardenDecoration decoration, {
    required double alignmentX,
    required double alignmentY,
  }) {
    updateDecorationPlacement(
      decoration,
      alignmentX: alignmentX,
      alignmentY: alignmentY,
    );
  }

  void updateDecorationPlacement(
    GardenDecoration decoration, {
    double? alignmentX,
    double? alignmentY,
    double? scale,
    bool? inFront,
  }) {
    if (!_state.placedDecorations.contains(decoration)) {
      return;
    }

    final current = _state.decorationPlacements[decoration];
    const maxScale = 1.75;
    final placements = {..._state.decorationPlacements}
      ..[decoration] =
          (current ??
                  const GardenDecorationPlacement(
                    alignmentX: .5,
                    alignmentY: .7,
                  ))
              .copyWith(
                alignmentX: alignmentX?.clamp(.08, .92).toDouble(),
                alignmentY: alignmentY?.clamp(.34, .98).toDouble(),
                scale: scale?.clamp(.65, maxScale).toDouble(),
                inFront: inFront,
              );

    _setState(_state.copyWith(decorationPlacements: placements));
  }

  void cleanUpGarden() {
    if (_state.placedDecorations.isEmpty &&
        _state.decorationPlacements.isEmpty &&
        _state.potPlacements.isEmpty) {
      return;
    }

    _setState(
      _state.copyWith(
        placedDecorations: const {},
        decorationPlacements: const {},
        potPlacements: const {},
      ),
    );
  }

  void movePot(
    int index, {
    required double alignmentX,
    required double alignmentY,
  }) {
    if (!_state.isAreaUnlocked(_state.activeArea)) {
      return;
    }

    if (index < 0 || index >= _state.pots.length) {
      return;
    }

    final placements = {..._state.potPlacements}
      ..[index] = GardenDecorationPlacement(
        alignmentX: alignmentX.clamp(.08, .92).toDouble(),
        alignmentY: alignmentY.clamp(.55, .98).toDouble(),
      );

    _setState(_state.copyWith(potPlacements: placements), persist: true);
  }

  void performSelectedPotAction() {
    final index = _state.selectedPotIndex;
    if (index == null) {
      return;
    }

    _performPotAction(index, keepSelected: true);
  }

  void performPotAction(int index) {
    if (!_state.isAreaUnlocked(_state.activeArea)) {
      return;
    }

    if (index < 0 || index >= _state.pots.length) {
      return;
    }

    final pot = _state.pots[index];
    if (pot.stage.isEmpty) {
      selectPot(index);
      return;
    }

    _performPotAction(index, keepSelected: false);
  }

  void _performPotAction(int index, {required bool keepSelected}) {
    _state = _stateWithBloomCharges(_state, DateTime.now());
    final pot = _state.pots[index];
    if (pot.stage.isEmpty && _state.water < pot.plantType.plantCost) {
      return;
    }

    if (pot.stage.needsWater && _state.water <= 0) {
      return;
    }

    if (pot.stage.hasCoins && !pot.hasCollectableCoins) {
      _setState(_state.copyWith(selectedPotIndex: index), persist: false);
      return;
    }

    final now = DateTime.now();
    final updatedPot = _updatedPotAfterPrimaryAction(pot, now);
    var updatedPots = [..._state.pots]..[index] = updatedPot;
    if (pot.plantType == GardenPlantType.cherryBlossom &&
        pot.hasCollectableCoins) {
      updatedPots = _potsAfterCherryBlossomCollection(
        pots: updatedPots,
        cherryBlossomIndex: index,
        now: now,
      );
    }
    final unlockedPlantTypes = _unlockedPlantTypesAfterAction(pot, updatedPot);
    final bloomCompleted = !pot.stage.hasCoins && updatedPot.stage.hasCoins;

    _setState(
      _state.copyWith(
        water: _waterAfterPrimaryAction(pot),
        coins: _coinsAfterPrimaryAction(pot),
        totalBlooms: bloomCompleted
            ? _state.totalBlooms + 1
            : _state.totalBlooms,
        pots: updatedPots,
        unlockedPlantTypes: unlockedPlantTypes,
        selectedPotIndex: keepSelected ? index : null,
        clearSelectedPot: !keepSelected,
      ),
    );
  }

  void plantSelectedPot(GardenPlantType plantType) {
    if (!_state.isAreaUnlocked(_state.activeArea)) {
      return;
    }

    final index = _state.selectedPotIndex;
    if (index == null) {
      return;
    }

    if (!_plantTypeAllowedInSelectedPot(plantType, index)) {
      return;
    }

    final pot = _state.pots[index];
    if (!pot.stage.isEmpty) {
      return;
    }

    if (_state.water < plantType.plantCost) {
      return;
    }

    if (!_state.unlockedPlantTypes.contains(plantType)) {
      return;
    }

    final updatedPots = [..._state.pots]
      ..[index] = GardenPot(
        stage: GardenGrowthStage.seed,
        plantType: plantType,
        coinReward: plantType.coinReward,
        waterProgress: 0,
        bloomCollections: 0,
        bloomCharges: 0,
        lastBloomChargeAtMillis: null,
        potStyle: pot.potStyle,
      );

    _setState(
      _state.copyWith(
        water: math.max(0, _state.water - plantType.plantCost),
        pots: updatedPots,
        selectedPotIndex: index,
      ),
    );
  }

  void removeSelectedPlant() {
    final index = _state.selectedPotIndex;
    if (index == null) {
      return;
    }

    final updatedPots = [..._state.pots]
      ..[index] = const GardenPot.empty().copyWith(
        potStyle: _state.pots[index].potStyle,
      );

    _setState(_state.copyWith(pots: updatedPots, selectedPotIndex: index));
  }

  bool _plantTypeAllowedInSelectedPot(GardenPlantType plantType, int index) {
    final isHangingSlot = _state.activeArea.isHangingPotSlot(index);
    final allowedPlants = isHangingSlot
        ? GardenPlantType.hangingPlantable
        : GardenPlantType.groundPlantable;
    return allowedPlants.contains(plantType);
  }

  GardenPot _updatedPotAfterPrimaryAction(GardenPot pot, DateTime now) {
    if (pot.stage == GardenGrowthStage.empty) {
      return pot.copyWith(
        stage: GardenGrowthStage.seed,
        coinReward: pot.plantType.coinReward,
        waterProgress: 0,
        bloomCollections: 0,
        bloomCharges: 0,
        clearLastBloomChargeAt: true,
      );
    }

    if (pot.stage.hasCoins) {
      if (!pot.hasCollectableCoins) {
        return pot;
      }

      final collections = pot.bloomCollections + 1;
      if (collections >= maxBloomCollections) {
        return pot.copyWith(
          stage: GardenGrowthStage.dry,
          waterProgress: 0,
          bloomCollections: 0,
          bloomCharges: 0,
          clearLastBloomChargeAt: true,
        );
      }

      return pot.copyWith(
        bloomCollections: collections,
        bloomCharges: math.max(0, pot.bloomCharges - 1),
        lastBloomChargeAtMillis: now.millisecondsSinceEpoch,
      );
    }

    if (pot.stage.needsWater) {
      final waterProgress = pot.waterProgress + 1;
      if (waterProgress < pot.waterRequired) {
        return pot.copyWith(waterProgress: waterProgress);
      }

      return pot.copyWith(
        stage: pot.nextStage,
        waterProgress: 0,
        bloomCollections: pot.stage == GardenGrowthStage.dry
            ? 0
            : pot.bloomCollections,
        bloomCharges: pot.nextStage.hasCoins ? 1 : 0,
        lastBloomChargeAtMillis: pot.nextStage.hasCoins
            ? now.millisecondsSinceEpoch
            : null,
        clearLastBloomChargeAt: !pot.nextStage.hasCoins,
      );
    }

    return pot.copyWith(stage: pot.nextStage);
  }

  int _waterAfterPrimaryAction(GardenPot pot) {
    if (pot.stage.isEmpty) {
      return math.max(0, _state.water - pot.plantType.plantCost);
    }

    if (!pot.stage.needsWater) {
      return _state.water;
    }

    return math.max(0, _state.water - 1);
  }

  int _coinsAfterPrimaryAction(GardenPot pot) {
    if (!pot.hasCollectableCoins) {
      return _state.coins;
    }

    return _state.coins + _coinRewardForCollect(pot);
  }

  int _coinRewardForCollect(GardenPot pot) {
    final baseReward = pot.plantType.coinReward;
    if (pot.plantType == GardenPlantType.clover &&
        _randomDouble() < cloverDoubleDropChance) {
      return baseReward * 2;
    }

    return baseReward;
  }

  List<GardenPot> _potsAfterCherryBlossomCollection({
    required List<GardenPot> pots,
    required int cherryBlossomIndex,
    required DateTime now,
  }) {
    final eligibleIndexes = <int>[];
    for (var index = 0; index < pots.length; index += 1) {
      final pot = pots[index];
      if (index == cherryBlossomIndex ||
          !pot.stage.hasCoins ||
          pot.bloomCharges >= pot.plantType.maxBloomCharges) {
        continue;
      }
      eligibleIndexes.add(index);
    }

    if (eligibleIndexes.isEmpty) {
      return pots;
    }

    final candidateIndex = (_randomDouble() * eligibleIndexes.length)
        .floor()
        .clamp(0, eligibleIndexes.length - 1)
        .toInt();
    final targetIndex = eligibleIndexes[candidateIndex];
    final target = pots[targetIndex];
    final updatedPots = [...pots];
    updatedPots[targetIndex] = target.copyWith(
      bloomCharges: target.bloomCharges + 1,
      lastBloomChargeAtMillis: now.millisecondsSinceEpoch,
    );
    return updatedPots;
  }

  Set<GardenPlantType> _unlockedPlantTypesAfterAction(
    GardenPot oldPot,
    GardenPot updatedPot,
  ) {
    if (!updatedPot.stage.hasCoins || oldPot.stage.hasCoins) {
      return _state.unlockedPlantTypes;
    }

    final nextUnlock = updatedPot.plantType.nextUnlock;
    if (nextUnlock == null || _state.unlockedPlantTypes.contains(nextUnlock)) {
      return _state.unlockedPlantTypes;
    }

    return {..._state.unlockedPlantTypes, nextUnlock};
  }

  void _refreshBloomCharges() {
    final refreshedState = _stateWithBloomCharges(_state, DateTime.now());
    if (!_sameGardenState(refreshedState, _state)) {
      _setState(refreshedState);
    }
  }

  GardenState _stateWithoutRetiredItems(GardenState state) {
    const retiredDecorations = {
      GardenDecoration.hangingPlantFrame,
      GardenDecoration.hangingPot,
    };
    final decorations = state.ownedDecorations
        .where((decoration) => !retiredDecorations.contains(decoration))
        .toSet();
    final placedDecorationsByArea = <GardenArea, Set<GardenDecoration>>{};
    final decorationPlacementsByArea =
        <GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>{};
    final potsByArea = <GardenArea, List<GardenPot>>{};
    var selectedPotWasRetired = false;

    for (final area in GardenArea.values) {
      placedDecorationsByArea[area] =
          (state.placedDecorationsByArea[area] ?? {})
              .where((decoration) => !retiredDecorations.contains(decoration))
              .where(decorations.contains)
              .toSet();
      decorationPlacementsByArea[area] =
          Map<GardenDecoration, GardenDecorationPlacement>.from(
            state.decorationPlacementsByArea[area] ?? {},
          )..removeWhere(
            (decoration, _) => retiredDecorations.contains(decoration),
          );
      final areaPots = (state.potsByArea[area] ?? const <GardenPot>[])
          .where((pot) => pot.potStyle != GardenPotStyle.hanging)
          .toList();
      potsByArea[area] = areaPots;

      if (area == state.activeArea) {
        selectedPotWasRetired =
            state.selectedPot?.potStyle == GardenPotStyle.hanging;
      }
    }

    if (setEquals(decorations, state.ownedDecorations) &&
        _sameDecorationSetsByArea(
          placedDecorationsByArea,
          state.placedDecorationsByArea,
        ) &&
        _sameDecorationPlacementsByArea(
          decorationPlacementsByArea,
          state.decorationPlacementsByArea,
        ) &&
        _samePotsByArea(potsByArea, state.potsByArea)) {
      return state;
    }

    return state.copyWith(
      ownedDecorations: decorations,
      placedDecorationsByArea: placedDecorationsByArea,
      decorationPlacementsByArea: decorationPlacementsByArea,
      potsByArea: potsByArea,
      clearSelectedPot: selectedPotWasRetired,
    );
  }

  GardenState _stateWithBloomCharges(GardenState state, DateTime now) {
    var changed = false;
    final refreshedPotsByArea = <GardenArea, List<GardenPot>>{};

    for (final entry in state.potsByArea.entries) {
      final refreshedPots = <GardenPot>[];
      for (final pot in entry.value) {
        final refreshedPot = _potWithBloomCharges(pot, now);
        refreshedPots.add(refreshedPot);
        changed = changed || !_samePot(refreshedPot, pot);
      }
      refreshedPotsByArea[entry.key] = refreshedPots;
    }

    if (!changed) {
      return state;
    }

    return state.copyWith(potsByArea: refreshedPotsByArea);
  }

  GardenPot _potWithBloomCharges(GardenPot pot, DateTime now) {
    if (!pot.stage.hasCoins) {
      if (pot.bloomCharges == 0 && pot.lastBloomChargeAtMillis == null) {
        return pot;
      }

      return pot.copyWith(bloomCharges: 0, clearLastBloomChargeAt: true);
    }

    final maxCharges = pot.plantType.maxBloomCharges;
    final nowMillis = now.millisecondsSinceEpoch;
    final lastChargeAt = pot.lastBloomChargeAtMillis;
    if (lastChargeAt == null) {
      return pot.copyWith(
        bloomCharges: math
            .max(1, pot.bloomCharges)
            .clamp(0, maxCharges)
            .toInt(),
        lastBloomChargeAtMillis: nowMillis,
      );
    }

    if (pot.bloomCharges > maxCharges) {
      return pot.copyWith(
        bloomCharges: maxCharges,
        lastBloomChargeAtMillis: nowMillis,
      );
    }

    if (pot.bloomCharges == maxCharges) {
      return pot;
    }

    final intervalMillis = pot.plantType.coinDropInterval.inMilliseconds;
    final elapsedMillis = nowMillis - lastChargeAt;
    if (elapsedMillis < intervalMillis) {
      return pot;
    }

    final intervals = elapsedMillis ~/ intervalMillis;
    final newCharges = math.min(maxCharges, pot.bloomCharges + intervals);
    final newLastChargeAt = newCharges >= maxCharges
        ? nowMillis
        : lastChargeAt + intervals * intervalMillis;

    return pot.copyWith(
      bloomCharges: newCharges,
      lastBloomChargeAtMillis: newLastChargeAt,
    );
  }

  bool _sameGardenState(GardenState a, GardenState b) {
    if (a.water != b.water ||
        a.coins != b.coins ||
        a.totalBlooms != b.totalBlooms ||
        a.activeArea != b.activeArea ||
        a.selectedPotIndex != b.selectedPotIndex ||
        !setEquals(a.unlockedPlantTypes, b.unlockedPlantTypes) ||
        !setEquals(a.ownedPotStyles, b.ownedPotStyles) ||
        !setEquals(a.ownedDecorations, b.ownedDecorations) ||
        !_sameDecorationSetsByArea(
          a.placedDecorationsByArea,
          b.placedDecorationsByArea,
        ) ||
        !_sameDecorationPlacementsByArea(
          a.decorationPlacementsByArea,
          b.decorationPlacementsByArea,
        ) ||
        !_sameIntPlacementsByArea(
          a.potPlacementsByArea,
          b.potPlacementsByArea,
        ) ||
        !_samePotsByArea(a.potsByArea, b.potsByArea)) {
      return false;
    }

    return true;
  }

  bool _samePotsByArea(
    Map<GardenArea, List<GardenPot>> a,
    Map<GardenArea, List<GardenPot>> b,
  ) {
    if (!setEquals(a.keys.toSet(), b.keys.toSet())) {
      return false;
    }

    for (final area in a.keys) {
      final aPots = a[area] ?? const <GardenPot>[];
      final bPots = b[area] ?? const <GardenPot>[];
      if (aPots.length != bPots.length) {
        return false;
      }
      for (var index = 0; index < aPots.length; index += 1) {
        if (!_samePot(aPots[index], bPots[index])) {
          return false;
        }
      }
    }

    return true;
  }

  bool _samePot(GardenPot a, GardenPot b) {
    return a.stage == b.stage &&
        a.plantType == b.plantType &&
        a.coinReward == b.coinReward &&
        a.waterProgress == b.waterProgress &&
        a.bloomCollections == b.bloomCollections &&
        a.bloomCharges == b.bloomCharges &&
        a.lastBloomChargeAtMillis == b.lastBloomChargeAtMillis &&
        a.potStyle == b.potStyle;
  }

  bool _sameDecorationPlacements(
    Map<GardenDecoration, GardenDecorationPlacement> a,
    Map<GardenDecoration, GardenDecorationPlacement> b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    for (final entry in a.entries) {
      final other = b[entry.key];
      if (other == null || !_samePlacement(entry.value, other)) {
        return false;
      }
    }

    return true;
  }

  bool _sameDecorationSetsByArea(
    Map<GardenArea, Set<GardenDecoration>> a,
    Map<GardenArea, Set<GardenDecoration>> b,
  ) {
    if (!setEquals(a.keys.toSet(), b.keys.toSet())) {
      return false;
    }

    for (final area in a.keys) {
      if (!setEquals(a[area], b[area])) {
        return false;
      }
    }

    return true;
  }

  bool _sameDecorationPlacementsByArea(
    Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>> a,
    Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>> b,
  ) {
    if (!setEquals(a.keys.toSet(), b.keys.toSet())) {
      return false;
    }

    for (final area in a.keys) {
      if (!_sameDecorationPlacements(a[area] ?? {}, b[area] ?? {})) {
        return false;
      }
    }

    return true;
  }

  bool _sameIntPlacements(
    Map<int, GardenDecorationPlacement> a,
    Map<int, GardenDecorationPlacement> b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    for (final entry in a.entries) {
      final other = b[entry.key];
      if (other == null || !_samePlacement(entry.value, other)) {
        return false;
      }
    }

    return true;
  }

  bool _sameIntPlacementsByArea(
    Map<GardenArea, Map<int, GardenDecorationPlacement>> a,
    Map<GardenArea, Map<int, GardenDecorationPlacement>> b,
  ) {
    if (!setEquals(a.keys.toSet(), b.keys.toSet())) {
      return false;
    }

    for (final area in a.keys) {
      if (!_sameIntPlacements(a[area] ?? {}, b[area] ?? {})) {
        return false;
      }
    }

    return true;
  }

  bool _samePlacement(
    GardenDecorationPlacement a,
    GardenDecorationPlacement b,
  ) {
    return a.alignmentX == b.alignmentX &&
        a.alignmentY == b.alignmentY &&
        a.scale == b.scale &&
        a.inFront == b.inFront;
  }

  void _setState(GardenState state, {bool persist = true}) {
    _state = state;
    notifyListeners();
    if (persist) {
      final repository = _repository;
      if (repository != null) {
        unawaited(repository.saveState(_state));
      }
    }
  }
}
