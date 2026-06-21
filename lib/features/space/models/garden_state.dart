import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_decoration_placement.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';

class GardenState {
  GardenState({
    required this.water,
    required this.coins,
    required this.pots,
    required Set<GardenPlantType> unlockedPlantTypes,
    Set<GardenPotStyle> ownedPotStyles = GardenPotStyle.initiallyOwned,
    this.selectedPotStyle = GardenPotStyle.classic,
    Set<GardenDecoration> ownedDecorations = const {},
    Set<GardenDecoration> placedDecorations = const {},
    Map<GardenDecoration, GardenDecorationPlacement> decorationPlacements =
        const {},
    Map<int, GardenDecorationPlacement> potPlacements = const {},
    this.selectedPotIndex,
  }) : unlockedPlantTypes = Set.unmodifiable({
         ...GardenPlantType.initiallyUnlocked,
         ...unlockedPlantTypes,
       }),
       ownedPotStyles = Set.unmodifiable({
         ...GardenPotStyle.initiallyOwned,
         ...ownedPotStyles,
       }),
       ownedDecorations = Set.unmodifiable(ownedDecorations),
       placedDecorations = Set.unmodifiable(
         placedDecorations.where(ownedDecorations.contains),
       ),
       decorationPlacements = Map.unmodifiable(decorationPlacements),
       potPlacements = Map.unmodifiable(potPlacements);

  static const defaultWater = 1000;
  static const defaultCoins = 1000;
  static const defaultPotCount = 4;
  static const maxPotCount = defaultPotCount;

  factory GardenState.initial() {
    return GardenState(
      water: defaultWater,
      coins: defaultCoins,
      unlockedPlantTypes: GardenPlantType.initiallyUnlocked,
      ownedPotStyles: GardenPotStyle.initiallyOwned,
      selectedPotStyle: GardenPotStyle.classic,
      ownedDecorations: const {},
      placedDecorations: const {},
      decorationPlacements: const {},
      potPlacements: const {},
      pots: List.unmodifiable(
        List.generate(defaultPotCount, (_) => const GardenPot.empty()),
      ),
    );
  }

  final int water;
  final int coins;
  final List<GardenPot> pots;
  final Set<GardenPlantType> unlockedPlantTypes;
  final Set<GardenPotStyle> ownedPotStyles;
  final GardenPotStyle selectedPotStyle;
  final Set<GardenDecoration> ownedDecorations;
  final Set<GardenDecoration> placedDecorations;
  final Map<GardenDecoration, GardenDecorationPlacement> decorationPlacements;
  final Map<int, GardenDecorationPlacement> potPlacements;
  final int? selectedPotIndex;

  GardenPot? get selectedPot {
    final index = selectedPotIndex;
    if (index == null || index < 0 || index >= pots.length) {
      return null;
    }

    return pots[index];
  }

  int get groundPotCount {
    return pots.length;
  }

  List<GardenGrowthStage> get potStages {
    return List.unmodifiable(pots.map((pot) => pot.stage));
  }

  GardenState copyWith({
    int? water,
    int? coins,
    List<GardenPot>? pots,
    Set<GardenPlantType>? unlockedPlantTypes,
    Set<GardenPotStyle>? ownedPotStyles,
    GardenPotStyle? selectedPotStyle,
    Set<GardenDecoration>? ownedDecorations,
    Set<GardenDecoration>? placedDecorations,
    Map<GardenDecoration, GardenDecorationPlacement>? decorationPlacements,
    Map<int, GardenDecorationPlacement>? potPlacements,
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
      ownedPotStyles: ownedPotStyles == null
          ? this.ownedPotStyles
          : Set.unmodifiable({
              ...GardenPotStyle.initiallyOwned,
              ...ownedPotStyles,
            }),
      selectedPotStyle: selectedPotStyle ?? this.selectedPotStyle,
      ownedDecorations: ownedDecorations == null
          ? this.ownedDecorations
          : Set.unmodifiable(ownedDecorations),
      placedDecorations: placedDecorations == null
          ? this.placedDecorations
          : Set.unmodifiable(placedDecorations),
      decorationPlacements: decorationPlacements == null
          ? this.decorationPlacements
          : Map.unmodifiable(decorationPlacements),
      potPlacements: potPlacements == null
          ? this.potPlacements
          : Map.unmodifiable(potPlacements),
      selectedPotIndex: clearSelectedPot
          ? null
          : selectedPotIndex ?? this.selectedPotIndex,
    );
  }
}
