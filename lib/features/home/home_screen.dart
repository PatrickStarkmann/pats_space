import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/widgets/app_icon_button.dart';
import 'package:pats_space/features/focus/controllers/focus_character_animator.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/focus_animation_catalog.dart';
import 'package:pats_space/features/focus/models/focus_animation_spec.dart';
import 'package:pats_space/features/focus/models/focus_session_phase.dart';
import 'package:pats_space/features/home/widgets/focus_mode_label.dart';
import 'package:pats_space/features/home/widgets/focus_session_dots.dart';
import 'package:pats_space/features/home/widgets/focus_timer_preview.dart';
import 'package:pats_space/features/home/widgets/patsspace_character_view.dart';
import 'package:pats_space/features/home/widgets/time_settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FocusTimerController _timerController;
  late final FocusCharacterAnimator _characterAnimator;
  bool _assetsPrecached = false;

  @override
  void initState() {
    super.initState();
    _timerController = FocusTimerController()..addListener(_syncAnimation);
    _characterAnimator = FocusCharacterAnimator();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAnimationAssets();
  }

  @override
  void dispose() {
    _timerController.removeListener(_syncAnimation);
    _timerController.dispose();
    _characterAnimator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_timerController, _characterAnimator]),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;
            final tight = constraints.maxHeight < 650;
            final topSpace =
                (constraints.maxHeight *
                        (tight
                            ? 0.16
                            : compact
                            ? 0.19
                            : 0.22))
                    .clamp(
                      tight ? AppSpacing.xxl * 1.25 : AppSpacing.xxl * 1.55,
                      AppSpacing.xxl * 3.45,
                    )
                    .toDouble();
            final characterGap = tight
                ? AppSpacing.xl
                : compact
                ? AppSpacing.xxl * 1.25
                : AppSpacing.xxl * 1.75;

            return Column(
              children: [
                SizedBox(height: topSpace),
                FocusModeLabel(
                  label: _focusLabel,
                  accentColor: _timerController.settings.accentColor.color,
                  onPressed: _settingsAction,
                ),
                SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
                FocusTimerPreview(
                  timeLabel: _formatTime(_timerController.remainingSeconds),
                  onPressed: _settingsAction,
                ),
                SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
                FocusSessionDots(states: _timerController.sessionStatuses),
                SizedBox(height: characterGap),
                PatsspaceCharacterView(
                  compact: compact,
                  assetPath: _currentCharacterAsset,
                  visualScale: _currentAnimationSpec.visualScale,
                  alignment: _currentAnimationSpec.alignment,
                  verticalOffset: _currentAnimationSpec.verticalOffset,
                ),
                SizedBox(height: compact ? 0 : AppSpacing.xxs),
                _FocusControls(
                  active: _timerController.active,
                  running: _timerController.running,
                  canSkip:
                      _timerController.phase != FocusSessionPhase.stopwatch,
                  onSkip: _timerController.skip,
                  onPlayPause: _timerController.toggle,
                  onRestart: _timerController.restartCurrentSession,
                  onCancel: _confirmCancelFocusRound,
                ),
                const Spacer(),
              ],
            );
          },
        );
      },
    );
  }

  VoidCallback get _settingsAction => _openSettings;

  String get _focusLabel {
    final label = _timerController.settings.focusLabel.trim();
    return label.isEmpty ? _timerController.modeLabel : label;
  }

  String get _currentCharacterAsset {
    final frames = _currentAnimationSpec.frames;
    return frames[_characterAnimator.frameIndex % frames.length];
  }

  FocusAnimationSpec get _currentAnimationSpec {
    return _timerController.phase == FocusSessionPhase.breakTime
        ? FocusAnimationCatalog.breakSpec(
            _timerController.settings.animationPair,
          )
        : FocusAnimationCatalog.focusSpec(
            _timerController.settings.animationPair,
          );
  }

  Future<void> _openSettings() async {
    final updated = await showTimeSettingsSheet(
      context: context,
      settings: _timerController.settings,
    );

    if (updated == null) {
      return;
    }

    if (_timerController.active && mounted) {
      final shouldCancel = await _confirmSettingsCancelSession();
      if (!shouldCancel) {
        return;
      }
    }

    _timerController.updateSettings(updated);
  }

  Future<bool> _confirmSettingsCancelSession() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Focus läuft gerade'),
          content: const Text(
            'Wenn du die Einstellungen speicherst, wird der aktuelle Fokus abgebrochen.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Zurück'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Abbrechen & speichern'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _confirmCancelFocusRound() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Fokus abbrechen?'),
          content: const Text(
            'Der aktuelle Fokuslauf wird beendet und dein Fortschritt in dieser Runde wird zurückgesetzt.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Zurück'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Fokus abbrechen'),
            ),
          ],
        );
      },
    );

    if (result ?? false) {
      _timerController.cancelFocusRound();
    }
  }

  void _syncAnimation() {
    if (_timerController.running) {
      _characterAnimator.start();
      return;
    }

    if (_timerController.active) {
      _characterAnimator.pause();
      return;
    }

    _characterAnimator.reset();
  }

  void _precacheAnimationAssets() {
    if (_assetsPrecached) {
      return;
    }

    _assetsPrecached = true;
    for (final assetPath in FocusAnimationCatalog.allFrames) {
      precacheImage(AssetImage(assetPath), context);
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _FocusControls extends StatelessWidget {
  const _FocusControls({
    required this.active,
    required this.running,
    required this.canSkip,
    required this.onSkip,
    required this.onPlayPause,
    required this.onRestart,
    required this.onCancel,
  });

  final bool active;
  final bool running;
  final bool canSkip;
  final VoidCallback onSkip;
  final VoidCallback onPlayPause;
  final VoidCallback onRestart;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (running) {
      return AppIconButton(
        icon: CupertinoIcons.pause,
        semanticLabel: 'Pause',
        onPressed: onPlayPause,
      );
    }

    if (!active) {
      return AppIconButton(
        icon: CupertinoIcons.play,
        semanticLabel: 'Start',
        onPressed: onPlayPause,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIconButton(
            icon: CupertinoIcons.forward_end,
            semanticLabel: 'Skip',
            onPressed: active && canSkip ? onSkip : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          AppIconButton(
            icon: CupertinoIcons.play,
            semanticLabel: 'Resume',
            onPressed: onPlayPause,
          ),
          const SizedBox(width: AppSpacing.sm),
          AppIconButton(
            icon: CupertinoIcons.restart,
            semanticLabel: 'Restart',
            onPressed: onRestart,
          ),
          const SizedBox(width: AppSpacing.sm),
          AppIconButton(
            icon: CupertinoIcons.xmark,
            semanticLabel: 'Cancel',
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
