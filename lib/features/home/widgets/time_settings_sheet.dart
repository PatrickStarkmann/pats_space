import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/segmented_selector.dart';

class TimeSettings {
  const TimeSettings({
    required this.mode,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.longBreakInterval,
  });

  final FocusMode mode;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakInterval;

  TimeSettings copyWith({
    FocusMode? mode,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakInterval,
  }) {
    return TimeSettings(
      mode: mode ?? this.mode,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
    );
  }
}

enum FocusMode { pomodoro, stopwatch }

Future<TimeSettings?> showTimeSettingsSheet({
  required BuildContext context,
  required TimeSettings settings,
}) {
  return showModalBottomSheet<TimeSettings>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => TimeSettingsSheet(initialSettings: settings),
  );
}

class TimeSettingsSheet extends StatefulWidget {
  const TimeSettingsSheet({super.key, required this.initialSettings});

  final TimeSettings initialSettings;

  @override
  State<TimeSettingsSheet> createState() => _TimeSettingsSheetState();
}

class _TimeSettingsSheetState extends State<TimeSettingsSheet> {
  late TimeSettings _settings = widget.initialSettings;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final compact = mediaQuery.size.height < 760;
    final contentGap = compact ? AppSpacing.md : AppSpacing.lg;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            mediaQuery.viewInsets.bottom + AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F4FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Column(
            children: [
              const _SheetGrabber(),
              _SheetHeader(
                compact: compact,
                onCancel: () => Navigator.of(context).pop(),
                onDone: () => Navigator.of(context).pop(_settings),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: contentGap),
                      _ModeCard(
                        mode: _settings.mode,
                        onModeChanged: (mode) {
                          setState(() {
                            _settings = _settings.copyWith(mode: mode);
                          });
                        },
                      ),
                      SizedBox(height: contentGap),
                      if (_settings.mode == FocusMode.pomodoro) ...[
                        _PomodoroCard(
                          compact: compact,
                          focusMinutes: _settings.focusMinutes,
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(
                                focusMinutes: value,
                              );
                            });
                          },
                        ),
                        SizedBox(height: contentGap),
                        _BreakSettingsCard(
                          settings: _settings,
                          onChanged: (settings) {
                            setState(() => _settings = settings);
                          },
                        ),
                      ] else
                        const _StopwatchCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.graySoft,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: SizedBox(width: 44, height: 7),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.compact,
    required this.onCancel,
    required this.onDone,
  });

  final bool compact;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 58 : 72,
      child: Row(
        children: [
          IconButton(
            onPressed: onCancel,
            icon: const Icon(CupertinoIcons.xmark, size: 30),
          ),
          Expanded(
            child: Text(
              'Time Settings',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(fontSize: compact ? 24 : 28),
            ),
          ),
          IconButton(
            onPressed: onDone,
            icon: const Icon(CupertinoIcons.checkmark, size: 32),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onModeChanged});

  final FocusMode mode;
  final ValueChanged<FocusMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tight = constraints.maxWidth < 340;

          final selector = SegmentedSelector<FocusMode>(
            values: const [FocusMode.pomodoro, FocusMode.stopwatch],
            selectedValue: mode,
            labelBuilder: (value) {
              return switch (value) {
                FocusMode.pomodoro => 'Pomodoro',
                FocusMode.stopwatch => 'Stopwatch',
              };
            },
            onChanged: onModeChanged,
          );

          if (tight) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Focus Mode', style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.md),
                selector,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text('Focus Mode', style: AppTextStyles.headline),
              ),
              selector,
            ],
          );
        },
      ),
    );
  }
}

class _PomodoroCard extends StatelessWidget {
  const _PomodoroCard({
    required this.compact,
    required this.focusMinutes,
    required this.onChanged,
  });

  final bool compact;
  final int focusMinutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadii.pill),
                  ),
                ),
                child: SizedBox(width: 6, height: 28),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Pomodoro', style: AppTextStyles.headline),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              '${focusMinutes}m',
              style: AppTextStyles.timer.copyWith(fontSize: compact ? 56 : 68),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.graySoft,
              inactiveTrackColor: AppColors.graySoft,
              thumbColor: const Color(0xFFF16C72),
              trackHeight: 0,
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
              activeTickMarkColor: AppColors.charcoal,
              inactiveTickMarkColor: AppColors.charcoal,
            ),
            child: Slider(
              value: focusMinutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              onChanged: (value) => onChanged(value.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakSettingsCard extends StatelessWidget {
  const _BreakSettingsCard({required this.settings, required this.onChanged});

  final TimeSettings settings;
  final ValueChanged<TimeSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        children: [
          _SettingsRow(
            label: 'Long Break Interval',
            value: '${settings.longBreakInterval}',
            onTap: () => onChanged(
              settings.copyWith(
                longBreakInterval: _cycle(settings.longBreakInterval, 2, 6, 1),
              ),
            ),
          ),
          const Divider(color: AppColors.graySoft),
          _SettingsRow(
            label: 'Short Break',
            value: '${settings.shortBreakMinutes}m',
            onTap: () => onChanged(
              settings.copyWith(
                shortBreakMinutes: _cycle(settings.shortBreakMinutes, 5, 15),
              ),
            ),
          ),
          const Divider(color: AppColors.graySoft),
          _SettingsRow(
            label: 'Long Break',
            value: '${settings.longBreakMinutes}m',
            onTap: () => onChanged(
              settings.copyWith(
                longBreakMinutes: _cycle(settings.longBreakMinutes, 15, 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _cycle(int value, int min, int max, [int step = 5]) {
    final next = value + step;
    return next > max ? min : next;
  }
}

class _StopwatchCard extends StatelessWidget {
  const _StopwatchCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadii.pill),
                  ),
                ),
                child: SizedBox(width: 6, height: 28),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Stopwatch', style: AppTextStyles.headline),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Counts up until you stop or skip. Breaks are not started automatically.',
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headline,
              ),
            ),
            Text(value, style: AppTextStyles.bodyMuted),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.charcoal,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
