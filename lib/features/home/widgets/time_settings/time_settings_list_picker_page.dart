import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_card.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_header.dart';

class TimeSettingsListPickerPage extends StatelessWidget {
  const TimeSettingsListPickerPage({
    super.key,
    required this.compact,
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onBack,
    required this.onChanged,
  });

  final bool compact;
  final String title;
  final List<int> values;
  final int selectedValue;
  final String Function(int value) labelBuilder;
  final VoidCallback onBack;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TimeSettingsGrabber(),
        TimeSettingsBackHeader(compact: compact, title: title, onBack: onBack),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: TimeSettingsCard(
              child: Column(
                children: List.generate(values.length, (index) {
                  final value = values[index];
                  return Column(
                    children: [
                      _ListPickerRow(
                        label: labelBuilder(value),
                        selected: value == selectedValue,
                        onTap: () => onChanged(value),
                      ),
                      if (index != values.length - 1)
                        const Divider(color: AppColors.graySoft),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ListPickerRow extends StatelessWidget {
  const _ListPickerRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!selected) {
          HapticFeedback.selectionClick();
        }
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              const Icon(
                CupertinoIcons.checkmark,
                color: Color(0xFFF16C72),
                size: 30,
              ),
          ],
        ),
      ),
    );
  }
}
