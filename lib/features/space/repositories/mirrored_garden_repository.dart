import 'package:flutter/foundation.dart';
import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/garden_repository.dart';

class MirroredGardenRepository implements GardenRepository {
  const MirroredGardenRepository({
    required this.localRepository,
    required this.remoteRepository,
  });

  final GardenRepository localRepository;
  final GardenRepository remoteRepository;

  @override
  Future<GardenState?> loadState() {
    return localRepository.loadState();
  }

  @override
  Future<void> saveState(GardenState state) async {
    await localRepository.saveState(state);
    try {
      await remoteRepository.saveState(state);
    } catch (error, stackTrace) {
      debugPrint('Could not sync garden state: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
