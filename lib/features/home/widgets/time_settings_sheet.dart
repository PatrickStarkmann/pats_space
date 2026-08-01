import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_animation_pair.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';
import 'package:pats_space/features/focus/models/focus_mode.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/focus_blocking/controllers/focus_blocking_controller.dart';
import 'package:pats_space/features/focus_blocking/widgets/focus_blocking_settings_card.dart';
import 'package:pats_space/features/home/widgets/time_settings/animation_pair_settings_card.dart';
import 'package:pats_space/features/home/widgets/time_settings/break_settings_card.dart';
import 'package:pats_space/features/home/widgets/time_settings/focus_label_settings_card.dart';
import 'package:pats_space/features/home/widgets/time_settings/focus_mode_settings_card.dart';
import 'package:pats_space/features/home/widgets/time_settings/pomodoro_settings_card.dart';
import 'package:pats_space/features/home/widgets/time_settings/stopwatch_settings_card.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_list_picker_page.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_header.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_value_picker_page.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

Future<FocusTimerSettings?> showTimeSettingsSheet({
  required BuildContext context,
  required FocusTimerSettings settings,
  required FocusBlockingController focusBlockingController,
  bool showAnimationSettings = true,
}) {
  return showModalBottomSheet<FocusTimerSettings>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => TimeSettingsSheet(
      initialSettings: settings,
      focusBlockingController: focusBlockingController,
      showAnimationSettings: showAnimationSettings,
    ),
  );
}

class TimeSettingsSheet extends StatefulWidget {
  const TimeSettingsSheet({
    super.key,
    required this.initialSettings,
    required this.showAnimationSettings,
    required this.focusBlockingController,
  });

  final FocusTimerSettings initialSettings;
  final bool showAnimationSettings;
  final FocusBlockingController focusBlockingController;

  @override
  State<TimeSettingsSheet> createState() => _TimeSettingsSheetState();
}

class _TimeSettingsSheetState extends State<TimeSettingsSheet> {
  late FocusTimerSettings _settings = widget.initialSettings;
  _TimeSettingsDetail? _detail;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final compact = mediaQuery.size.height < 760;
    final contentGap = compact ? AppSpacing.md : AppSpacing.lg;

