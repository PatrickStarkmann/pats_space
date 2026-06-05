import 'dart:async';

import 'package:flutter/foundation.dart';

class FocusCharacterAnimator extends ChangeNotifier {
  FocusCharacterAnimator({
    this.frameDuration = const Duration(milliseconds: 1100),
  });

  final Duration frameDuration;
  Timer? _timer;
  int _frameIndex = 0;

  int get frameIndex => _frameIndex;

  void start() {
    if (_timer?.isActive ?? false) {
      return;
    }

    _timer = Timer.periodic(frameDuration, (_) {
      _frameIndex += 1;
      notifyListeners();
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    pause();
    if (_frameIndex == 0) {
      return;
    }

    _frameIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    pause();
    super.dispose();
  }
}
