import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_area.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_decoration_placement.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';

class GardenState {
  GardenState({
    required this.water,
    required this.coins,
    required List<GardenPot> pots,
    required Set<GardenPlantType> unlockedPlantTypes,
    this.activeArea = GardenArea.main,
    Map<GardenArea, List<GardenPot>>? potsByArea,
    Set<GardenPotStyle> ownedPotStyles = GardenPotStyle.initiallyOwned,
    this.selectedPotStyle = GardenPotStyle.classic,
    Set<GardenDecoration> ownedDecorations = const {},
    Set<GardenDecoration> placedDecorations = const {},
    Map<GardenArea, Set<GardenDecoration>>? placedDecorationsByArea,
    Map<GardenDecoration, GardenDecorationPlacement> decorationPlacements =
        const {},
    Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>?
    decorationPlacementsByArea,
    Map<int, GardenDecorationPlacement> potPlacements = const {},
    Map<GardenArea, Map<int, GardenDecorationPlacement>>? potPlacementsByArea,
    this.selectedPotIndex,
  }) : unlockedPlantTypes = Set.unmodifiable({
         ...GardenPlantType.initiallyUnlocked,
         ...unlockedPlantTypes,
       }),
       potsByArea = _normalizedPotsByArea(
         potsByArea: potsByArea,
         activeArea: activeArea,
         activePots: pots,
       ),
       ownedPotStyles = Set.unmodifiable({
         ...GardenPotStyle.initiallyOwned,
         ...ownedPotStyles,
       }),
       ownedDecorations = Set.unmodifiable(ownedDecorations),
       placedDecorationsByArea = _normalizedDecorationsByArea(
         decorationsByArea: placedDecorationsByArea,
         activeArea: activeArea,
         activeDecorations: placedDecorations,
         ownedDecorations: ownedDecorations,
       ),
       decorationPlacementsByArea = _normalizedDecorationPlacementsByArea(
         placementsByArea: decorationPlacementsByArea,
         activeArea: activeArea,
         activePlacements: decorationPlacements,
       ),
       potPlacementsByArea = _normalizedPotPlacementsByArea(
         placementsByArea: potPlacementsByArea,
         activeArea: activeArea,
         activePlacements: potPlacements,
       );

  static const defaultWater = 1000;
  static const defaultCoins = 1000;
  static const defaultPotCount = 4;
  static const maxPotCount = 9;

  factory GardenState.initial() {
    return GardenState(
      water: defaultWater,
      coins: defaultCoins,
      unlockedPlantTypes: GardenPlantType.initiallyUnlocked,
      activeArea: GardenArea.main,
      ownedPotStyles: GardenPotStyle.initiallyOwned,
      selectedPotStyle: GardenPotStyle.classic,
      ownedDecorations: const {},
      placedDecorations: const {},
      decorationPlacements: const {},
      potPlacements: const {},
      pots: List.unmodifiable(
        List.generate(GardenArea.main.potCount, (_) => const GardenPot.empty()),
      ),
    );
  }

  final int water;
  final int coins;
  final GardenArea activeArea;
  final Map<GardenArea, List<GardenPot>> potsByArea;
  final Set<GardenPlantType> unlockedPlantTypes;
  final Set<GardenPotStyle> ownedPotStyles;
  final GardenPotStyle selectedPotStyle;
  final Set<GardenDecoration> ownedDecorations;
  final Map<GardenArea, Set<GardenDecoration>> placedDecorationsByArea;
  final Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>
  decorationPlacementsByArea;
  final Map<GardenArea, Map<int, GardenDecorationPlacement>>
  potPlacementsByArea;
  final int? selectedPotIndex;

  List<GardenPot> get pots =>
      potsByArea[activeArea] ?? _defaultPots(activeArea);

  Set<GardenDecoration> get placedDecorations =>
      placedDecorationsByArea[activeArea] ?? {};

  Map<GardenDecoration, GardenDecorationPlacement> get decorationPlacements =>
      decorationPlacementsByArea[activeArea] ?? {};

