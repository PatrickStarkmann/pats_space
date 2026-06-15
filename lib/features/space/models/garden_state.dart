import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';

class GardenState {
  const GardenState({
    required this.water,
    required this.coins,
    required this.pots,
    this.selectedPotIndex,
  });

  static const defaultWater = 1000;
  static const defaultCoins = 0;
  static const defaultPotCount = 4;

  factory GardenState.initial() {
    return GardenState(
      water: defaultWater,
      coins: defaultCoins,
      pots: List.unmodifiable(
        List.generate(defaultPotCount, (_) => const GardenPot.empty()),
      ),
    );
  }

  final int water;
  final int coins;
  final List<GardenPot> pots;
  final int? selectedPotIndex;

  GardenPot? get selectedPot {
    final index = selectedPotIndex;
    if (index == null || index < 0 || index >= pots.length) {
      return null;
    }

    return pots[index];
  }

  List<GardenGrowthStage> get potStages {
    return List.unmodifiable(pots.map((pot) => pot.stage));
  }

  GardenState copyWith({
    int? water,
    int? coins,
    List<GardenPot>? pots,
    int? selectedPotIndex,
    bool clearSelectedPot = false,
  }) {
    return GardenState(
      water: water ?? this.water,
      coins: coins ?? this.coins,
      pots: pots == null ? this.pots : List.unmodifiable(pots),
      selectedPotIndex: clearSelectedPot
          ? null
          : selectedPotIndex ?? this.selectedPotIndex,
    );
  }
}
