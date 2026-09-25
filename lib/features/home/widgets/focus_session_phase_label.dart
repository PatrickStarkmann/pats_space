import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';

/// A compact, textual phase indicator beneath the focus timer.
class FocusSessionPhaseLabel extends StatelessWidget {
  const FocusSessionPhaseLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
