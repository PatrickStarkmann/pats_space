import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/garden_repository.dart';

class GardenController extends ChangeNotifier {
  GardenController({GardenRepository? repository, GardenState? initialState})
    : _repository = repository,
      _state = initialState ?? GardenState.initial();

  final GardenRepository? _repository;

  GardenState _state;

  GardenState get state => _state;

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

    final pot = _state.pots[index];
    if (pot.stage.needsWater && _state.water <= 0) {
      return;
    }

    final updatedPot = _updatedPotAfterPrimaryAction(pot);
    final updatedPots = [..._state.pots]..[index] = updatedPot;

    _setState(
      _state.copyWith(
        water: _waterAfterPrimaryAction(pot),
        coins: _coinsAfterPrimaryAction(pot),
        pots: updatedPots,
        selectedPotIndex: index,
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

    final updatedPots = [..._state.pots]
      ..[index] = GardenPot(
        stage: GardenGrowthStage.seed,
        plantType: plantType,
        coinReward: plantType.coinReward,
        waterProgress: 0,
        bloomCollections: 0,
      );

    _setState(_state.copyWith(pots: updatedPots, selectedPotIndex: index));
  }

  void removeSelectedPlant() {
    final index = _state.selectedPotIndex;
    if (index == null) {
      return;
    }

    final updatedPots = [..._state.pots]..[index] = const GardenPot.empty();

    _setState(_state.copyWith(pots: updatedPots, selectedPotIndex: index));
  }

  GardenPot _updatedPotAfterPrimaryAction(GardenPot pot) {
    if (pot.stage == GardenGrowthStage.empty) {
      return pot.copyWith(
        stage: GardenGrowthStage.seed,
        coinReward: pot.plantType.coinReward,
        waterProgress: 0,
        bloomCollections: 0,
      );
    }

    if (pot.stage.hasCoins) {
      final collections = pot.bloomCollections + 1;
      if (collections >= 3) {
        return pot.copyWith(
          stage: GardenGrowthStage.dry,
          waterProgress: 0,
          bloomCollections: 0,
        );
      }

      return pot.copyWith(bloomCollections: collections);
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
      );
    }

    return pot.copyWith(stage: pot.nextStage);
  }

  int _waterAfterPrimaryAction(GardenPot pot) {
    if (!pot.stage.needsWater) {
      return _state.water;
    }

    return math.max(0, _state.water - 1);
  }

  int _coinsAfterPrimaryAction(GardenPot pot) {
    if (!pot.stage.hasCoins) {
      return _state.coins;
    }

    return _state.coins + pot.coinReward;
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