  Map<int, GardenDecorationPlacement> get potPlacements =>
      potPlacementsByArea[activeArea] ?? {};

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
    GardenArea? activeArea,
    List<GardenPot>? pots,
    Map<GardenArea, List<GardenPot>>? potsByArea,
    Set<GardenPlantType>? unlockedPlantTypes,
    Set<GardenPotStyle>? ownedPotStyles,
    GardenPotStyle? selectedPotStyle,
    Set<GardenDecoration>? ownedDecorations,
    Set<GardenDecoration>? placedDecorations,
    Map<GardenArea, Set<GardenDecoration>>? placedDecorationsByArea,
    Map<GardenDecoration, GardenDecorationPlacement>? decorationPlacements,
    Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>?
    decorationPlacementsByArea,
    Map<int, GardenDecorationPlacement>? potPlacements,
    Map<GardenArea, Map<int, GardenDecorationPlacement>>? potPlacementsByArea,
    int? selectedPotIndex,
    bool clearSelectedPot = false,
  }) {
    final nextActiveArea = activeArea ?? this.activeArea;

    return GardenState(
      water: water ?? this.water,
      coins: coins ?? this.coins,
      activeArea: nextActiveArea,
      pots:
          pots ?? (potsByArea ?? this.potsByArea)[nextActiveArea] ?? this.pots,
      potsByArea:
          potsByArea ??
          _copyPotsByAreaWith(this.potsByArea, nextActiveArea, pots),
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
      placedDecorations: placedDecorations ?? this.placedDecorations,
      placedDecorationsByArea:
          placedDecorationsByArea ??
          _copyDecorationsByAreaWith(
            this.placedDecorationsByArea,
            nextActiveArea,
            placedDecorations,
          ),
      decorationPlacements: decorationPlacements ?? this.decorationPlacements,
      decorationPlacementsByArea:
          decorationPlacementsByArea ??
          _copyDecorationPlacementsByAreaWith(
            this.decorationPlacementsByArea,
            nextActiveArea,
            decorationPlacements,
          ),
      potPlacements: potPlacements ?? this.potPlacements,
      potPlacementsByArea:
          potPlacementsByArea ??
          _copyPotPlacementsByAreaWith(
            this.potPlacementsByArea,
            nextActiveArea,
            potPlacements,
          ),
      selectedPotIndex: clearSelectedPot
          ? null
          : selectedPotIndex ?? this.selectedPotIndex,
    );
  }

  static List<GardenPot> _defaultPots([GardenArea area = GardenArea.main]) {
    return List.unmodifiable(
      List.generate(area.potCount, (_) => const GardenPot.empty()),
    );
  }

  static List<GardenPot> _normalizedPots(
    List<GardenPot> pots,
    GardenArea area,
  ) {
    final normalized = pots.take(area.potCount).toList();
    while (normalized.length < area.potCount) {
      normalized.add(const GardenPot.empty());
    }
    return List.unmodifiable(normalized);
  }

  static Map<GardenArea, List<GardenPot>> _normalizedPotsByArea({
    required Map<GardenArea, List<GardenPot>>? potsByArea,
    required GardenArea activeArea,
    required List<GardenPot> activePots,
  }) {
    final normalized = <GardenArea, List<GardenPot>>{};
    for (final area in GardenArea.values) {
      normalized[area] = _normalizedPots(
        potsByArea?[area] ??
            (area == activeArea ? activePots : _defaultPots(area)),
        area,
      );
    }
    return Map.unmodifiable(normalized);
  }

  static Map<GardenArea, Set<GardenDecoration>> _normalizedDecorationsByArea({
    required Map<GardenArea, Set<GardenDecoration>>? decorationsByArea,
    required GardenArea activeArea,
    required Set<GardenDecoration> activeDecorations,
    required Set<GardenDecoration> ownedDecorations,
  }) {
    final normalized = <GardenArea, Set<GardenDecoration>>{};
    for (final area in GardenArea.values) {
      final decorations =
          decorationsByArea?[area] ??
          (area == activeArea ? activeDecorations : const <GardenDecoration>{});
      normalized[area] = Set.unmodifiable(
        decorations.where(ownedDecorations.contains),
      );
    }
    return Map.unmodifiable(normalized);
  }

  static Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>
  _normalizedDecorationPlacementsByArea({
    required Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>?
    placementsByArea,
    required GardenArea activeArea,
    required Map<GardenDecoration, GardenDecorationPlacement> activePlacements,
  }) {
    final normalized =
        <GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>{};
    for (final area in GardenArea.values) {
      normalized[area] = Map.unmodifiable(
        placementsByArea?[area] ??
            (area == activeArea
                ? activePlacements
                : const <GardenDecoration, GardenDecorationPlacement>{}),
      );
    }
    return Map.unmodifiable(normalized);
  }

  static Map<GardenArea, Map<int, GardenDecorationPlacement>>
  _normalizedPotPlacementsByArea({
    required Map<GardenArea, Map<int, GardenDecorationPlacement>>?
    placementsByArea,
    required GardenArea activeArea,
    required Map<int, GardenDecorationPlacement> activePlacements,
  }) {
    final normalized = <GardenArea, Map<int, GardenDecorationPlacement>>{};
    for (final area in GardenArea.values) {
      normalized[area] = Map.unmodifiable(
        placementsByArea?[area] ??
            (area == activeArea
                ? activePlacements
                : const <int, GardenDecorationPlacement>{}),
      );
    }
    return Map.unmodifiable(normalized);
  }

  static Map<GardenArea, List<GardenPot>> _copyPotsByAreaWith(
    Map<GardenArea, List<GardenPot>> current,
    GardenArea activeArea,
    List<GardenPot>? pots,
  ) {
    if (pots == null) {
      return current;
    }

    return {...current, activeArea: List.unmodifiable(pots)};
  }

  static Map<GardenArea, Set<GardenDecoration>> _copyDecorationsByAreaWith(
    Map<GardenArea, Set<GardenDecoration>> current,
    GardenArea activeArea,
    Set<GardenDecoration>? decorations,
  ) {
    if (decorations == null) {
      return current;
    }

    return {...current, activeArea: Set.unmodifiable(decorations)};
  }

  static Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>>
  _copyDecorationPlacementsByAreaWith(
    Map<GardenArea, Map<GardenDecoration, GardenDecorationPlacement>> current,
    GardenArea activeArea,
    Map<GardenDecoration, GardenDecorationPlacement>? placements,
  ) {
    if (placements == null) {
      return current;
    }

    return {...current, activeArea: Map.unmodifiable(placements)};
  }

  static Map<GardenArea, Map<int, GardenDecorationPlacement>>
  _copyPotPlacementsByAreaWith(
    Map<GardenArea, Map<int, GardenDecorationPlacement>> current,
    GardenArea activeArea,
    Map<int, GardenDecorationPlacement>? placements,
  ) {
    if (placements == null) {
      return current;
    }

    return {...current, activeArea: Map.unmodifiable(placements)};
  }
}
