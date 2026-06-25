import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/app_icon_button.dart';
import 'package:pats_space/features/focus/controllers/focus_character_animator.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/focus_reward_calculator.dart';
import 'package:pats_space/features/focus/focus_animation_catalog.dart';
import 'package:pats_space/features/focus/models/focus_animation_spec.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_session_phase.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/focus/repositories/focus_settings_repository.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/home/widgets/focus_completion_sheet.dart';
import 'package:pats_space/features/home/widgets/focus_mode_label.dart';
import 'package:pats_space/features/home/widgets/focus_session_dots.dart';
import 'package:pats_space/features/home/widgets/focus_timer_preview.dart';
import 'package:pats_space/features/home/widgets/group_focus_lobby_sheet.dart';
import 'package:pats_space/features/home/widgets/group_focus_room_sheet.dart';
import 'package:pats_space/features/home/widgets/patsspace_character_view.dart';
import 'package:pats_space/features/home/widgets/social_focus_group_view.dart';
import 'package:pats_space/features/home/widgets/time_settings_sheet.dart';
import 'package:pats_space/features/social_focus/controllers/social_focus_controller.dart';
import 'package:pats_space/features/social_focus/models/social_focus_models.dart';
import 'package:pats_space/features/social_focus/repositories/fake_social_focus_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.historyController,
    required this.gardenController,
    required this.initialSettings,
    required this.settingsRepository,
    required this.onOpenSpace,
  });

  final FocusHistoryController historyController;
  final GardenController gardenController;
  final FocusTimerSettings initialSettings;
  final FocusSettingsRepository settingsRepository;
  final VoidCallback onOpenSpace;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FocusTimerController _timerController;
  late final FocusCharacterAnimator _characterAnimator;
  late final SocialFocusController _socialFocusController;
  bool _assetsPrecached = false;
  _FocusCompletionReward? _completionReward;
  Duration _pendingRewardDuration = Duration.zero;
  int _pendingWaterReward = 0;
  _FocusViewMode _focusViewMode = _FocusViewMode.solo;

  @override
  void initState() {
    super.initState();
    _socialFocusController = SocialFocusController(
      repository: FakeSocialFocusRepository(),
    );
    _timerController = FocusTimerController(
      initialSettings: widget.initialSettings,
      onFocusSessionCompleted: _handleFocusSessionCompleted,
      onFocusRoundCompleted: _handleFocusRoundCompleted,
    )..addListener(_syncAnimation);
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
    _socialFocusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _timerController,
        _characterAnimator,
        _socialFocusController,
      ]),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bottomNavigationInset =
                MediaQuery.paddingOf(context).bottom + AppSpacing.xs * 2 + 44;
            final availableHeight =
                constraints.maxHeight - bottomNavigationInset;
            final compact = availableHeight < 720;
            final tight = availableHeight < 650;
            final groupMode = _focusViewMode == _FocusViewMode.group;
            final groupParticipantCount =
                _socialFocusController.activeRoom?.members.length ?? 0;
            final singleGroup = groupMode && groupParticipantCount == 1;
            final compactGroup = groupMode && groupParticipantCount < 4;
            final mediumGroup = groupMode && groupParticipantCount == 3;
            final topSpace =
                (availableHeight *
                        (singleGroup
                            ? (tight
                                  ? 0.08
                                  : compact
                                  ? 0.10
                                  : 0.12)
                            : compactGroup
                            ? (tight
                                  ? 0.11
                                  : compact
                                  ? 0.14
                                  : 0.16)
                            : groupMode
                            ? (tight
                                  ? 0.06
                                  : compact
                                  ? 0.08
                                  : 0.10)
                            : tight
                            ? 0.16
                            : compact
                            ? 0.19
                            : 0.22))
                    .clamp(
                      singleGroup
                          ? (tight ? AppSpacing.lg : AppSpacing.xl)
                          : compactGroup
                          ? (tight ? AppSpacing.xl : AppSpacing.xxl)
                          : groupMode
                          ? (tight ? AppSpacing.lg : AppSpacing.xl)
                          : (tight
                                ? AppSpacing.xxl * 1.25
                                : AppSpacing.xxl * 1.55),
                      singleGroup
                          ? AppSpacing.xxl * 1.8
                          : compactGroup
                          ? AppSpacing.xxl * 2.5
                          : groupMode
                          ? AppSpacing.xxl * 1.7
                          : AppSpacing.xxl * 3.45,
                    )
                    .toDouble();
            final characterGap = tight
                ? AppSpacing.xl
                : compact
                ? AppSpacing.xxl * 1.25
                : AppSpacing.xxl * 1.75;
            final groupCharacterGap = compactGroup
                ? singleGroup
                      ? (tight ? AppSpacing.md : AppSpacing.lg)
                      : (tight ? AppSpacing.xl : AppSpacing.xxl)
                : (tight ? AppSpacing.lg : AppSpacing.xl);
            final groupControlsGap = tight ? AppSpacing.sm : AppSpacing.md;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: bottomNavigationInset),
                  child: Column(
                    children: [
                      SizedBox(height: topSpace),
                      FocusModeLabel(
                        label: _focusLabel,
                        accentColor:
                            _timerController.settings.accentColor.color,
                        onPressed: _settingsAction,
                      ),
                      SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
                      FocusTimerPreview(
                        timeLabel: _formatTime(
                          _timerController.remainingSeconds,
                        ),
                        onPressed: _settingsAction,
                      ),
                      SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
                      if (!_timerController.isStopwatch)
                        FocusSessionDots(
                          states: _timerController.sessionStatuses,
                        ),
                      if (groupMode &&
                          _socialFocusController.activeRoom != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _GroupRoomPill(
                          room: _socialFocusController.activeRoom!,
                          onPressed: _openGroupRoomSheet,
                        ),
                      ],
                      SizedBox(
                        height: groupMode ? groupCharacterGap : characterGap,
                      ),
                      if (groupMode && !compactGroup)
                        Flexible(
                          flex: 5,
                          fit: FlexFit.tight,
                          child: SocialFocusGroupView(
                            participants: _groupParticipants,
                            active: _timerController.active,
                            running: _timerController.running,
                            inBreak:
                                _timerController.phase ==
                                FocusSessionPhase.breakTime,
                            compact: compact,
                          ),
                        )
                      else if (groupMode)
                        SocialFocusGroupView(
                          participants: _groupParticipants,
                          active: _timerController.active,
                          running: _timerController.running,
                          inBreak:
                              _timerController.phase ==
                              FocusSessionPhase.breakTime,
                          compact: compact,
                        )
                      else
                        PatsspaceCharacterView(
                          compact: compact,
                          assetPath: _currentCharacterAsset,
                          visualScale: _currentAnimationSpec.visualScale,
                          alignment: _currentAnimationSpec.alignment,
                          verticalOffset: _currentAnimationSpec.verticalOffset,
                        ),
                      SizedBox(
                        height: groupMode
                            ? groupControlsGap
                            : compact
                            ? 0
                            : AppSpacing.xxs,
                      ),
                      _FocusControls(
                        active: _timerController.active,
                        running: _timerController.running,
                        stopwatch: _timerController.isStopwatch,
                        canSkip:
                            _timerController.phase !=
                            FocusSessionPhase.stopwatch,
                        onSkip: () {
                          _handleSkip();
                        },
                        onPlayPause: _timerController.toggle,
                        onRestart: _timerController.restartCurrentSession,
                        onFinish: () {
                          _handleFinishStopwatch();
                        },
                        onCancel: _confirmCancelFocusRound,
                      ),
                      if (!groupMode || (compactGroup && !mediumGroup))
                        const Spacer(),
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
                  left: 0,
                  child: _FocusViewModeToggle(
                    selectedMode: _focusViewMode,
                    onChanged: _handleFocusViewModeChanged,
                  ),
                ),
                if (_completionReward != null)
                  Positioned(
                    left: -AppSpacing.screenHorizontal,
                    right: -AppSpacing.screenHorizontal,
                    bottom: bottomNavigationInset,
                    child: FocusCompletionSheet(
                      focusDuration: _completionReward!.focusDuration,
                      waterReward: _completionReward!.waterReward,
                      onContinue: _dismissCompletionReward,
                      onOpenSpace: _openSpaceFromCompletion,
                    ),
                  ),
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
    final showBreakAnimation =
        _timerController.phase == FocusSessionPhase.breakTime ||
        (_timerController.isStopwatch &&
            _timerController.active &&
            !_timerController.running);

    return showBreakAnimation
        ? FocusAnimationCatalog.breakSpec(
            _timerController.settings.animationPair,
          )
        : FocusAnimationCatalog.focusSpec(
            _timerController.settings.animationPair,
          );
  }

  Future<void> _handleFocusViewModeChanged(_FocusViewMode mode) async {
    if (mode == _FocusViewMode.solo) {
      if (!_socialFocusController.hasActiveRoom) {
        setState(() => _focusViewMode = _FocusViewMode.solo);
        return;
      }

      final shouldLeave = await _confirmLeaveGroupFocus();
      if (!mounted || !shouldLeave) {
        return;
      }

      await _socialFocusController.leaveRoom();
      if (!mounted) {
        return;
      }

      setState(() => _focusViewMode = _FocusViewMode.solo);
      return;
    }

    if (_socialFocusController.hasActiveRoom) {
      setState(() => _focusViewMode = _FocusViewMode.group);
      return;
    }

    final snapshot = await _socialFocusController.loadLobby();
    if (!mounted) {
      return;
    }

    final selection = await showGroupFocusLobbySheet(
      context: context,
      snapshot: snapshot,
    );
    if (!mounted) {
      return;
    }

    if (selection == null) {
      setState(() => _focusViewMode = _FocusViewMode.solo);
      return;
    }

    if (selection.createsRoom) {
      await _socialFocusController.createOpenRoom();
    } else {
      await _socialFocusController.joinRoom(selection.roomId!);
    }
    if (!mounted) {
      return;
    }

    setState(() => _focusViewMode = _FocusViewMode.group);
  }

  Future<bool> _confirmLeaveGroupFocus() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Leave group focus?'),
          content: const Text(
            'You can rejoin an open friend room from the group lobby later.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _openGroupRoomSheet() async {
    final room = _socialFocusController.activeRoom;
    if (room == null) {
      return;
    }

    final shouldLeave = await showGroupFocusRoomSheet(
      context: context,
      room: room,
    );
    if (!mounted || !shouldLeave) {
      return;
    }

    await _socialFocusController.leaveRoom();
    if (!mounted) {
      return;
    }

    setState(() => _focusViewMode = _FocusViewMode.solo);
  }

  List<SocialFocusParticipant> get _groupParticipants {
    final room = _socialFocusController.activeRoom;
    if (room == null) {
      return const [];
    }

    return [
      for (final member in room.members)
        SocialFocusParticipant(
          name: member.name,
          focusFrames: _framesForSocialActivity(member.activity),
          status: _statusForSocialMember(member),
        ),
    ];
  }

  SocialFocusMemberStatus _statusForSocialMember(SocialFocusMember member) {
    if (member.id != 'me') {
      return member.status;
    }

    return switch (_timerController.phase) {
      FocusSessionPhase.breakTime => SocialFocusMemberStatus.breakTime,
      FocusSessionPhase.focus || FocusSessionPhase.stopwatch
          when _timerController.running =>
        SocialFocusMemberStatus.focusing,
      _ => SocialFocusMemberStatus.idle,
    };
  }

  List<String> _framesForSocialActivity(SocialFocusActivity activity) {
    return switch (activity) {
      SocialFocusActivity.reading => AppAssets.socialFocusReading,
      SocialFocusActivity.writing => AppAssets.socialFocusWriting,
      SocialFocusActivity.coding => AppAssets.socialFocusCoding,
    };
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

      _completeActiveRoundAsAborted();
    }

    _timerController.updateSettings(updated);
    widget.settingsRepository.saveSettings(updated);
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
      _completeActiveRoundAsAborted();
    }
  }

  void _completeActiveRoundAsAborted() {
    final focusDuration = _timerController.elapsedFocusDuration;
    final waterReward =
        _pendingWaterReward +
        FocusRewardCalculator.waterForPartialFocus(focusDuration);
    final rewardDuration = _pendingRewardDuration + focusDuration;

    _timerController.cancelFocusRound();
    if (waterReward > 0) {
      widget.gardenController.addWater(waterReward);
    }

    _clearPendingRoundReward();
    _showCompletionReward(
      focusDuration: rewardDuration,
      waterReward: waterReward,
    );
  }

  Future<void> _handleSkip() async {
    final shouldWarn =
        _timerController.phase == FocusSessionPhase.focus &&
        _timerController.elapsedFocusDuration <
            FocusRewardCalculator.waterInterval;

    if (shouldWarn) {
      final shouldSkip = await _confirmShortFocusExit(
        title: 'Fokus überspringen?',
        content:
            'Unter 5 Minuten bekommst du kein Wasser und dieser Fokus wird nicht in den Stats gespeichert.',
        confirmLabel: 'Trotzdem überspringen',
      );
      if (!shouldSkip) {
        return;
      }

      _timerController.skip();
      return;
    }

    _timerController.skip();
  }

  Future<void> _handleFinishStopwatch() async {
    final focusDuration = _timerController.elapsedFocusDuration;
    final underRewardMinimum =
        focusDuration < FocusRewardCalculator.waterInterval;

    if (underRewardMinimum) {
      final shouldFinish = await _confirmShortFocusExit(
        title: 'Stopwatch beenden?',
        content:
            'Unter 5 Minuten bekommst du kein Wasser und diese Session wird nicht in den Stats gespeichert.',
        confirmLabel: 'Trotzdem beenden',
      );
      if (!shouldFinish) {
        return;
      }

      _timerController.resetToIdle();
      _showCompletionReward(focusDuration: focusDuration, waterReward: 0);
      return;
    }

    _timerController.finishStopwatch();
  }

  Future<bool> _confirmShortFocusExit({
    required String title,
    required String content,
    required String confirmLabel,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Weiter fokussieren'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _syncAnimation() {
    if (_timerController.active) {
      _characterAnimator.start();
      return;
    }

    _characterAnimator.reset();
  }

  void _handleFocusSessionCompleted(FocusSessionRecord record) {
    final waterReward = FocusRewardCalculator.waterForCompletedFocus(
      record.focusDuration,
    );

    if (waterReward > 0) {
      widget.historyController.addRecord(record);
    }

    if (record.mode == FocusMode.stopwatch) {
      if (waterReward > 0) {
        widget.gardenController.addWater(waterReward);
      }
      _showCompletionReward(
        focusDuration: record.focusDuration,
        waterReward: waterReward,
      );
      return;
    }

    _pendingRewardDuration += record.focusDuration;
    _pendingWaterReward += waterReward;
  }

  void _handleFocusRoundCompleted() {
    final waterReward = _pendingWaterReward;
    final focusDuration = _pendingRewardDuration;

    if (waterReward > 0) {
      widget.gardenController.addWater(waterReward);
    }

    _clearPendingRoundReward();
    _showCompletionReward(
      focusDuration: focusDuration,
      waterReward: waterReward,
    );
  }

  void _clearPendingRoundReward() {
    _pendingRewardDuration = Duration.zero;
    _pendingWaterReward = 0;
  }

  void _showCompletionReward({
    required Duration focusDuration,
    required int waterReward,
  }) {
    if (!mounted) {
      return;
    }

    setState(() {
      _completionReward = _FocusCompletionReward(
        focusDuration: focusDuration,
        waterReward: waterReward,
      );
    });
  }

  void _dismissCompletionReward() {
    setState(() {
      _completionReward = null;
    });
  }

  void _openSpaceFromCompletion() {
    _dismissCompletionReward();
    widget.onOpenSpace();
  }

  void _precacheAnimationAssets() {
    if (_assetsPrecached) {
      return;
    }

    _assetsPrecached = true;
    for (final assetPath in FocusAnimationCatalog.allFrames) {
      precacheImage(AssetImage(assetPath), context);
    }
    for (final assetPath in _socialFocusAssets) {
      precacheImage(AssetImage(assetPath), context);
    }
  }

  List<String> get _socialFocusAssets {
    return [
      AppAssets.socialFocusDesk,
      ...AppAssets.socialFocusReading,
      ...AppAssets.socialFocusWriting,
      ...AppAssets.socialFocusCoding,
      ...AppAssets.socialFocusSleeping,
    ];
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

enum _FocusViewMode { solo, group }

class _GroupRoomPill extends StatelessWidget {
  const _GroupRoomPill({required this.room, required this.onPressed});

  final SocialFocusRoom room;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F1EE),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${room.hostName}\'s room · ${room.seatsLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF303030),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            const Icon(
              CupertinoIcons.chevron_down,
              color: Color(0xFF303030),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusViewModeToggle extends StatelessWidget {
  const _FocusViewModeToggle({
    required this.selectedMode,
    required this.onChanged,
  });

  final _FocusViewMode selectedMode;
  final FutureOr<void> Function(_FocusViewMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FocusViewModeButton(
            icon: CupertinoIcons.person,
            selected: selectedMode == _FocusViewMode.solo,
            semanticLabel: 'Solo focus',
            onPressed: () {
              onChanged(_FocusViewMode.solo);
            },
          ),
          _FocusViewModeButton(
            icon: CupertinoIcons.person_2,
            selected: selectedMode == _FocusViewMode.group,
            semanticLabel: 'Group focus',
            onPressed: () {
              onChanged(_FocusViewMode.group);
            },
          ),
        ],
      ),
    );
  }
}

