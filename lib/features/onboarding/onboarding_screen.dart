import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/looping_asset_animation.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onStartFocusChallenge});

  final void Function(String? source) onStartFocusChallenge;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _screenCount = 5;

  int _screenIndex = 0;
  String? _selectedSource;

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
                duration: const Duration(milliseconds: 360),
                transitionBuilder: (child, animation) {
                  final opacity = CurvedAnimation(
                    parent: animation,
                    curve: const Interval(.48, 1, curve: Curves.easeOutCubic),
                  );
                  return FadeTransition(
                    opacity: opacity,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(.018, 0),
                        end: Offset.zero,
                      ).animate(opacity),
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
    final l10n = AppLocalizations.of(context);
    return switch (_screenIndex) {
      0 => _SpokenOnboardingScreen(
        key: const ValueKey('welcome'),
        progressIndex: _screenIndex,
        title: l10n.onboardingWelcomeTitle,
        body: l10n.onboardingWelcomeBody,
        actionLabel: l10n.continueAction,
        visualBuilder: (_) => const SizedBox.shrink(),
        visualFlex: 1,
        bodyFlex: 8,
        bodyAlignment: const Alignment(0, -.12),
        onContinue: _nextScreen,
      ),
      1 => _PatIntroScreen(
        key: const ValueKey('pat-intro'),
        progressIndex: _screenIndex,
        onContinue: _nextScreen,
      ),
      2 => _FocusEarnGrowScreen(
        key: const ValueKey('loop'),
        progressIndex: _screenIndex,
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
        title: l10n.onboardingStartSmallTitle,
        body: l10n.onboardingStartSmallBody,
        actionLabel: l10n.onboardingStartChallenge,
        visualBuilder: (_) => const _FocusChallengePreview(),
        visualAlignment: const Alignment(0, .45),
        onContinue: _startFocusChallenge,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  void _nextScreen() {
    AppHaptics.lightImpact();
    setState(() => _screenIndex += 1);
  }

  void _startFocusChallenge() {
    AppHaptics.mediumImpact();
    widget.onStartFocusChallenge(_selectedSource);
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
    final l10n = AppLocalizations.of(context);
    return _OnboardingFrame(
      progressIndex: widget.progressIndex,
      visual: _PatTalkingVisual(speaking: _speaking),
      body: _SpokenCopy(
        title: l10n.onboardingPatTitle,
        body: l10n.onboardingPatBody,
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
      actionLabel: l10n.onboardingPatAction,
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

class _FocusEarnGrowScreen extends StatefulWidget {
  const _FocusEarnGrowScreen({
    super.key,
    required this.progressIndex,
    required this.onContinue,
  });

  final int progressIndex;
  final VoidCallback onContinue;

  @override
  State<_FocusEarnGrowScreen> createState() => _FocusEarnGrowScreenState();
}

class _FocusEarnGrowScreenState extends State<_FocusEarnGrowScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() => _ready = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _OnboardingFrame(
      progressIndex: widget.progressIndex,
      bodyBeforeVisual: true,
      bodyFlex: 3,
      visualFlex: 6,
      bodyAlignment: const Alignment(0, .32),
      visualAlignment: Alignment.topCenter,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.onboardingFocusEarnGrowTitle,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.onboardingFocusEarnGrowBody,
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      visual: Transform.translate(
        offset: const Offset(0, -34),
        child: const _FocusEarnGrowVisual(),
      ),
      actionLabel: l10n.continueAction,
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
    final l10n = AppLocalizations.of(context);
    return _OnboardingFrame(
      progressIndex: progressIndex,
      visual: const _AlmostThereLabel(),
      visualFlex: 1,
      bodyFlex: 8,
      bodyAlignment: Alignment.topCenter,
      body: Column(
        children: [
          Text(
            l10n.onboardingSourceEyebrow,
            style: AppTextStyles.caption.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.onboardingSourceTitle,
            style: AppTextStyles.title.copyWith(fontSize: 27),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.onboardingSourceBody,
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
      actionLabel: l10n.continueAction,
      actionEnabled: selectedSource != null,
      onAction: onContinue,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ProgressiveText(
          text: widget.title,
          visibleCharacters: _titleCharacters,
          style: AppTextStyles.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 140),
          opacity: _bodyStarted ? 1 : 0,
          child: _ProgressiveText(
            text: widget.body,
            visibleCharacters: _bodyStarted ? _bodyCharacters : 0,
            style: AppTextStyles.bodyMuted,
          ),
        ),
      ],
    );
  }
}

class _ProgressiveText extends StatelessWidget {
  const _ProgressiveText({
    required this.text,
    required this.visibleCharacters,
    required this.style,
  });

  final String text;
  final int visibleCharacters;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final characters = text.characters;
    final visible = characters.take(visibleCharacters).toString();
    final hidden = characters.skip(visibleCharacters).toString();
    final baseColor =
        style.color ??
        DefaultTextStyle.of(context).style.color ??
        AppColors.charcoal;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: visible, style: style),
          TextSpan(
            text: hidden,
            style: style.copyWith(color: baseColor.withValues(alpha: 0)),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PatTalkingVisual extends StatelessWidget {
  const _PatTalkingVisual({this.speaking = false});

  final bool speaking;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 66),
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
    return Transform.translate(
      offset: const Offset(0, 68),
      child: const SizedBox(
        height: 330,
        child: LoopingAssetAnimation(
          frames: AppAssets.focusPair02Focus,
          frameDuration: Duration(milliseconds: 900),
        ),
      ),
    );
  }
}

class _FocusEarnGrowVisual extends StatefulWidget {
  const _FocusEarnGrowVisual();

  @override
  State<_FocusEarnGrowVisual> createState() => _FocusEarnGrowVisualState();
}

class _FocusEarnGrowVisualState extends State<_FocusEarnGrowVisual> {
  int _visibleSteps = 0;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    _startReveal();
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  void _startReveal() {
    _revealTimer?.cancel();
    setState(() => _visibleSteps = 0);
    _revealTimer = Timer.periodic(const Duration(milliseconds: 420), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_visibleSteps >= 3) {
        timer.cancel();
        return;
      }

      setState(() => _visibleSteps += 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      _LoopItem(
        icon: PhosphorIconsRegular.timer,
        title: l10n.onboardingStepFocusTitle,
        body: l10n.onboardingStepFocusBody,
      ),
      _LoopItem(
        icon: PhosphorIconsRegular.drop,
        title: l10n.onboardingStepEarnTitle,
        body: l10n.onboardingStepEarnBody,
      ),
      _LoopItem(
        icon: PhosphorIconsRegular.plant,
        title: l10n.onboardingStepGrowTitle,
        body: l10n.onboardingStepGrowBody,
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _StepReveal(
                visible: index < _visibleSteps,
                child: Row(
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
              ),
              if (index < items.length - 1)
                _StepReveal(
                  visible: index + 1 < _visibleSteps,
                  subtle: true,
                  child: Row(
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
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepReveal extends StatelessWidget {
  const _StepReveal({
    required this.visible,
    required this.child,
    this.subtle = false,
  });

  final bool visible;
  final Widget child;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final duration = subtle
        ? const Duration(milliseconds: 260)
        : const Duration(milliseconds: 420);
    return AnimatedSlide(
      duration: duration,
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : Offset(0, subtle ? .02 : .11),
      child: AnimatedScale(
        duration: duration,
        curve: subtle ? Curves.easeOutCubic : Curves.easeOutBack,
        scale: visible
            ? 1
            : subtle
            ? 1
            : .92,
        child: AnimatedOpacity(
          duration: duration,
          curve: Curves.easeOutCubic,
          opacity: visible ? 1 : 0,
          child: child,
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
        AppLocalizations.of(context).onboardingSourceAlmostThere,
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

  List<_SourceOption> _sources(AppLocalizations l10n) {
    return [
      _SourceOption(
        'tiktok',
        l10n.onboardingSourceTikTok,
        PhosphorIconsRegular.tiktokLogo,
      ),
      _SourceOption(
        'instagram',
        l10n.onboardingSourceInstagram,
        PhosphorIconsRegular.instagramLogo,
      ),
      _SourceOption(
        'youtube',
        l10n.onboardingSourceYouTube,
        PhosphorIconsRegular.youtubeLogo,
      ),
      _SourceOption(
        'app_store',
        l10n.onboardingSourceAppStore,
        PhosphorIconsRegular.appStoreLogo,
      ),
      _SourceOption(
        'friend',
        l10n.onboardingSourceFriend,
        PhosphorIconsRegular.users,
      ),
      _SourceOption(
        'search',
        l10n.onboardingSourceSearch,
        PhosphorIconsRegular.magnifyingGlass,
      ),
      _SourceOption(
        'other',
        l10n.onboardingSourceOther,
        PhosphorIconsRegular.dotsThree,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sources = _sources(AppLocalizations.of(context));
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final source in sources)
              _SourceTile(
                width: source.id == 'other' ? constraints.maxWidth : tileWidth,
                source: source,
                selected: selectedSource == source.id,
                onTap: () => onSourceSelected(source.id),
              ),
          ],
        );
      },
    );
  }
}

class _SourceOption {
  const _SourceOption(this.id, this.label, this.icon);

  final String id;
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
