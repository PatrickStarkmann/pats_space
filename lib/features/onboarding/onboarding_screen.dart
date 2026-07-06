import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/looping_asset_animation.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  static const waterReward = 10;

  final Future<void> Function(String? source, int waterReward) onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _challengeDuration = Duration(seconds: 45);
  static const _screenCount = 6;

  int _screenIndex = 0;
  String? _selectedSource;
  bool _challengeRunning = false;
  bool _challengeCompleted = false;
  bool _finishing = false;
  Duration _remaining = _challengeDuration;
  Timer? _challengeTimer;

  @override
  void dispose() {
    _challengeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(.025, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildScreen(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    return switch (_screenIndex) {
      0 => _SpokenOnboardingScreen(
        key: const ValueKey('welcome'),
        progressIndex: _screenIndex,
        title: 'Welcome to Patsspace',
        body: 'A cozy little focus app that helps your space grow.',
        actionLabel: 'Continue',
        visualBuilder: (speaking) => _PatTalkingVisual(speaking: speaking),
        onContinue: _nextScreen,
      ),
      1 => _PatIntroScreen(
        key: const ValueKey('pat-intro'),
        progressIndex: _screenIndex,
        onContinue: _nextScreen,
      ),
      2 => _SpokenOnboardingScreen(
        key: const ValueKey('loop'),
        progressIndex: _screenIndex,
        title: 'Focus, earn, grow',
        body:
            'Stay focused, earn Waterdrops, and use them to grow plants in your space.',
        actionLabel: 'Continue',
        visualBuilder: (_) => const _FocusEarnGrowVisual(),
        bodyBeforeVisual: true,
        bodyAlignment: Alignment.topCenter,
        visualAlignment: Alignment.topCenter,
        bodyFlex: 3,
        visualFlex: 6,
        onContinue: _nextScreen,
      ),
      3 => _SourceScreen(
        key: const ValueKey('source'),
        progressIndex: _screenIndex,
        selectedSource: _selectedSource,
        onSourceSelected: (source) {
          AppHaptics.selection();
          setState(() => _selectedSource = source);
        },
        onContinue: _nextScreen,
      ),
      4 => _SpokenOnboardingScreen(
        key: const ValueKey('challenge-start'),
        progressIndex: _screenIndex,
        title: 'Let’s start small',
        body: 'Try a 45-second focus challenge with me.',
        actionLabel: 'Start challenge',
        visualBuilder: (_) => const _FocusChallengePreview(),
        onContinue: _startChallengeFromIntro,
      ),
      _ => _ChallengeScreen(
        key: const ValueKey('challenge'),
        progressIndex: _screenIndex,
        running: _challengeRunning,
        completed: _challengeCompleted,
        remaining: _remaining,
        duration: _challengeDuration,
        finishing: _finishing,
        onStart: _startChallenge,
        onFinish: _finishOnboarding,
      ),
    };
  }

  void _nextScreen() {
    AppHaptics.lightImpact();
    setState(() => _screenIndex += 1);
  }

  void _startChallenge() {
    if (_challengeRunning || _challengeCompleted) {
      return;
    }

    AppHaptics.mediumImpact();
    setState(() {
      _remaining = _challengeDuration;
      _challengeRunning = true;
    });

    _startChallengeTimer();
  }

  void _startChallengeFromIntro() {
    if (_challengeRunning || _challengeCompleted) {
      return;
    }

    AppHaptics.mediumImpact();
    setState(() {
      _screenIndex += 1;
      _remaining = _challengeDuration;
      _challengeRunning = true;
    });

    _startChallengeTimer();
  }

  void _startChallengeTimer() {
    _challengeTimer?.cancel();
    _challengeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final next = _remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        AppHaptics.success();
        setState(() {
          _remaining = Duration.zero;
          _challengeRunning = false;
          _challengeCompleted = true;
        });
        return;
      }

      setState(() => _remaining = next);
    });
  }

  Future<void> _finishOnboarding() async {
    if (!_challengeCompleted || _finishing) {
      return;
    }

    setState(() => _finishing = true);
    await widget.onFinished(_selectedSource, OnboardingScreen.waterReward);
  }
}

class _PatIntroScreen extends StatefulWidget {
  const _PatIntroScreen({
    super.key,
    required this.progressIndex,
    required this.onContinue,
  });

  final int progressIndex;
  final VoidCallback onContinue;

  @override
  State<_PatIntroScreen> createState() => _PatIntroScreenState();
}

