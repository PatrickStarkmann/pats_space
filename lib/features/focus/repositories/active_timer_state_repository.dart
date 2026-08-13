import 'package:pats_space/features/focus/models/active_timer_state.dart';

abstract interface class ActiveTimerStateRepository {
  Future<ActiveTimerState?> load();

  Future<void> save(ActiveTimerState state);

  Future<void> clear();
}
