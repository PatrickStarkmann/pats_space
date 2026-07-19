import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';

class AppLoadingScreen extends StatefulWidget {
  const AppLoadingScreen({super.key, this.animateEntrance = true});

  final bool animateEntrance;

  @override
  State<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _characterOpacity;
  late final Animation<double> _characterScale;
  late final Animation<Offset> _characterOffset;
  late final Animation<double> _copyOpacity;
  late final Animation<Offset> _copyOffset;
  final List<Timer> _frameTimers = [];
  int _frameIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
      value: widget.animateEntrance ? 0 : 1,
    );
    if (widget.animateEntrance) {
      _controller.forward();
    }
    final characterCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .72, curve: Curves.easeOutCubic),
    );
    final copyCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.28, 1, curve: Curves.easeOutCubic),
    );
    _characterOpacity = characterCurve;
    _characterScale = Tween<double>(begin: .94, end: 1).animate(characterCurve);
    _characterOffset = Tween<Offset>(
      begin: const Offset(.12, 0),
      end: Offset.zero,
    ).animate(characterCurve);
    _copyOpacity = copyCurve;
    _copyOffset = Tween<Offset>(
      begin: const Offset(0, .12),
      end: Offset.zero,
    ).animate(copyCurve);

    if (widget.animateEntrance) {
      _frameTimers.addAll([
        Timer(const Duration(milliseconds: 980), () {
          if (mounted) {
            setState(() => _frameIndex = 1);
          }
        }),
        Timer(const Duration(milliseconds: 1380), () {
          if (mounted) {
            setState(() => _frameIndex = 0);
          }
        }),
      ]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final frame in AppAssets.introCharacterPeek) {
      precacheImage(AssetImage(frame), context);
    }
  }

  @override
  void dispose() {
    for (final timer in _frameTimers) {
      timer.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final characterSize = (width * .92).clamp(320.0, 500.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _characterOffset,
                  child: FadeTransition(
                    opacity: _characterOpacity,
                    child: ScaleTransition(
                      scale: _characterScale,
                      child: SizedBox(
                        width: characterSize,
                        height: characterSize,
                        child: Image.asset(
                          AppAssets.introCharacterPeek[_frameIndex],
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: const Alignment(0, -.28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: SlideTransition(
                      position: _copyOffset,
                      child: FadeTransition(
                        opacity: _copyOpacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Patsspace', style: AppTextStyles.title),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              "let's grow together",
                              style: AppTextStyles.bodyMuted,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