class _PatIntroScreenState extends State<_PatIntroScreen> {
  bool _speaking = true;
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      progressIndex: widget.progressIndex,
      visual: _PatTalkingVisual(speaking: _speaking),
      body: _SpokenCopy(
        title: 'Hi, I’m Pat.',
        body: 'I’ll show you around.',
        onSpeakingChanged: (speaking) {
          if (mounted) {
            setState(() => _speaking = speaking);
          }
        },
        onCompleted: () {
          if (mounted) {
            setState(() => _ready = true);
          }
        },
      ),
      actionLabel: 'Hi Pat',
      actionEnabled: _ready,
      onAction: widget.onContinue,
    );
  }
}

class _SpokenOnboardingScreen extends StatefulWidget {
  const _SpokenOnboardingScreen({
    super.key,
    required this.progressIndex,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.visualBuilder,
    required this.onContinue,
    this.bodyBeforeVisual = false,
    this.visualAlignment = Alignment.center,
    this.bodyAlignment = Alignment.center,
    this.visualFlex = 5,
    this.bodyFlex = 4,
  });

  final int progressIndex;
  final String title;
  final String body;
  final String actionLabel;
  final Widget Function(bool speaking) visualBuilder;
  final VoidCallback onContinue;
  final bool bodyBeforeVisual;
  final Alignment visualAlignment;
  final Alignment bodyAlignment;
  final int visualFlex;
  final int bodyFlex;

  @override
  State<_SpokenOnboardingScreen> createState() =>
      _SpokenOnboardingScreenState();
}

class _SpokenOnboardingScreenState extends State<_SpokenOnboardingScreen> {
  bool _speaking = true;
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      progressIndex: widget.progressIndex,
      visual: widget.visualBuilder(_speaking),
      bodyBeforeVisual: widget.bodyBeforeVisual,
      visualAlignment: widget.visualAlignment,
      bodyAlignment: widget.bodyAlignment,
      visualFlex: widget.visualFlex,
      bodyFlex: widget.bodyFlex,
      body: _SpokenCopy(
        title: widget.title,
        body: widget.body,
        onSpeakingChanged: (speaking) {
          if (mounted) {
            setState(() => _speaking = speaking);
          }
        },
        onCompleted: () {
          if (mounted) {
            setState(() => _ready = true);
          }
        },
      ),
      actionLabel: widget.actionLabel,
      actionEnabled: _ready,
      onAction: widget.onContinue,
    );
  }
}

class _SourceScreen extends StatelessWidget {
  const _SourceScreen({
    super.key,
    required this.progressIndex,
    required this.selectedSource,
    required this.onSourceSelected,
    required this.onContinue,
  });

  final int progressIndex;
  final String? selectedSource;
  final ValueChanged<String> onSourceSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      progressIndex: progressIndex,
      visual: const _AlmostThereLabel(),
      visualFlex: 1,
      bodyFlex: 8,
      bodyAlignment: Alignment.topCenter,
      body: Column(
        children: [
          Text(
            'One quick question',
            style: AppTextStyles.caption.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Where did you first hear about Patsspace?',
            style: AppTextStyles.title.copyWith(fontSize: 27),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This helps us understand what’s working.',
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SourceGrid(
            selectedSource: selectedSource,
            onSourceSelected: onSourceSelected,
          ),
        ],
      ),
      actionLabel: 'Continue',
      actionEnabled: selectedSource != null,
      onAction: onContinue,
    );
  }
}

class _ChallengeScreen extends StatelessWidget {
  const _ChallengeScreen({
    super.key,
    required this.progressIndex,
    required this.running,
    required this.completed,
    required this.remaining,
    required this.duration,
    required this.finishing,
    required this.onStart,
    required this.onFinish,
  });

  final int progressIndex;
  final bool running;
  final bool completed;
  final Duration remaining;
  final Duration duration;
  final bool finishing;
  final VoidCallback onStart;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final title = completed
        ? 'Nice work!'
        : running
        ? 'Stay with it'
        : 'Ready when you are';
    final body = completed
        ? 'You completed your first focus challenge.'
        : running
        ? 'You’re doing great.'
        : 'Tap start and stay with Pat until the timer ends.';
    final actionLabel = completed
        ? finishing
              ? 'Opening Garden...'
              : 'Plant your first seed'
        : running
        ? 'Stay focused'
        : 'Start';

    return _OnboardingFrame(
      progressIndex: progressIndex,
      visualAlignment: Alignment.bottomCenter,
      visual: _ChallengeVisual(
        running: running,
        completed: completed,
        remaining: remaining,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: completed
                ? Padding(
                    key: const ValueKey('reward'),
                    padding: const EdgeInsets.only(top: AppSpacing.xl),
                    child: const _WaterRewardValue(amount: 10),
                  )
                : const SizedBox.shrink(key: ValueKey('no-reward')),
          ),
        ],
      ),
      actionLabel: actionLabel,
      actionEnabled: !running,
      onAction: completed ? onFinish : onStart,
    );
  }
}

