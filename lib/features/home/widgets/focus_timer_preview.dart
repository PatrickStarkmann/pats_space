import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';

class FocusTimerPreview extends StatelessWidget {
  const FocusTimerPreview({super.key, required this.timeLabel, this.onPressed});

  final String timeLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(timeLabel, maxLines: 1, style: AppTextStyles.timer),
      ),
    );
  }
}
