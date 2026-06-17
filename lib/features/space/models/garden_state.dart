import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';

class GardenState {
  GardenState({
    required this.water,
    required this.coins,
    required this.pots,
    required Set<GardenPlantType> unlockedPlantTypes,
    this.selectedPotIndex,
  }) : unlockedPlantTypes = Set.unmodifiable({
         ...GardenPlantType.initiallyUnlocked,
         ...unlockedPlantTypes,
       });

  static const defaultWater = 1000;
  static const defaultCoins = 0;
  static const defaultPotCount = 4;

  factory GardenState.initial() {
    return GardenState(
      water: defaultWater,
      coins: defaultCoins,
      unlockedPlantTypes: GardenPlantType.initiallyUnlocked,
      pots: List.unmodifiable(
        List.generate(defaultPotCount, (_) => const GardenPot.empty()),
      ),
    );
  }

  final int water;
  final int coins;
  final List<GardenPot> pots;
  final Set<GardenPlantType> unlockedPlantTypes;
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
    Set<GardenPlantType>? unlockedPlantTypes,
    int? selectedPotIndex,
    bool clearSelectedPot = false,
  }) {
    return GardenState(
      water: water ?? this.water,
      coins: coins ?? this.coins,
      pots: pots == null ? this.pots : List.unmodifiable(pots),
      unlockedPlantTypes: unlockedPlantTypes == null
          ? this.unlockedPlantTypes
          : Set.unmodifiable({
              ...GardenPlantType.initiallyUnlocked,
              ...unlockedPlantTypes,
            }),
      selectedPotIndex: clearSelectedPot
          ? null
          : selectedPotIndex ?? this.selectedPotIndex,
    );
  }
}
