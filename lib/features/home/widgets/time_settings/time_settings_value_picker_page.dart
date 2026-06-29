import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_card.dart';
import 'package:pats_space/features/home/widgets/time_settings/time_settings_header.dart';

class TimeSettingsValuePickerPage extends StatefulWidget {
  const TimeSettingsValuePickerPage({
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
  State<TimeSettingsValuePickerPage> createState() =>
      _TimeSettingsValuePickerPageState();
}

class _TimeSettingsValuePickerPageState
    extends State<TimeSettingsValuePickerPage> {
  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final selectedIndex = widget.values.indexOf(widget.selectedValue);
    _scrollController = FixedExtentScrollController(
      initialItem: selectedIndex < 0 ? 0 : selectedIndex,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TimeSettingsGrabber(),
        TimeSettingsBackHeader(
          compact: widget.compact,
          title: widget.title,
          onBack: widget.onBack,
        ),
        SizedBox(height: widget.compact ? AppSpacing.md : AppSpacing.lg),
        TimeSettingsCard(
          child: SizedBox(
            height: widget.compact ? 210 : 260,
            child: CupertinoPicker(
              scrollController: _scrollController,
              itemExtent: 58,
              magnification: 1.08,
              squeeze: 1.05,
              useMagnifier: true,
              selectionOverlay: const _PickerSelectionOverlay(),
              onSelectedItemChanged: (index) {
                AppHaptics.selection();
                widget.onChanged(widget.values[index]);
              },
              children: widget.values.map((value) {
                final selected = value == widget.selectedValue;
                return Center(
                  child: Text(
                    widget.labelBuilder(value),
                    style: AppTextStyles.headline.copyWith(
                      color: selected ? AppColors.charcoal : AppColors.grayWarm,
                      fontSize: selected ? 30 : 25,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerSelectionOverlay extends StatelessWidget {
  const _PickerSelectionOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: const SizedBox(height: 58, width: double.infinity),
      ),
    );
  }
}
