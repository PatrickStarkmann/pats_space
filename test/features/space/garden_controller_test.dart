import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_decoration_placement.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';
import 'package:pats_space/features/space/models/garden_state.dart';

void main() {
  group('GardenController', () {
    test('plant balance scales starter to premium plants', () {
      expect(GardenPlantType.daisy.balance.totalWaterToFirstBloom, 17);
      expect(GardenPlantType.clover.balance.totalWaterToFirstBloom, 20);
      expect(GardenPlantType.tulip.balance.totalWaterToFirstBloom, 28);
      expect(GardenPlantType.sunflower.balance.totalWaterToFirstBloom, 40);
    });

    test('daisy needs more water for each growth stage', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 100),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);
      expect(controller.state.water, 99);

      _performActions(controller, 2);
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);
      expect(controller.state.pots[0].waterProgress, 2);

      _performActions(controller, 1);
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);

      _performActions(controller, 4);
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);
      expect(controller.state.pots[0].waterProgress, 4);

      _performActions(controller, 1);
      expect(controller.state.pots[0].stage, GardenGrowthStage.bud);

      _performActions(controller, 7);
      expect(controller.state.pots[0].stage, GardenGrowthStage.bud);
      expect(controller.state.pots[0].waterProgress, 7);

      _performActions(controller, 1);
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
    });

    test('ready bloom charge can be collected once', () {
      final oldChargeAt = DateTime.now()
          .subtract(GardenController.bloomChargeInterval * 3)
          .millisecondsSinceEpoch;
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          coins: 0,
          pots: [
            _bloomingPot(charges: 1, lastChargeAtMillis: oldChargeAt),
            const GardenPot.empty(),
            const GardenPot.empty(),
            const GardenPot.empty(),
          ],
        ),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);

      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
      expect(controller.state.coins, 0);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
      expect(controller.state.coins, 5);
      expect(controller.state.pots[0].bloomCharges, 0);
      expect(controller.state.pots[0].bloomCollections, 1);
      expect(
        controller.state.pots[0].lastBloomChargeAtMillis,
        greaterThan(oldChargeAt),
      );

      controller.performSelectedPotAction();
      expect(controller.state.coins, 5);
      expect(controller.state.pots[0].bloomCharges, 0);
    });

    test('third bloom collection dries out the plant', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          coins: 0,
          pots: [
            _bloomingPot(charges: 1, collections: 2),
            const GardenPot.empty(),
            const GardenPot.empty(),
            const GardenPot.empty(),
          ],
        ),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.dry);
      expect(controller.state.coins, 5);
    });

    test('dry daisy needs one water to bloom again', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          water: 100,
          pots: [
            _bloomingPot(charges: 1, collections: 2),
            const GardenPot.empty(),
            const GardenPot.empty(),
            const GardenPot.empty(),
          ],
        ),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.dry);

      _performActions(controller, 4);
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
    });

    test('selected plant can be removed and replanted', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 20),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);

      controller.removeSelectedPlant();
      expect(controller.state.pots[0].stage, GardenGrowthStage.empty);
      expect(controller.state.selectedPotIndex, 0);
    });

    test('pot action opens empty pot and waters planted pot directly', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          water: 20,
          unlockedPlantTypes: _allPlantsUnlocked,
        ),
      );
      addTearDown(controller.dispose);

      controller.performPotAction(0);
      expect(controller.state.selectedPotIndex, 0);
      expect(controller.state.pots[0].stage, GardenGrowthStage.empty);

      controller.plantSelectedPot(GardenPlantType.tulip);
      controller.closeSelectedPot();
      controller.performPotAction(0);

      expect(controller.state.selectedPotIndex, isNull);
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);
      expect(controller.state.pots[0].waterProgress, 1);
      expect(controller.state.water, 17);
    });

    test('selected plant type is kept while growing', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          water: 50,
          unlockedPlantTypes: _allPlantsUnlocked,
        ),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.plantSelectedPot(GardenPlantType.tulip);

      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);
      expect(controller.state.pots[0].plantType, GardenPlantType.tulip);

      _performActions(controller, 26);

      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
      expect(controller.state.pots[0].plantType, GardenPlantType.tulip);
    });

    test('clover skips bud and needs more water as a sprout', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          water: 40,
          unlockedPlantTypes: _allPlantsUnlocked,
        ),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.plantSelectedPot(GardenPlantType.clover);
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);

      _performActions(controller, 6);
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);

      _performActions(controller, 11);
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);
      expect(controller.state.pots[0].waterProgress, 11);

      _performActions(controller, 1);
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
    });

    test('blooming a plant unlocks the next plant', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 40),
      );
      addTearDown(controller.dispose);

      expect(
        controller.state.unlockedPlantTypes,
        contains(GardenPlantType.daisy),
      );
      expect(
        controller.state.unlockedPlantTypes,
        isNot(contains(GardenPlantType.tulip)),
      );

      controller.selectPot(0);
      controller.performSelectedPotAction();
      _performActions(controller, 16);

      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
      expect(
        controller.state.unlockedPlantTypes,
        contains(GardenPlantType.tulip),
      );
    });

    test('locked plants cannot be planted', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 40),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.plantSelectedPot(GardenPlantType.tulip);

      expect(controller.state.pots[0].stage, GardenGrowthStage.empty);
      expect(controller.state.water, 40);
    });

    test('bloom charges refill every eight hours without stacking', () {
      final lastChargeAt = DateTime.now()
          .subtract(GardenController.bloomChargeInterval * 3)
          .millisecondsSinceEpoch;
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          pots: [
            _bloomingPot(charges: 1, lastChargeAtMillis: lastChargeAt),
            const GardenPot.empty(),
            const GardenPot.empty(),
            const GardenPot.empty(),
          ],
        ),
      );
      addTearDown(controller.dispose);

      expect(controller.state.pots[0].bloomCharges, 1);
    });

    test('tulip and sunflower use their own coin rewards', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          coins: 0,
          pots: [
            _bloomingPot(charges: 1, plantType: GardenPlantType.tulip),
            _bloomingPot(charges: 1, plantType: GardenPlantType.sunflower),
            const GardenPot.empty(),
            const GardenPot.empty(),
          ],
        ),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.performSelectedPotAction();
      expect(controller.state.coins, 8);

      controller.selectPot(1);
      controller.performSelectedPotAction();
      expect(controller.state.coins, 22);
    });

    test('clover has a deterministic lucky double drop path', () {
      final controller = GardenController(
        randomDouble: () => .1,
        initialState: GardenState.initial().copyWith(
          coins: 0,
          pots: [
            _bloomingPot(charges: 1, plantType: GardenPlantType.clover),
            const GardenPot.empty(),
            const GardenPot.empty(),
            const GardenPot.empty(),
          ],
        ),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.performSelectedPotAction();

      expect(controller.state.coins, 10);
    });

    test('tulip refill waits for its ten hour interval', () {
      final lastChargeAt = DateTime.now()
          .subtract(GardenPlantType.tulip.coinDropInterval)
          .millisecondsSinceEpoch;
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          pots: [
            _bloomingPot(
              charges: 0,
              plantType: GardenPlantType.tulip,
              lastChargeAtMillis: lastChargeAt,
            ),
            const GardenPot.empty(),
            const GardenPot.empty(),
            const GardenPot.empty(),
          ],
        ),
      );
      addTearDown(controller.dispose);

      expect(controller.state.pots[0].bloomCharges, 1);
    });

    test('pot slots are fixed to the garden size', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          coins: 500,
          pots: List.generate(
            GardenState.maxPotCount,
            (_) => const GardenPot.empty(),
          ),
        ),
      );
      addTearDown(controller.dispose);

      final bought = controller.buyNextPotSlot();

      expect(bought, isFalse);
      expect(controller.state.coins, 500);
      expect(controller.state.pots, hasLength(GardenState.maxPotCount));
    });

    test('pot styles can be bought and equipped', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(coins: 200),
      );
      addTearDown(controller.dispose);

      final bought = controller.buyPotStyle(GardenPotStyle.blue);

      expect(bought, isTrue);
      expect(controller.state.coins, 80);
      expect(controller.state.ownedPotStyles, contains(GardenPotStyle.blue));
      expect(controller.state.selectedPotStyle, GardenPotStyle.blue);

      final selected = controller.selectPotStyle(GardenPotStyle.classic);
      expect(selected, isTrue);
      expect(controller.state.selectedPotStyle, GardenPotStyle.classic);
    });

    test('pot style can be changed per selected pot', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          coins: 200,
          water: 20,
          ownedPotStyles: {GardenPotStyle.classic, GardenPotStyle.blue},
        ),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.plantSelectedPot(GardenPlantType.daisy);

      controller.selectPot(1);
      controller.styleSelectedPot(GardenPotStyle.blue);
      controller.plantSelectedPot(GardenPlantType.daisy);

      expect(controller.state.pots[0].potStyle, GardenPotStyle.classic);
      expect(controller.state.pots[1].potStyle, GardenPotStyle.blue);
    });

    test('decorations can be bought once', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(coins: 200),
      );
      addTearDown(controller.dispose);

      final bought = controller.buyDecoration(GardenDecoration.lantern);
      final boughtAgain = controller.buyDecoration(GardenDecoration.lantern);

      expect(bought, isTrue);
      expect(boughtAgain, isFalse);
      expect(controller.state.coins, 60);
      expect(
        controller.state.ownedDecorations,
        contains(GardenDecoration.lantern),
      );
      expect(
        controller.state.placedDecorations,
        contains(GardenDecoration.lantern),
      );
    });

    test('owned decorations can be removed and placed again for free', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(coins: 200),
      );
      addTearDown(controller.dispose);

      controller.buyDecoration(GardenDecoration.lantern);
      controller.removeDecoration(GardenDecoration.lantern);
      final coinsAfterRemove = controller.state.coins;
      final placedAgain = controller.buyDecoration(GardenDecoration.lantern);

      expect(
        controller.state.ownedDecorations,
        contains(GardenDecoration.lantern),
      );
      expect(placedAgain, isTrue);
      expect(controller.state.coins, coinsAfterRemove);
      expect(
        controller.state.placedDecorations,
        contains(GardenDecoration.lantern),
      );
    });

    test('owned decorations can be moved within garden bounds', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          ownedDecorations: {GardenDecoration.bench},
          placedDecorations: {GardenDecoration.bench},
        ),
      );
      addTearDown(controller.dispose);

      controller.moveDecoration(
        GardenDecoration.bench,
        alignmentX: 1.5,
        alignmentY: .1,
      );

      final placement =
          controller.state.decorationPlacements[GardenDecoration.bench];
      expect(placement, isNotNull);
      expect(placement!.alignmentX, .92);
      expect(placement.alignmentY, .34);
    });

    test('owned decorations can be scaled and moved in front', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          ownedDecorations: {GardenDecoration.bench},
          placedDecorations: {GardenDecoration.bench},
        ),
      );
      addTearDown(controller.dispose);

      controller.updateDecorationPlacement(
        GardenDecoration.bench,
        scale: 2,
        inFront: true,
      );

      final placement =
          controller.state.decorationPlacements[GardenDecoration.bench];
      expect(placement, isNotNull);
      expect(placement!.scale, 1.75);
      expect(placement.inFront, isTrue);
    });

    test('retired frame and hanging pot are removed from existing state', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          pots: [
            ...GardenState.initial().pots,
            const GardenPot.empty().copyWith(potStyle: GardenPotStyle.hanging),
          ],
          ownedDecorations: {
            GardenDecoration.hangingPlantFrame,
            GardenDecoration.hangingPot,
            GardenDecoration.bench,
          },
          placedDecorations: {
            GardenDecoration.hangingPlantFrame,
            GardenDecoration.hangingPot,
            GardenDecoration.bench,
          },
          decorationPlacements: {
            GardenDecoration.hangingPot: const GardenDecorationPlacement(
              alignmentX: .2,
              alignmentY: .5,
            ),
          },
        ),
      );
      addTearDown(controller.dispose);

      expect(
        controller.state.ownedDecorations,
        isNot(contains(GardenDecoration.hangingPlantFrame)),
      );
      expect(
        controller.state.ownedDecorations,
        isNot(contains(GardenDecoration.hangingPot)),
      );
      expect(
        controller.state.decorationPlacements,
        isNot(contains(GardenDecoration.hangingPot)),
      );
      expect(
        controller.state.ownedDecorations,
        contains(GardenDecoration.bench),
      );
      expect(
        controller.state.pots.any(
          (pot) => pot.potStyle == GardenPotStyle.hanging,
        ),
        isFalse,
      );
    });

    test('pots can be moved within garden bounds', () {
      final controller = GardenController(initialState: GardenState.initial());
      addTearDown(controller.dispose);

      controller.movePot(0, alignmentX: 1.4, alignmentY: .2);

      final placement = controller.state.potPlacements[0];
      expect(placement, isNotNull);
      expect(placement!.alignmentX, .92);
      expect(placement.alignmentY, .55);
    });

    test('garden can be cleaned up without removing plants', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
          water: 20,
          ownedDecorations: {GardenDecoration.bench},
          placedDecorations: {GardenDecoration.bench},
        ),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.plantSelectedPot(GardenPlantType.daisy);
      controller.moveDecoration(
        GardenDecoration.bench,
        alignmentX: .8,
        alignmentY: .8,
      );
      controller.movePot(0, alignmentX: .8, alignmentY: .8);

      controller.cleanUpGarden();

      expect(controller.state.decorationPlacements, isEmpty);
      expect(controller.state.potPlacements, isEmpty);
      expect(
        controller.state.ownedDecorations,
        contains(GardenDecoration.bench),
      );
      expect(controller.state.placedDecorations, isEmpty);
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);
    });
  });
}

void _performActions(GardenController controller, int count) {
  for (var i = 0; i < count; i += 1) {
    controller.performSelectedPotAction();
  }
}

Set<GardenPlantType> get _allPlantsUnlocked =>
    GardenPlantType.plantable.toSet();

GardenPot _bloomingPot({
  required int charges,
  GardenPlantType plantType = GardenPlantType.daisy,
  int collections = 0,
  int? lastChargeAtMillis,
}) {
  return GardenPot(
    stage: GardenGrowthStage.bloom,
    plantType: plantType,
    coinReward: plantType.coinReward,
    waterProgress: 0,
    bloomCollections: collections,
    bloomCharges: charges,
    lastBloomChargeAtMillis:
        lastChargeAtMillis ?? DateTime.now().millisecondsSinceEpoch,
  );
}
