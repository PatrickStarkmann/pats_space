import 'dart:async';

import 'package:flutter/widgets.dart';

class LoopingAssetAnimation extends StatefulWidget {
  const LoopingAssetAnimation({
    super.key,
    required this.frames,
    this.frameDuration = const Duration(milliseconds: 1100),
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.playing = true,
    this.loop = true,
    this.initialFrameIndex = 0,
  });

  final List<String> frames;
  final Duration frameDuration;
  final BoxFit fit;
  final Alignment alignment;
  final bool playing;
  final bool loop;
  final int initialFrameIndex;

  @override
  State<LoopingAssetAnimation> createState() => _LoopingAssetAnimationState();
}

class _LoopingAssetAnimationState extends State<LoopingAssetAnimation> {
  Timer? _timer;
  int _frameIndex = 0;

  @override
  void initState() {
    super.initState();
    _frameIndex = widget.initialFrameIndex;
    _start();
  }

  @override
  void didUpdateWidget(covariant LoopingAssetAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frames != widget.frames ||
        oldWidget.frameDuration != widget.frameDuration ||
        oldWidget.initialFrameIndex != widget.initialFrameIndex) {
      _frameIndex = widget.initialFrameIndex;
      _start();
    } else if (oldWidget.playing != widget.playing) {
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    if (!widget.playing || widget.frames.length < 2) {
      return;
    }

    _timer = Timer.periodic(widget.frameDuration, (_) {
      if (!mounted) {
        return;
      }

      final nextFrameIndex = _frameIndex + 1;
      if (!widget.loop && nextFrameIndex >= widget.frames.length) {
        _timer?.cancel();
        return;
      }

      setState(() {
        _frameIndex = nextFrameIndex % widget.frames.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Image.asset(
      widget.frames[_frameIndex % widget.frames.length],
      fit: widget.fit,
      alignment: widget.alignment,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
    );
  }
}