class _OnboardingFrame extends StatelessWidget {
  const _OnboardingFrame({
    required this.progressIndex,
    required this.visual,
    required this.body,
    required this.actionLabel,
    required this.actionEnabled,
    required this.onAction,
    this.visualFlex = 5,
    this.bodyFlex = 4,
    this.bodyBeforeVisual = false,
    this.visualAlignment = Alignment.center,
    this.bodyAlignment = Alignment.center,
  });

  final int progressIndex;
  final Widget visual;
  final Widget body;
  final String actionLabel;
  final bool actionEnabled;
  final VoidCallback onAction;
  final int visualFlex;
  final int bodyFlex;
  final bool bodyBeforeVisual;
  final Alignment visualAlignment;
  final Alignment bodyAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 700;
        final headerGap = compact ? AppSpacing.md : AppSpacing.lg;
        final sectionGap = compact ? AppSpacing.sm : AppSpacing.md;
        final visualSection = Expanded(
          flex: visualFlex,
          child: Align(alignment: visualAlignment, child: visual),
        );
        final bodySection = Expanded(
          flex: bodyFlex,
          child: Align(alignment: bodyAlignment, child: body),
        );

        return Column(
          children: [
            _ProgressPills(
              count: _OnboardingScreenState._screenCount,
              activeIndex: progressIndex,
            ),
            SizedBox(height: headerGap),
            if (bodyBeforeVisual) ...[
              bodySection,
              SizedBox(height: sectionGap),
              visualSection,
            ] else ...[
              visualSection,
              SizedBox(height: sectionGap),
              bodySection,
            ],
            SizedBox(height: sectionGap),
            _OnboardingButton(
              label: actionLabel,
              enabled: actionEnabled,
              onPressed: onAction,
            ),
          ],
        );
      },
    );
  }
}

class _SpokenCopy extends StatefulWidget {
  const _SpokenCopy({
    required this.title,
    required this.body,
    required this.onSpeakingChanged,
    required this.onCompleted,
  });

  final String title;
  final String body;
  final ValueChanged<bool> onSpeakingChanged;
  final VoidCallback onCompleted;

  @override
  State<_SpokenCopy> createState() => _SpokenCopyState();
}

class _SpokenCopyState extends State<_SpokenCopy> {
  static const _titleStep = Duration(milliseconds: 32);
  static const _bodyStep = Duration(milliseconds: 17);

  Timer? _timer;
  int _titleCharacters = 0;
  int _bodyCharacters = 0;
  bool _bodyStarted = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onSpeakingChanged(true);
        _startTitle();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTitle() {
    _timer?.cancel();
    _timer = Timer.periodic(_titleStep, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_titleCharacters >= widget.title.length) {
        timer.cancel();
        Future<void>.delayed(const Duration(milliseconds: 120), () {
          if (mounted) {
            setState(() => _bodyStarted = true);
            _startBody();
          }
        });
        return;
      }

      setState(() => _titleCharacters += 1);
    });
  }

  void _startBody() {
    _timer?.cancel();
    _timer = Timer.periodic(_bodyStep, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_bodyCharacters >= widget.body.length) {
        timer.cancel();
        _finish();
        return;
      }

      setState(() => _bodyCharacters += 1);
    });
  }

  void _finish() {
    if (_completed) {
      return;
    }

    _completed = true;
    widget.onSpeakingChanged(false);
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title.characters.take(_titleCharacters).toString();
    final body = widget.body.characters.take(_bodyCharacters).toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 140),
          opacity: _bodyStarted ? 1 : 0,
          child: Text(
            body,
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _PatTalkingVisual extends StatelessWidget {
  const _PatTalkingVisual({this.speaking = false});

  final bool speaking;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 18),
      child: LoopingAssetAnimation(
        frames: AppAssets.onboardingPatTalking,
        frameDuration: const Duration(milliseconds: 360),
        fit: BoxFit.contain,
        playing: speaking,
      ),
    );
  }
}

class _FocusChallengePreview extends StatelessWidget {
  const _FocusChallengePreview();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 240,
      child: LoopingAssetAnimation(
        frames: AppAssets.focusPair02Focus,
        frameDuration: Duration(milliseconds: 900),
      ),
    );
  }
}

class _ChallengeVisual extends StatelessWidget {
  const _ChallengeVisual({
    required this.running,
    required this.completed,
    required this.remaining,
  });

