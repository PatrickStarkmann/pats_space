import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/models/garden_plant_type.dart';
import 'package:pats_space/features/space/models/garden_state.dart';

void main() {
  group('GardenController', () {
    test('daisy needs more water for each growth stage', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 20),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);
      expect(controller.state.pots[0].waterProgress, 1);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.bud);

      controller.performSelectedPotAction();
      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.bud);
      expect(controller.state.pots[0].waterProgress, 2);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
    });

    test('bloom can be collected three times before drying out', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 20),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.performSelectedPotAction();
      for (var i = 0; i < 6; i += 1) {
        controller.performSelectedPotAction();
      }

      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
      expect(controller.state.coins, 0);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
      expect(controller.state.coins, 5);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
      expect(controller.state.coins, 10);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.dry);
      expect(controller.state.coins, 15);
    });

    test('dry daisy needs one water to bloom again', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 20),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.performSelectedPotAction();
      for (var i = 0; i < 6; i += 1) {
        controller.performSelectedPotAction();
      }
      for (var i = 0; i < 3; i += 1) {
        controller.performSelectedPotAction();
      }
      expect(controller.state.pots[0].stage, GardenGrowthStage.dry);

      controller.performSelectedPotAction();
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

    test('selected plant type is kept while growing', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 20),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.plantSelectedPot(GardenPlantType.tulip);

      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);
      expect(controller.state.pots[0].plantType, GardenPlantType.tulip);

      for (var i = 0; i < 6; i += 1) {
        controller.performSelectedPotAction();
      }

      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
      expect(controller.state.pots[0].plantType, GardenPlantType.tulip);
    });

    test('clover skips bud and needs more water as a sprout', () {
      final controller = GardenController(
        initialState: GardenState.initial().copyWith(water: 20),
      );
      addTearDown(controller.dispose);

      controller.selectPot(0);
      controller.plantSelectedPot(GardenPlantType.clover);
      expect(controller.state.pots[0].stage, GardenGrowthStage.seed);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);

      for (var i = 0; i < 4; i += 1) {
        controller.performSelectedPotAction();
      }
      expect(controller.state.pots[0].stage, GardenGrowthStage.sprout);
      expect(controller.state.pots[0].waterProgress, 4);

      controller.performSelectedPotAction();
      expect(controller.state.pots[0].stage, GardenGrowthStage.bloom);
    });
  });
}
