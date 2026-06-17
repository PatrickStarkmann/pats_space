import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
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

  GardenState get state => _state;

  @override
  void dispose() {
    _bloomChargeTimer?.cancel();
    super.dispose();
  }

  void selectPot(int index) {
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

  void performSelectedPotAction() {
    final index = _state.selectedPotIndex;
    if (index == null) {
      return;
    }

    _performPotAction(index, keepSelected: true);
  }

  void performPotAction(int index) {
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

    final updatedPot = _updatedPotAfterPrimaryAction(pot, DateTime.now());
    final updatedPots = [..._state.pots]..[index] = updatedPot;
    final unlockedPlantTypes = _unlockedPlantTypesAfterAction(pot, updatedPot);

    _setState(
      _state.copyWith(
        water: _waterAfterPrimaryAction(pot),
        coins: _coinsAfterPrimaryAction(pot),
        pots: updatedPots,
        unlockedPlantTypes: unlockedPlantTypes,
        selectedPotIndex: keepSelected ? index : null,
        clearSelectedPot: !keepSelected,
      ),
    );
  }

  void plantSelectedPot(GardenPlantType plantType) {
    final index = _state.selectedPotIndex;
    if (index == null) {
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

    final updatedPots = [..._state.pots]..[index] = const GardenPot.empty();

    _setState(_state.copyWith(pots: updatedPots, selectedPotIndex: index));
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

  GardenState _stateWithBloomCharges(GardenState state, DateTime now) {
    var changed = false;
    final refreshedPots = <GardenPot>[];

    for (final pot in state.pots) {
      final refreshedPot = _potWithBloomCharges(pot, now);
      refreshedPots.add(refreshedPot);
      changed = changed || !_samePot(refreshedPot, pot);
    }

    if (!changed) {
      return state;
    }

    return state.copyWith(pots: refreshedPots);
  }

  GardenPot _potWithBloomCharges(GardenPot pot, DateTime now) {
    if (!pot.stage.hasCoins) {
      if (pot.bloomCharges == 0 && pot.lastBloomChargeAtMillis == null) {
        return pot;
      }

      return pot.copyWith(bloomCharges: 0, clearLastBloomChargeAt: true);
    }

    final nowMillis = now.millisecondsSinceEpoch;
    final lastChargeAt = pot.lastBloomChargeAtMillis;
    if (lastChargeAt == null) {
      return pot.copyWith(
        bloomCharges: math
            .max(1, pot.bloomCharges)
            .clamp(0, maxBloomCharges)
            .toInt(),
        lastBloomChargeAtMillis: nowMillis,
      );
    }

    if (pot.bloomCharges > maxBloomCharges) {
      return pot.copyWith(
        bloomCharges: maxBloomCharges,
        lastBloomChargeAtMillis: nowMillis,
      );
    }

    if (pot.bloomCharges == maxBloomCharges) {
      return pot;
    }

    final intervalMillis = pot.plantType.coinDropInterval.inMilliseconds;
    final elapsedMillis = nowMillis - lastChargeAt;
    if (elapsedMillis < intervalMillis) {
      return pot;
    }

    final intervals = elapsedMillis ~/ intervalMillis;
    final newCharges = math.min(maxBloomCharges, pot.bloomCharges + intervals);
    final newLastChargeAt = newCharges >= maxBloomCharges
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
        a.selectedPotIndex != b.selectedPotIndex ||
        !setEquals(a.unlockedPlantTypes, b.unlockedPlantTypes) ||
        a.pots.length != b.pots.length) {
      return false;
    }

    for (var index = 0; index < a.pots.length; index += 1) {
      if (!_samePot(a.pots[index], b.pots[index])) {
        return false;
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
        a.lastBloomChargeAtMillis == b.lastBloomChargeAtMillis;
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
