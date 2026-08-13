import 'package:pats_space/features/focus/models/focus_session_phase.dart';

class ActiveTimerState {
  const ActiveTimerState({
    required this.phase,
    required this.paused,
    required this.completedSessions,
    required this.remainingSeconds,
    required this.savedAt,
    this.focusStartedAt,
  });

  final FocusSessionPhase phase;
  final bool paused;
  final int completedSessions;
  final int remainingSeconds;
  final DateTime savedAt;
  final DateTime? focusStartedAt;

  Map<String, Object?> toJson() => {
    'phase': phase.name,
    'paused': paused,
    'completedSessions': completedSessions,
    'remainingSeconds': remainingSeconds,
    'savedAt': savedAt.toIso8601String(),
    'focusStartedAt': focusStartedAt?.toIso8601String(),
  };

  static ActiveTimerState? fromJson(Map<String, dynamic> json) {
    final phaseName = json['phase'];
    final savedAt = DateTime.tryParse(json['savedAt'] as String? ?? '');
    if (phaseName is! String || savedAt == null) return null;
    final phase = FocusSessionPhase.values.where(
      (value) => value.name == phaseName,
    );
    if (phase.isEmpty || phase.first == FocusSessionPhase.idle) return null;
    final remainingSeconds = (json['remainingSeconds'] as num?)?.toInt();
    if (remainingSeconds == null || remainingSeconds < 0) return null;
    return ActiveTimerState(
      phase: phase.first,
      paused: json['paused'] as bool? ?? false,
      completedSessions: (json['completedSessions'] as num?)?.toInt() ?? 0,
      remainingSeconds: remainingSeconds,
      savedAt: savedAt,
      focusStartedAt: DateTime.tryParse(
        json['focusStartedAt'] as String? ?? '',
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ActiveTimerState &&
      other.phase == phase &&
      other.paused == paused &&
      other.completedSessions == completedSessions &&
      other.remainingSeconds == remainingSeconds &&
      other.savedAt == savedAt &&
      other.focusStartedAt == focusStartedAt;

  @override
  int get hashCode => Object.hash(
    phase,
    paused,
    completedSessions,
    remainingSeconds,
    savedAt,
    focusStartedAt,
  );
}
