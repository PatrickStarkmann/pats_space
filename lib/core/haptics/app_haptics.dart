import 'package:flutter/services.dart';

class AppHaptics {
  const AppHaptics._();

  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> lightImpact() => HapticFeedback.lightImpact();

  static Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  static Future<void> heavyImpact() => HapticFeedback.heavyImpact();

  static Future<void> success() =>
      _play([_HapticStep.light(), _HapticStep.pause(55), _HapticStep.medium()]);

  static Future<void> warning() => _play([
    _HapticStep.medium(),
    _HapticStep.pause(70),
    _HapticStep.selection(),
  ]);

  static Future<void> reward() => _play([
    _HapticStep.selection(),
    _HapticStep.pause(45),
    _HapticStep.light(),
    _HapticStep.pause(70),
    _HapticStep.medium(),
  ]);

  static Future<void> purchase() =>
      _play([_HapticStep.light(), _HapticStep.pause(50), _HapticStep.medium()]);

  static Future<void> unlock() => _play([
    _HapticStep.light(),
    _HapticStep.pause(55),
    _HapticStep.light(),
    _HapticStep.pause(90),
    _HapticStep.heavy(),
  ]);

  static Future<void> error() => _play([
    _HapticStep.medium(),
    _HapticStep.pause(85),
    _HapticStep.medium(),
  ]);

  static Future<void> _play(List<_HapticStep> steps) async {
    for (final step in steps) {
      await step.play();
    }
  }
}

class _HapticStep {
  const _HapticStep._(this._play);

  factory _HapticStep.pause(int milliseconds) {
    return _HapticStep._(
      () => Future<void>.delayed(Duration(milliseconds: milliseconds)),
    );
  }

  factory _HapticStep.selection() {
    return _HapticStep._(HapticFeedback.selectionClick);
  }

  factory _HapticStep.light() {
    return _HapticStep._(HapticFeedback.lightImpact);
  }

  factory _HapticStep.medium() {
    return _HapticStep._(HapticFeedback.mediumImpact);
  }

  factory _HapticStep.heavy() {
    return _HapticStep._(HapticFeedback.heavyImpact);
  }

  final Future<void> Function() _play;

  Future<void> play() => _play();
}
