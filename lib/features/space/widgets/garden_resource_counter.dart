import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/widgets/garden_coin_icon.dart';

class GardenResourceCounter extends StatelessWidget {
  const GardenResourceCounter({
    super.key,
    required this.water,
    required this.coins,
  });

  final int water;
  final int coins;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: AppTextStyles.body.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ResourceValue(
            icon: const Icon(
              CupertinoIcons.drop_fill,
              color: Color(0xFF65A9F7),
              size: 24,
            ),
            value: water,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              width: 1,
              height: 22,
              color: AppColors.graySoft.withValues(alpha: .55),
            ),
          ),
          _ResourceValue(icon: const GardenCoinIcon(size: 24), value: coins),
        ],
      ),
    );
  }
}

class _ResourceValue extends StatelessWidget {
  const _ResourceValue({required this.icon, required this.value});

  final Widget icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: AppSpacing.xs),
        Text(value.toString()),
      ],
    );
  }
}
