import 'package:flutter/material.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/looping_asset_animation.dart';

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
  late final Animation<double> _copyOpacity;
  late final Animation<Offset> _copyOffset;

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
    _copyOpacity = copyCurve;
    _copyOffset = Tween<Offset>(
      begin: const Offset(0, .16),
      end: Offset.zero,
    ).animate(copyCurve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _characterOpacity,
                  child: ScaleTransition(
                    scale: _characterScale,
                    child: const SizedBox(
                      width: 184,
                      height: 184,
                      child: LoopingAssetAnimation(
                        frames: AppAssets.focusPair02Focus,
                        frameDuration: Duration(milliseconds: 760),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SlideTransition(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
