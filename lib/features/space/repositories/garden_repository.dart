import 'package:pats_space/features/space/models/garden_state.dart';

abstract class GardenRepository {
  Future<GardenState?> loadState();

  Future<void> saveState(GardenState state);
}
