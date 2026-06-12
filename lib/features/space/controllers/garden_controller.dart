import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
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

  void performSelectedPotAction() {
    final index = _state.selectedPotIndex;
    if (index == null) {
      return;
    }

    final pot = _state.pots[index];
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

  GardenPot _updatedPotAfterPrimaryAction(GardenPot pot) {
    if (pot.stage == GardenGrowthStage.empty) {
      return pot.copyWith(stage: GardenGrowthStage.seed);
    }

    return pot.copyWith(stage: pot.stage.next);
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