  final bool running;
  final bool completed;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 320.0;
        final timerHeight = (availableHeight * .28).clamp(56.0, 82.0);
        final gap = (availableHeight * .06).clamp(12.0, 22.0);
        final imageHeight = (availableHeight - timerHeight - gap).clamp(
          150.0,
          210.0,
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: timerHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  completed ? '00:00' : _formatRemaining(remaining),
                  maxLines: 1,
                  style: AppTextStyles.timer.copyWith(fontSize: 82),
                ),
              ),
            ),
            SizedBox(height: gap),
            SizedBox(
              width: imageHeight * 1.24,
              height: imageHeight,
              child: LoopingAssetAnimation(
                frames: AppAssets.focusPair02Focus,
                frameDuration: const Duration(milliseconds: 900),
                playing: running,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatRemaining(Duration value) {
    final seconds = value.inSeconds.clamp(0, 99).toString().padLeft(2, '0');
    return '00:$seconds';
  }
}

class _FocusEarnGrowVisual extends StatelessWidget {
  const _FocusEarnGrowVisual();

  @override
  Widget build(BuildContext context) {
    const items = [
      _LoopItem(
        icon: PhosphorIconsRegular.timer,
        title: '1. Focus',
        body: 'You focus with intention.',
      ),
      _LoopItem(
        icon: PhosphorIconsRegular.drop,
        title: '2. Earn',
        body: 'You earn Waterdrops.',
      ),
      _LoopItem(
        icon: PhosphorIconsRegular.plant,
        title: '3. Grow',
        body: 'Your plant grows as you keep going.',
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Row(
                children: [
                  _LoopIcon(icon: items[index].icon),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[index].title,
                          style: AppTextStyles.headline.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          items[index].body,
                          style: AppTextStyles.bodyMuted.copyWith(
                            fontSize: 15,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (index < items.length - 1)
                Row(
                  children: [
                    SizedBox(
                      width: 68,
                      height: 28,
                      child: CustomPaint(painter: _DashedLinePainter()),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoopItem {
  const _LoopItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _WaterRewardValue extends StatelessWidget {
  const _WaterRewardValue({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('reward'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PhosphorIcon(
          PhosphorIconsFill.drop,
          color: Color(0xFF65A9F7),
          size: 30,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '+$amount',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.charcoal,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LoopIcon extends StatelessWidget {
  const _LoopIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: .52),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 68,
        child: Icon(icon, color: AppColors.charcoal, size: 34),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.graySoft
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    var y = 0.0;
    final x = size.width / 2;
    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 5), paint);
      y += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlmostThereLabel extends StatelessWidget {
  const _AlmostThereLabel();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Text(
        'Almost there!',
        style: AppTextStyles.bodyMuted.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SourceGrid extends StatelessWidget {
  const _SourceGrid({
    required this.selectedSource,
    required this.onSourceSelected,
  });

  final String? selectedSource;
  final ValueChanged<String> onSourceSelected;

  static const sources = [
    _SourceOption('TikTok', PhosphorIconsRegular.tiktokLogo),
    _SourceOption('Instagram', PhosphorIconsRegular.instagramLogo),
    _SourceOption('YouTube', PhosphorIconsRegular.youtubeLogo),
    _SourceOption('App Store', PhosphorIconsRegular.appStoreLogo),
    _SourceOption('Friend', PhosphorIconsRegular.users),
    _SourceOption('Search', PhosphorIconsRegular.magnifyingGlass),
    _SourceOption('Other', PhosphorIconsRegular.dotsThree),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final source in sources)
              _SourceTile(
                width: source.label == 'Other'
                    ? constraints.maxWidth
                    : tileWidth,
                source: source,
                selected: selectedSource == source.label,
                onTap: () => onSourceSelected(source.label),
              ),
          ],
        );
      },
    );
  }
}

class _SourceOption {
  const _SourceOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.width,
    required this.source,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final _SourceOption source;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: width,
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.charcoal : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected
                ? AppColors.charcoal
                : AppColors.graySoft.withValues(alpha: .42),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: selected ? .1 : .045),
              blurRadius: selected ? 18 : 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              source.icon,
              color: selected ? AppColors.surface : AppColors.charcoal,
              size: 25,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              source.label,
              style: AppTextStyles.body.copyWith(
                color: selected ? AppColors.surface : AppColors.charcoal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingButton extends StatefulWidget {
  const _OnboardingButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              AppHaptics.lightImpact();
              widget.onPressed();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? .985 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.charcoal
                : AppColors.graySoft.withValues(alpha: .58),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.button.copyWith(
              color: enabled ? AppColors.surface : AppColors.grayWarm,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressPills extends StatelessWidget {
  const _ProgressPills({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: index == activeIndex ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: index == activeIndex
                  ? AppColors.charcoal
                  : AppColors.graySoft.withValues(alpha: .48),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          if (index < count - 1) const SizedBox(width: 7),
        ],
      ],
    );
  }
}