class _FocusViewModeButton extends StatelessWidget {
  const _FocusViewModeButton({
    required this.icon,
    required this.selected,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 54,
          height: 32,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF303030) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: selected ? Colors.white : const Color(0xFF303030),
          ),
        ),
      ),
    );
  }
}

class _FocusCompletionReward {
  const _FocusCompletionReward({
    required this.focusDuration,
    required this.waterReward,
  });

  final Duration focusDuration;
  final int waterReward;
}

class _FocusControls extends StatelessWidget {
  const _FocusControls({
    required this.active,
    required this.running,
    required this.stopwatch,
    required this.canSkip,
    required this.onSkip,
    required this.onPlayPause,
    required this.onRestart,
    required this.onFinish,
    required this.onCancel,
  });

  final bool active;
  final bool running;
  final bool stopwatch;
  final bool canSkip;
  final VoidCallback onSkip;
  final VoidCallback onPlayPause;
  final VoidCallback onRestart;
  final VoidCallback onFinish;
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
          if (!stopwatch) ...[
            AppIconButton(
              icon: CupertinoIcons.forward_end,
              semanticLabel: 'Skip',
              onPressed: active && canSkip ? onSkip : null,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
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
          if (stopwatch) ...[
            AppIconButton(
              icon: CupertinoIcons.checkmark,
              semanticLabel: 'Finish',
              onPressed: onFinish,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
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
