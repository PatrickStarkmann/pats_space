import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';

class RangePill extends StatelessWidget {
  const RangePill({
    super.key,
    required this.title,
    required this.onPrevious,
    required this.onNext,
    this.width = 162,
  });

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final double width;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: width,
        height: 42,
        child: Row(
          children: [
            _SmallPillArrow(
              icon: CupertinoIcons.chevron_left,
              onPressed: onPrevious,
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: AppTextStyles.headline.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _SmallPillArrow(
              icon: CupertinoIcons.chevron_right,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPillArrow extends StatelessWidget {
  const _SmallPillArrow({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: 40,
        height: 42,
        child: Icon(icon, color: AppColors.charcoal, size: 20),
      ),
    );
  }
}
