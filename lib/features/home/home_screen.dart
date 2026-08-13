import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/analytics/app_analytics.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/app_icon_button.dart';
import 'package:pats_space/features/focus/controllers/focus_character_animator.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/focus_reward_calculator.dart';
import 'package:pats_space/features/focus/focus_animation_catalog.dart';
import 'package:pats_space/features/focus/models/focus_animation_spec.dart';
import 'package:pats_space/features/focus/models/active_timer_state.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_session_phase.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/focus/repositories/focus_settings_repository.dart';
import 'package:pats_space/features/focus/repositories/active_timer_state_repository.dart';
import 'package:pats_space/features/focus/repositories/pending_focus_reward_repository.dart';
import 'package:pats_space/features/focus_blocking/controllers/focus_blocking_controller.dart';
import 'package:pats_space/features/notifications/controllers/notification_controller.dart';
import 'package:pats_space/features/notifications/models/timer_notification_kind.dart';
import 'package:pats_space/features/notifications/models/timer_notification_request.dart';
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
import 'package:pats_space/features/social_focus/repositories/firebase_social_focus_repository.dart';
import 'package:pats_space/features/sounds/controllers/sound_controller.dart';
import 'package:pats_space/features/sounds/widgets/ambient_sound_sheet.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.historyController,
    required this.gardenController,
    required this.initialSettings,
    required this.settingsRepository,
    required this.activeTimerStateRepository,
    this.initialActiveTimerState,
    required this.pendingRewardRepository,
    required this.gardenOnline,
    required this.onEnsureOnlineAction,
    required this.onOpenSpace,
    required this.focusBlockingController,
    required this.soundController,
    required this.notificationController,
    this.tutorialFocusDuration,
    this.tutorialFocusWaterReward = 0,
    this.onTutorialFocusCompleted,
  });

  final FocusHistoryController historyController;
  final GardenController gardenController;
  final FocusTimerSettings initialSettings;
  final FocusSettingsRepository settingsRepository;
  final ActiveTimerStateRepository activeTimerStateRepository;
  final ActiveTimerState? initialActiveTimerState;
  final PendingFocusRewardRepository pendingRewardRepository;
  final bool gardenOnline;
  final Future<bool> Function() onEnsureOnlineAction;
  final VoidCallback onOpenSpace;
  final FocusBlockingController focusBlockingController;
  final SoundController soundController;
  final NotificationController notificationController;
  final Duration? tutorialFocusDuration;
  final int tutorialFocusWaterReward;
  final VoidCallback? onTutorialFocusCompleted;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final FocusTimerController _timerController;
  late final FocusCharacterAnimator _characterAnimator;
  late final SocialFocusController _socialFocusController;
  bool _assetsPrecached = false;
  _FocusCompletionReward? _completionReward;
  Duration _pendingRewardDuration = Duration.zero;
  int _pendingWaterReward = 0;
  _FocusViewMode _focusViewMode = _FocusViewMode.solo;
  SocialFocusMemberStatus? _lastSyncedSocialFocusStatus;
  FocusSessionPhase _lastTimerPhase = FocusSessionPhase.idle;
  bool _appInForeground = true;
  String? _lastPersistedTimerSignature;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _socialFocusController = SocialFocusController(
      repository: FirebaseSocialFocusRepository(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
    );
    _timerController = FocusTimerController(
      initialSettings: widget.initialSettings,
      focusDurationOverride: widget.tutorialFocusDuration,
      startBreakAfterFocus: widget.tutorialFocusDuration == null,
      onFocusSessionCompleted: _handleFocusSessionCompleted,
      onFocusRoundCompleted: _handleFocusRoundCompleted,
      onFocusPeriodCompleted: _playFocusOrBreakEndSound,
      onBreakPeriodCompleted: _playFocusOrBreakEndSound,
      onFocusRoundFinished: _playRoundEndSound,
    );
    final initialTimerState = widget.initialActiveTimerState;
    if (initialTimerState != null) {
      _timerController.restore(initialTimerState);
    }
    _timerController.addListener(_syncAnimation);
    _characterAnimator = FocusCharacterAnimator();
    if (widget.gardenOnline) {
      _restoreSocialFocusRoom();
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gardenOnline && !widget.gardenOnline) {
      _lastSyncedSocialFocusStatus = null;
      _socialFocusController.clearActiveRoomLocally();
      if (_focusViewMode == _FocusViewMode.group) {
        setState(() => _focusViewMode = _FocusViewMode.solo);
      }
      return;
    }

    if (!oldWidget.gardenOnline && widget.gardenOnline) {
      _restoreSocialFocusRoom();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAnimationAssets();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.notificationController.cancelTimerNotification());
    unawaited(widget.soundController.syncFocusPlayback(shouldPlay: false));
    _timerController.removeListener(_syncAnimation);
    _timerController.dispose();
    _characterAnimator.dispose();
    _socialFocusController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (foreground) {
      unawaited(widget.notificationController.setAppForeground(true));
      _timerController.resumeFromBackground();
      _persistActiveTimerState(force: true);
      _appInForeground = true;
      return;
    }

    _appInForeground = false;
    _persistActiveTimerState(force: true);
    _timerController.suspendForBackground();
    if (!foreground) {
      unawaited(widget.soundController.stopAlert());
    }
    unawaited(
      widget.notificationController.setAppForeground(foreground).then((_) {
        if (!foreground && mounted) {
          _syncTimerNotification();
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _timerController,
        _characterAnimator,
        _socialFocusController,
        widget.focusBlockingController,
        widget.soundController,
      ]),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
            final bottomNavigationInset =
                MediaQuery.paddingOf(context).bottom + AppSpacing.xs * 2 + 44;
            final availableHeight =
                constraints.maxHeight - bottomNavigationInset;
            final compact = availableHeight < 720;
            final tight = availableHeight < 650;
            final groupMode =
                _focusViewMode == _FocusViewMode.group &&
                _socialFocusController.hasActiveRoom;
            final groupParticipantCount =
                _socialFocusController.activeRoom?.members.length ?? 0;
            final singleGroup = groupMode && groupParticipantCount == 1;
            final compactGroup = groupMode && groupParticipantCount < 4;
            final mediumGroup = groupMode && groupParticipantCount == 3;
            final topSpace = keyboardVisible
                ? AppSpacing.lg
                : (availableHeight *
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
            final characterGap = keyboardVisible
                ? AppSpacing.sm
                : tight
                ? AppSpacing.xl
                : compact
                ? AppSpacing.xxl * 1.25
                : AppSpacing.xxl * 1.75;
            final groupCharacterGap = keyboardVisible
                ? AppSpacing.sm
                : compactGroup
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
                            compact: compact,
                          ),
                        )
                      else if (groupMode)
                        SocialFocusGroupView(
                          participants: _groupParticipants,
                          active: _timerController.active,
                          running: _timerController.running,
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
                            widget.tutorialFocusDuration == null &&
                            _timerController.phase !=
                                FocusSessionPhase.stopwatch,
                        onSkip: () {
                          _handleSkip();
                        },
                        onPlayPause: _handlePlayPause,
                        onRestart: _timerController.restartCurrentSession,
                        onFinish: () {
                          _handleFinishStopwatch();
                        },
                        onCancel: _confirmCancelFocusRound,
                        tutorial: widget.tutorialFocusDuration != null,
                        highlightStart:
                            widget.tutorialFocusDuration != null &&
                            !_timerController.active,
                      ),
                      if (!groupMode || (compactGroup && !mediumGroup))
                        const Spacer(),
                    ],
                  ),
                ),
                if (widget.tutorialFocusDuration == null)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
                    left: 0,
                    child: _FocusViewModeToggle(
                      selectedMode: _focusViewMode,
                      socialOnline: widget.gardenOnline,
                      onChanged: _handleFocusViewModeChanged,
                    ),
                  ),
                if (widget.tutorialFocusDuration == null)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
                    right: 0,
                    child: Transform.translate(
                      offset: const Offset(0, -4),
                      child: AppIconButton(
                        icon: !widget.soundController.ambientSoundsEnabled
                            ? PhosphorIconsRegular.speakerSlash
                            : PhosphorIconsRegular.speakerHigh,
                        selected: widget.soundController.ambientSoundsEnabled,
                        showSelectedBackground: false,
                        buttonSize: 44,
                        iconSize: 24,
                        semanticLabel: AppLocalizations.of(
                          context,
                        ).ambientSounds,
                        onPressed: _handleAmbientSoundTap,
                        onLongPress: () {
                          _openAmbientSounds(showHintAfterSelection: false);
                        },
                      ),
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
                      onContinue: _handleCompletionContinue,
                      onOpenSpace: _handleCompletionOpenSpace,
                      tutorial: widget.onTutorialFocusCompleted != null,
                      dismissible: widget.onTutorialFocusCompleted == null,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  VoidCallback? get _settingsAction =>
      widget.tutorialFocusDuration == null ? _openSettings : null;

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

      unawaited(AppAnalytics.instance.logSocialFocusLeft());
      _lastSyncedSocialFocusStatus = null;
      setState(() => _focusViewMode = _FocusViewMode.solo);
      return;
    }

    if (_socialFocusController.hasActiveRoom) {
      setState(() => _focusViewMode = _FocusViewMode.group);
      return;
    }

    setState(() => _focusViewMode = _FocusViewMode.group);

    if (!await widget.onEnsureOnlineAction()) {
      if (!mounted) {
        return;
      }

      setState(() => _focusViewMode = _FocusViewMode.solo);
      return;
    }

    final snapshot = await _socialFocusController.loadLobby();
    if (!mounted) {
      return;
    }

    final selection = await showGroupFocusLobbySheet(
      context: context,
      snapshot: snapshot,
      snapshots: _socialFocusController.watchLobby(),
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

    if (!_socialFocusController.hasActiveRoom) {
      AppHaptics.error();
      setState(() => _focusViewMode = _FocusViewMode.solo);
      return;
    }

    unawaited(
      AppAnalytics.instance.logSocialFocusJoined(
        createdRoom: selection.createsRoom,
      ),
    );
    _syncSocialFocusStatus();
    setState(() => _focusViewMode = _FocusViewMode.group);
  }

  Future<void> _restoreSocialFocusRoom() async {
    final restored = await _socialFocusController.restoreActiveRoom();
    if (!mounted || !restored) {
      return;
    }

    _syncSocialFocusStatus();
    setState(() => _focusViewMode = _FocusViewMode.group);
  }

  Future<bool> _confirmLeaveGroupFocus() async {
    final l10n = AppLocalizations.of(context);
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.leaveGroupFocusTitle),
          content: Text(l10n.leaveGroupFocusMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.stay),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.leave),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _openGroupRoomSheet() async {
    if (!widget.gardenOnline) {
      _lastSyncedSocialFocusStatus = null;
      _socialFocusController.clearActiveRoomLocally();
      setState(() => _focusViewMode = _FocusViewMode.solo);
      return;
    }

    final room = _socialFocusController.activeRoom;
    if (room == null) {
      return;
    }

    final shouldLeave = await showGroupFocusRoomSheet(
      context: context,
      room: _roomWithLiveLocalStatus(room),
      localMemberId: _localSocialFocusMemberId,
      onLocalActivityChanged: _socialFocusController.updateLocalActivity,
    );
    if (!mounted || !shouldLeave) {
      return;
    }

    await _socialFocusController.leaveRoom();
    if (!mounted) {
      return;
    }

    unawaited(AppAnalytics.instance.logSocialFocusLeft());
    _lastSyncedSocialFocusStatus = null;
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
          usesLocalTimer: member.id == _localSocialFocusMemberId,
        ),
    ];
  }

  SocialFocusMemberStatus _statusForSocialMember(SocialFocusMember member) {
    if (member.id != _localSocialFocusMemberId) {
      return member.status;
    }

    return _localSocialFocusStatus;
  }

  String? get _localSocialFocusMemberId =>
      FirebaseAuth.instance.currentUser?.uid;

  SocialFocusRoom _roomWithLiveLocalStatus(SocialFocusRoom room) {
    return SocialFocusRoom(
      id: room.id,
      hostName: room.hostName,
      statusLabel: room.statusLabel,
      capacity: room.capacity,
      members: [
        for (final member in room.members)
          SocialFocusMember(
            id: member.id,
            name: member.name,
            activity: member.activity,
            status: _statusForSocialMember(member),
          ),
      ],
    );
  }

  List<String> _framesForSocialActivity(SocialFocusActivity activity) {
    return switch (activity) {
      SocialFocusActivity.reading => AppAssets.socialFocusReading,
      SocialFocusActivity.studying => AppAssets.socialFocusWriting,
      SocialFocusActivity.working => AppAssets.socialFocusCoding,
    };
  }

  Future<void> _openSettings() async {
    final updated = await showTimeSettingsSheet(
      context: context,
      settings: _timerController.settings,
      focusBlockingController: widget.focusBlockingController,
      showAnimationSettings: _focusViewMode == _FocusViewMode.solo,
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
    final l10n = AppLocalizations.of(context);
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.focusRunningTitle),
          content: Text(l10n.focusRunningSettingsMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.back),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.cancelAndSave),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _confirmCancelFocusRound() async {
    final l10n = AppLocalizations.of(context);
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.cancelFocusTitle),
          content: Text(l10n.cancelFocusMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.back),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.cancelFocus),
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

    unawaited(
      AppAnalytics.instance.logFocusCancelled(
        mode: _timerController.settings.mode.name,
        durationSeconds: rewardDuration.inSeconds,
        groupFocus: _socialFocusController.hasActiveRoom,
      ),
    );
    _timerController.cancelFocusRound();
    if (waterReward > 0) {
      _applyOrStoreWaterReward(waterReward, storeOffline: true);
    }

    _clearPendingRoundReward();
    _showCompletionReward(
      focusDuration: rewardDuration,
      waterReward: waterReward,
    );
  }

  Future<void> _handleSkip() async {
    final l10n = AppLocalizations.of(context);
    final shouldWarn =
        _timerController.phase == FocusSessionPhase.focus &&
        _timerController.elapsedFocusDuration <
            FocusRewardCalculator.waterInterval;

    if (shouldWarn) {
      final shouldSkip = await _confirmShortFocusExit(
        title: l10n.skipFocusTitle,
        content: l10n.skipShortFocusMessage,
        confirmLabel: l10n.skipAnyway,
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
    final l10n = AppLocalizations.of(context);
    final focusDuration = _timerController.elapsedFocusDuration;
    final underRewardMinimum =
        focusDuration < FocusRewardCalculator.waterInterval;

    if (underRewardMinimum) {
      final shouldFinish = await _confirmShortFocusExit(
        title: l10n.finishStopwatchTitle,
        content: l10n.finishShortStopwatchMessage,
        confirmLabel: l10n.finishAnyway,
      );
      if (!shouldFinish) {
        return;
      }

      _timerController.resetToIdle();
      unawaited(
        AppAnalytics.instance.logFocusCancelled(
          mode: FocusMode.stopwatch.name,
          durationSeconds: focusDuration.inSeconds,
          groupFocus: _socialFocusController.hasActiveRoom,
        ),
      );
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
    final l10n = AppLocalizations.of(context);
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.keepFocusing),
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
    final currentPhase = _timerController.phase;
    if (_lastTimerPhase != FocusSessionPhase.idle &&
        currentPhase == FocusSessionPhase.idle &&
        widget.focusBlockingController.status.isActive) {
      unawaited(widget.focusBlockingController.endSession());
    }
    _lastTimerPhase = currentPhase;

    unawaited(
      widget.soundController.syncFocusPlayback(
        shouldPlay:
            _timerController.running &&
            (currentPhase == FocusSessionPhase.focus ||
                currentPhase == FocusSessionPhase.stopwatch),
      ),
    );
    _syncTimerNotification();
    _persistActiveTimerState();

    if (_timerController.running) {
      _characterAnimator.start();
    } else if (_timerController.active) {
      _characterAnimator.pause();
    } else {
      _characterAnimator.reset();
    }

    _syncSocialFocusStatus();
  }

  void _persistActiveTimerState({bool force = false}) {
    final state = _timerController.persistentState;
    if (state == null) {
      _lastPersistedTimerSignature = null;
      unawaited(widget.activeTimerStateRepository.clear());
      return;
    }
    final signature = [
      state.phase.name,
      state.paused,
      state.completedSessions,
    ].join(':');
    if (!force && signature == _lastPersistedTimerSignature) return;
    _lastPersistedTimerSignature = signature;
    unawaited(widget.activeTimerStateRepository.save(state));
  }

  void _syncTimerNotification() {
    final l10n = AppLocalizations.of(context);
    unawaited(
      widget.notificationController.syncTimerNotifications(
        _backgroundNotificationTimeline(l10n),
      ),
    );
  }

  List<TimerNotificationRequest> _backgroundNotificationTimeline(
    AppLocalizations l10n,
  ) {
    if (!_timerController.running ||
        _timerController.phase == FocusSessionPhase.stopwatch) {
      return const [];
    }

    final settings = _timerController.settings;
    var phase = _timerController.phase;
    var session = _timerController.completedSessions + 1;
    var scheduledAt = DateTime.now().add(
      Duration(seconds: _timerController.remainingSeconds),
    );
    final requests = <TimerNotificationRequest>[];

    while (true) {
      final kind = switch (phase) {
        FocusSessionPhase.focus => TimerNotificationKind.focusEnd,
        FocusSessionPhase.breakTime =>
          session >= settings.sessionsPerRound
              ? TimerNotificationKind.roundEnd
              : TimerNotificationKind.breakEnd,
        FocusSessionPhase.idle || FocusSessionPhase.stopwatch => null,
      };
      if (kind == null) break;
      final (title, body) = switch (kind) {
        TimerNotificationKind.focusEnd => (
          l10n.focusFinishedNotificationTitle,
          l10n.focusFinishedNotificationBody,
        ),
        TimerNotificationKind.breakEnd => (
          l10n.breakFinishedNotificationTitle,
          l10n.breakFinishedNotificationBody,
        ),
        TimerNotificationKind.roundEnd => (
          l10n.roundFinishedNotificationTitle,
          l10n.roundFinishedNotificationBody,
        ),
      };
      requests.add(
        TimerNotificationRequest(
          kind: kind,
          scheduledAt: scheduledAt,
          title: title,
          body: body,
        ),
      );
      if (!settings.autoContinue || kind == TimerNotificationKind.roundEnd) {
        break;
      }
      if (phase == FocusSessionPhase.focus) {
        phase = FocusSessionPhase.breakTime;
        scheduledAt = scheduledAt.add(
          settings.breakDuration(
            isLongBreak: session % settings.longBreakInterval == 0,
          ),
        );
      } else {
        session += 1;
        phase = FocusSessionPhase.focus;
        scheduledAt = scheduledAt.add(settings.focusDuration);
      }
    }
    return requests;
  }

  Future<void> _handlePlayPause() async {
    if (_timerController.active) {
      _timerController.toggle();
      return;
    }

    if (!_timerController.settings.deepFocusEnabled) {
      _timerController.toggle();
      _logFocusStarted();
      return;
    }

    final activated = await widget.focusBlockingController.startSession(
      expectedEnd: _expectedFocusRoundEnd,
    );
    if (!mounted) {
      return;
    }

    if (activated) {
      _timerController.toggle();
      _logFocusStarted();
      return;
    }

    final startWithoutBlocking = await _confirmStartWithoutDeepFocus();
    if (startWithoutBlocking && mounted) {
      _timerController.toggle();
      _logFocusStarted();
    }
  }

  void _logFocusStarted() {
    unawaited(
      AppAnalytics.instance.logFocusStarted(
        mode: _timerController.settings.mode.name,
        plannedSeconds: _timerController.remainingSeconds,
        groupFocus: _socialFocusController.hasActiveRoom,
      ),
    );
  }

  DateTime? get _expectedFocusRoundEnd {
    final settings = _timerController.settings;
    if (settings.mode == FocusMode.stopwatch) {
      return null;
    }

    var totalSeconds =
        settings.focusDuration.inSeconds * settings.sessionsPerRound;
    for (var session = 1; session <= settings.sessionsPerRound; session += 1) {
      totalSeconds += settings
          .breakDuration(isLongBreak: session % settings.longBreakInterval == 0)
          .inSeconds;
    }
    return DateTime.now().add(Duration(seconds: totalSeconds));
  }

  Future<bool> _confirmStartWithoutDeepFocus() async {
    final l10n = AppLocalizations.of(context);
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(l10n.deepFocusCouldNotStartTitle),
        content: Text(l10n.deepFocusCouldNotStartMessage),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.back),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.startWithoutDeepFocus),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _syncSocialFocusStatus() {
    if (!_socialFocusController.hasActiveRoom) {
      _lastSyncedSocialFocusStatus = null;
      return;
    }

    final status = _localSocialFocusStatus;
    if (_lastSyncedSocialFocusStatus == status) {
      return;
    }

    _lastSyncedSocialFocusStatus = status;
    _socialFocusController.updateLocalStatus(status);
  }

  SocialFocusMemberStatus get _localSocialFocusStatus {
    return switch (_timerController.phase) {
      FocusSessionPhase.breakTime => SocialFocusMemberStatus.breakTime,
      FocusSessionPhase.focus || FocusSessionPhase.stopwatch
          when _timerController.running =>
        SocialFocusMemberStatus.focusing,
      _ => SocialFocusMemberStatus.idle,
    };
  }

  void _handleFocusSessionCompleted(FocusSessionRecord record) {
    if (widget.onTutorialFocusCompleted != null) {
      _showCompletionReward(
        focusDuration: record.focusDuration,
        waterReward: widget.tutorialFocusWaterReward,
      );
      return;
    }

    unawaited(
      AppAnalytics.instance.logFocusCompleted(
        mode: record.mode.name,
        durationSeconds: record.focusDuration.inSeconds,
        groupFocus: _socialFocusController.hasActiveRoom,
      ),
    );

    final waterReward = FocusRewardCalculator.waterForCompletedFocus(
      record.focusDuration,
    );

    if (waterReward > 0) {
      widget.historyController.addRecord(
        record.copyWith(waterReward: waterReward),
      );
      if (!widget.gardenOnline) {
        unawaited(
          widget.pendingRewardRepository.addSessionReward(
            record.copyWith(waterReward: waterReward),
            appliedLocally: true,
          ),
        );
      }
    }

    if (record.mode == FocusMode.stopwatch) {
      _playRoundEndSound();
      if (waterReward > 0) {
        _applyOrStoreWaterReward(waterReward, storeOffline: false);
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

  Future<void> _handleAmbientSoundTap() async {
    if (!widget.soundController.hasAmbientSoundSelection) {
      await _openAmbientSounds();
      return;
    }

    await widget.soundController.setAmbientSoundsEnabled(
      !widget.soundController.ambientSoundsEnabled,
    );
  }

  Future<void> _openAmbientSounds({bool showHintAfterSelection = true}) async {
    final shouldShowHint =
        showHintAfterSelection &&
        !widget.soundController.ambientLongPressHintShown;
    await showAmbientSoundSheet(
      context: context,
      controller: widget.soundController,
    );
    if (!mounted ||
        !shouldShowHint ||
        !widget.soundController.hasAmbientSoundSelection) {
      return;
    }

    await widget.soundController.markAmbientLongPressHintShown();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).holdForSoundSelection),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _playFocusOrBreakEndSound() {
    if (!_appInForeground) {
      return;
    }
    unawaited(widget.soundController.playFocusOrBreakEnd());
  }

  void _playRoundEndSound() {
    if (!_appInForeground) {
      return;
    }
    unawaited(widget.soundController.playRoundEnd());
  }

  void _handleFocusRoundCompleted() {
    final waterReward = _pendingWaterReward;
    final focusDuration = _pendingRewardDuration;

    if (waterReward > 0) {
      _applyOrStoreWaterReward(waterReward, storeOffline: true);
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

  void _applyOrStoreWaterReward(int waterReward, {required bool storeOffline}) {
    if (waterReward <= 0) {
      return;
    }

    widget.gardenController.addWater(waterReward);

    if (!widget.gardenOnline && storeOffline) {
      unawaited(
        widget.pendingRewardRepository.addWaterReward(
          waterReward,
          appliedLocally: true,
        ),
      );
    }
  }

  void _dismissCompletionReward() {
    setState(() {
      _completionReward = null;
    });
  }

  void _handleCompletionContinue() {
    if (widget.onTutorialFocusCompleted != null) {
      widget.onTutorialFocusCompleted!();
      return;
    }

    _prepareNextRoundAfterCompletion();
  }

  void _handleCompletionOpenSpace() {
    if (widget.onTutorialFocusCompleted != null) {
      widget.onTutorialFocusCompleted!();
      return;
    }

    _prepareNextRoundAfterCompletion();
    widget.onOpenSpace();
  }

  void _prepareNextRoundAfterCompletion() {
    _timerController.acknowledgeRoundCompletion();
    _dismissCompletionReward();
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
    required this.socialOnline,
    required this.onChanged,
  });

  final _FocusViewMode selectedMode;
  final bool socialOnline;
  final FutureOr<void> Function(_FocusViewMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
                semanticLabel: socialOnline
                    ? 'Group focus'
                    : 'Group focus unavailable offline',
                onPressed: () {
                  onChanged(_FocusViewMode.group);
                },
              ),
            ],
          ),
        ),
        if (!socialOnline) ...[
          const SizedBox(width: AppSpacing.xs),
          const _FocusSocialOfflineIcon(),
        ],
      ],
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
        onTap: () {
          if (!selected) {
            AppHaptics.selection();
          }
          onPressed();
        },
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