    return SafeArea(
      top: false,
      bottom: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            mediaQuery.viewInsets.bottom +
                mediaQuery.padding.bottom +
                AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F4FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: _detail == null
                ? _OverviewPage(
                    key: const ValueKey('overview'),
                    compact: compact,
                    contentGap: contentGap,
                    settings: _settings,
                    focusBlockingController: widget.focusBlockingController,
                    showAnimationSettings: widget.showAnimationSettings,
                    onDone: () => Navigator.of(context).pop(_settings),
                    onCancel: () => Navigator.of(context).pop(),
                    onModeChanged: (mode) {
                      setState(() {
                        _settings = _settings.copyWith(mode: mode);
                      });
                    },
                    onDeepFocusChanged: _handleDeepFocusChanged,
                    onFocusMinutesChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(focusMinutes: value);
                      });
                    },
                    onLabelChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(focusLabel: value);
                      });
                    },
                    onAccentColorChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(accentColor: value);
                      });
                    },
                    onBadgeIconChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(badgeIcon: value);
                      });
                    },
                    onAnimationPairChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(animationPair: value);
                      });
                    },
                    onDetailSelected: (detail) {
                      setState(() => _detail = detail);
                    },
                  )
                : _DetailPage(
                    key: ValueKey(_detail),
                    compact: compact,
                    detail: _detail!,
                    settings: _settings,
                    onBack: () => setState(() => _detail = null),
                    onChanged: _updateDetailValue,
                  ),
          ),
        ),
      ),
    );
  }

  void _updateDetailValue(int value) {
    setState(() {
      _settings = switch (_detail) {
        _TimeSettingsDetail.sessions => _settings.copyWith(
          sessionsPerRound: value,
        ),
        _TimeSettingsDetail.longBreakInterval => _settings.copyWith(
          longBreakInterval: value,
        ),
        _TimeSettingsDetail.shortBreak => _settings.copyWith(
          shortBreakMinutes: value,
        ),
        _TimeSettingsDetail.longBreak => _settings.copyWith(
          longBreakMinutes: value,
        ),
        null => _settings,
      };
    });
  }

  Future<void> _handleDeepFocusChanged(bool enabled) async {
    if (!enabled) {
      if (!mounted) {
        return;
      }
      setState(() {
        _settings = _settings.copyWith(deepFocusEnabled: false);
      });
      return;
    }

    final ready = await widget.focusBlockingController.prepare();
    if (!mounted || !ready) {
      return;
    }

    setState(() {
      _settings = _settings.copyWith(deepFocusEnabled: true);
    });
  }
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage({
    super.key,
    required this.compact,
    required this.contentGap,
    required this.settings,
    required this.focusBlockingController,
    required this.showAnimationSettings,
    required this.onDone,
    required this.onCancel,
    required this.onModeChanged,
    required this.onDeepFocusChanged,
    required this.onFocusMinutesChanged,
    required this.onLabelChanged,
    required this.onAccentColorChanged,
    required this.onBadgeIconChanged,
    required this.onAnimationPairChanged,
    required this.onDetailSelected,
  });

  final bool compact;
  final double contentGap;
  final FocusTimerSettings settings;
  final FocusBlockingController focusBlockingController;
  final bool showAnimationSettings;
  final VoidCallback onDone;
  final VoidCallback onCancel;
  final ValueChanged<FocusMode> onModeChanged;
  final Future<void> Function(bool enabled) onDeepFocusChanged;
  final ValueChanged<int> onFocusMinutesChanged;
  final ValueChanged<String> onLabelChanged;
  final ValueChanged<FocusAccentColor> onAccentColorChanged;
  final ValueChanged<FocusBadgeIcon> onBadgeIconChanged;
  final ValueChanged<FocusAnimationPair> onAnimationPairChanged;
  final ValueChanged<_TimeSettingsDetail> onDetailSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TimeSettingsGrabber(),
        TimeSettingsHeader(
          compact: compact,
          onCancel: onCancel,
          onDone: onDone,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: contentGap),
                FocusModeSettingsCard(
                  mode: settings.mode,
                  onModeChanged: onModeChanged,
                ),
                SizedBox(height: contentGap),
                FocusLabelSettingsCard(
                  settings: settings,
                  onLabelChanged: onLabelChanged,
                  onAccentColorChanged: onAccentColorChanged,
                  onBadgeIconChanged: onBadgeIconChanged,
                ),
                SizedBox(height: contentGap),
                if (settings.mode == FocusMode.pomodoro) ...[
                  PomodoroSettingsCard(
                    compact: compact,
                    focusMinutes: settings.focusMinutes,
                    onChanged: onFocusMinutesChanged,
                  ),
                  SizedBox(height: contentGap),
                  BreakSettingsCard(
                    settings: settings,
                    onSessionsPressed: () {
                      onDetailSelected(_TimeSettingsDetail.sessions);
                    },
                    onLongBreakIntervalPressed: () {
                      onDetailSelected(_TimeSettingsDetail.longBreakInterval);
                    },
                    onShortBreakPressed: () {
                      onDetailSelected(_TimeSettingsDetail.shortBreak);
                    },
                    onLongBreakPressed: () {
                      onDetailSelected(_TimeSettingsDetail.longBreak);
                    },
                  ),
                ] else ...[
                  const StopwatchSettingsCard(),
                ],
                SizedBox(height: contentGap),
                FocusBlockingSettingsCard(
                  controller: focusBlockingController,
                  enabled: settings.deepFocusEnabled,
                  onChanged: onDeepFocusChanged,
                ),
                if (showAnimationSettings) ...[
                  SizedBox(height: contentGap),
                  AnimationPairSettingsCard(
                    selectedPair: settings.animationPair,
                    onChanged: onAnimationPairChanged,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({
    super.key,
    required this.compact,
    required this.detail,
    required this.settings,
    required this.onBack,
    required this.onChanged,
  });

  final bool compact;
  final _TimeSettingsDetail detail;
  final FocusTimerSettings settings;
  final VoidCallback onBack;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (detail.usesListPicker) {
      return TimeSettingsListPickerPage(
        compact: compact,
        title: detail.title(l10n),
        values: detail.pickerValues,
        selectedValue: detail.selectedValue(settings),
        labelBuilder: detail.labelBuilder,
        onBack: onBack,
        onChanged: onChanged,
      );
    }

    return TimeSettingsValuePickerPage(
      compact: compact,
      title: detail.title(l10n),
      values: detail.pickerValues,
      selectedValue: detail.selectedValue(settings),
      labelBuilder: detail.labelBuilder,
      onBack: onBack,
      onChanged: onChanged,
    );
  }
}

enum _TimeSettingsDetail {
  sessions,
  longBreakInterval,
  shortBreak,
  longBreak;

  String title(AppLocalizations l10n) {
    return switch (this) {
      _TimeSettingsDetail.sessions => l10n.sessions,
      _TimeSettingsDetail.longBreakInterval => l10n.longBreakInterval,
      _TimeSettingsDetail.shortBreak => l10n.shortBreak,
      _TimeSettingsDetail.longBreak => l10n.longBreak,
    };
  }

  List<int> get pickerValues {
    return switch (this) {
      _TimeSettingsDetail.sessions => _range(1, 10),
      _TimeSettingsDetail.longBreakInterval => _range(2, 4),
      _TimeSettingsDetail.shortBreak => _range(1, 20),
      _TimeSettingsDetail.longBreak => _range(5, 30),
    };
  }

  bool get usesListPicker {
    return switch (this) {
      _TimeSettingsDetail.sessions ||
      _TimeSettingsDetail.longBreakInterval => true,
      _TimeSettingsDetail.shortBreak || _TimeSettingsDetail.longBreak => false,
    };
  }

  int selectedValue(FocusTimerSettings settings) {
    return switch (this) {
      _TimeSettingsDetail.sessions => settings.sessionsPerRound,
      _TimeSettingsDetail.longBreakInterval => settings.longBreakInterval,
      _TimeSettingsDetail.shortBreak => settings.shortBreakMinutes,
      _TimeSettingsDetail.longBreak => settings.longBreakMinutes,
    };
  }

  String labelBuilder(int value) {
    return switch (this) {
      _TimeSettingsDetail.sessions => '$value',
      _TimeSettingsDetail.longBreakInterval => '$value',
      _TimeSettingsDetail.shortBreak => '${value}m',
      _TimeSettingsDetail.longBreak => '${value}m',
    };
  }
}

List<int> _range(int min, int max) {
  return List.generate(max - min + 1, (index) => min + index);
}
