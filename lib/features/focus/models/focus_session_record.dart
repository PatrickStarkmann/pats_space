import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_tag.dart';

class FocusSessionRecord {
  const FocusSessionRecord({
    required this.id,
    required this.tag,
    required this.mode,
    required this.focusDuration,
    required this.startedAt,
    required this.completedAt,
    required this.animationPair,
    this.waterReward = 0,
  });

  final String id;
  final FocusTag tag;
  final FocusMode mode;
  final Duration focusDuration;
  final DateTime startedAt;
  final DateTime completedAt;
  final FocusAnimationPair animationPair;
  final int waterReward;

  FocusSessionRecord copyWith({int? waterReward}) {
    return FocusSessionRecord(
      id: id,
      tag: tag,
      mode: mode,
      focusDuration: focusDuration,
      startedAt: startedAt,
      completedAt: completedAt,
      animationPair: animationPair,
      waterReward: waterReward ?? this.waterReward,
    );
  }
}