class _FocusSocialOfflineIcon extends StatelessWidget {
  const _FocusSocialOfflineIcon();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.graySoft.withValues(alpha: .46)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: .06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(9),
        child: Icon(
          PhosphorIconsRegular.cloudSlash,
          size: 19,
          color: AppColors.grayWarm,
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
    this.tutorial = false,
    this.highlightStart = false,
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
  final bool tutorial;
  final bool highlightStart;

  @override
  Widget build(BuildContext context) {
    if (running) {
      return AppIconButton(
        icon: CupertinoIcons.pause,
        semanticLabel: 'Pause',
        haptic: AppIconButtonHaptic.light,
        onPressed: onPlayPause,
      );
    }

    if (!active) {
      final button = AppIconButton(
        icon: CupertinoIcons.play,
        semanticLabel: 'Start',
        haptic: AppIconButtonHaptic.light,
        onPressed: onPlayPause,
      );
      return highlightStart ? _TutorialStartPulse(child: button) : button;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!stopwatch && !tutorial) ...[
            AppIconButton(
              icon: CupertinoIcons.forward_end,
              semanticLabel: 'Skip',
              haptic: AppIconButtonHaptic.medium,
              onPressed: active && canSkip ? onSkip : null,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          AppIconButton(
            icon: CupertinoIcons.play,
            semanticLabel: 'Resume',
            haptic: AppIconButtonHaptic.light,
            onPressed: onPlayPause,
          ),
          const SizedBox(width: AppSpacing.sm),
          AppIconButton(
            icon: CupertinoIcons.restart,
            semanticLabel: 'Restart',
            haptic: AppIconButtonHaptic.medium,
            onPressed: onRestart,
          ),
          const SizedBox(width: AppSpacing.sm),
          if (stopwatch) ...[
            AppIconButton(
              icon: CupertinoIcons.checkmark,
              semanticLabel: 'Finish',
              haptic: AppIconButtonHaptic.medium,
              onPressed: onFinish,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (!tutorial)
            AppIconButton(
              icon: CupertinoIcons.xmark,
              semanticLabel: 'Cancel',
              haptic: AppIconButtonHaptic.medium,
              onPressed: onCancel,
            ),
        ],
      ),
    );
  }
}

class _TutorialStartPulse extends StatefulWidget {
  const _TutorialStartPulse({required this.child});

  final Widget child;

  @override
  State<_TutorialStartPulse> createState() => _TutorialStartPulseState();
}

class _TutorialStartPulseState extends State<_TutorialStartPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final wave = Curves.easeOutCubic.transform(_controller.value);
                  final opacity = (1 - wave).clamp(0.0, 1.0);

                  return Center(
                    child: Transform.scale(
                      alignment: Alignment.center,
                      scale: 1 + wave * .42,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.charcoal.withValues(
                              alpha: .28 * opacity,
                            ),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}
