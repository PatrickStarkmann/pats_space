import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_state.dart';

void main() {
  group('GardenController', () {
    test('daisy needs more water for each growth stage', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 100),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);
      expect(controller.state.water, 99);

      _performActions(controller, 4);
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);
      expect(controller.state.pots[0].waterProgress, 4);

      _performActions(controller, 1);
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);

      _performActions(controller, 7);
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);
      expect(controller.state.pots[0].waterProgress, 7);

      _performActions(controller, 1);
      expect(controller.state.pots[0].stage, GardenGrowthStage.bud);

      _performActions(controller, 11);
      expect(controller.state.pots[0].stage, GardenGrowthStage.bud);
      expect(controller.state.pots[0].waterProgress, 11);

      _performActions(controller, 1);
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
    });

    test('ready bloom charge can be collected once', () {
      final oldChargeAt = DateTime.now()
          .subtract(GardenController.bloomChargeInterval * 3)
          .millisecondsSinceEpoch;
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(
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

      _performActions(controller, 5);
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
        initialState: GardenState.initial().copyWith(water: 20),
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
        initialState: GardenState.initial().copyWith(water: 50),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.plantSelectedPot(GardenPlantType.tulip);

      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);
      expect(controller.state.pots[0].plantType, GardenPlantType.tulip);

      _performActions(controller, 31);

      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
      expect(controller.state.pots[0].plantType, GardenPlantType.tulip);
    });

    test('clover skips bud and needs more water as a sprout', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 40),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.plantSelectedPot(GardenPlantType.clover);
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);

      _performActions(controller, 7);
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);

      _performActions(controller, 13);
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);
      expect(controller.state.pots[0].waterProgress, 13);

      _performActions(controller, 1);
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
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
  });
}

void _performActions(GardenController controller, int count) {
  for (var i = 0; i < count; i += 1) {
    controller.performSelectedPotAction();
  }
}

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
