import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';
import 'package:pats_space/features/space/widgets/garden_coin_icon.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({
    super.key,
    required this.gardenController,
    required this.onOpenSpace,
  });

  final GardenController gardenController;
  final VoidCallback onOpenSpace;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gardenController,
      builder: (context, _) {
        final garden = gardenController.state;

        return SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: 132),
            children: [
              _ShopHeader(coins: garden.coins),
              const SizedBox(height: AppSpacing.xl),
              _ShopItemSection<GardenPotStyle>(
                title: 'Pot styles',
                subtitle: 'Pot looks',
                items: GardenPotStyle.shopStyles,
                isOwned: garden.ownedPotStyles.contains,
                isEquipped: (_) => false,
                nameOf: (style) => style.displayName,
                costOf: (style) => style.cost,
                assetOf: (style) => style.assetPath,
                actionLabel: (style) {
                  if (garden.ownedPotStyles.contains(style)) {
                    return 'Owned';
                  }
                  return null;
                },
                coins: garden.coins,
                onPrimaryAction: (style) {
                  final owned = garden.ownedPotStyles.contains(style);
                  if (owned) {
                    HapticFeedback.selectionClick();
                    return;
                  }

                  final success = gardenController.buyPotStyle(style);
                  if (success) {
                    HapticFeedback.mediumImpact();
                  } else {
                    HapticFeedback.selectionClick();
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              _ShopItemSection<GardenDecoration>(
                title: 'Decor',
                subtitle: 'Garden items',
                items: GardenDecoration.shopDecorations,
                isOwned: garden.ownedDecorations.contains,
                isEquipped: garden.placedDecorations.contains,
                isAvailable: (decoration) {
                  final requirement = decoration.requirement;
                  return requirement == null ||
                      garden.ownedDecorations.contains(requirement);
                },
                unavailableLabel: (decoration) {
                  final requirement = decoration.requirement;
                  return requirement == null
                      ? null
                      : 'Need ${requirement.displayName}';
                },
                nameOf: (decoration) => decoration.displayName,
                costOf: (decoration) => decoration.cost,
                assetOf: (decoration) => decoration.assetPath,
                actionLabel: (decoration) {
                  if (garden.placedDecorations.contains(decoration)) {
                    return 'Placed';
                  }
                  if (garden.ownedDecorations.contains(decoration)) {
                    return 'Place';
                  }
                  return null;
                },
                coins: garden.coins,
                onPrimaryAction: (decoration) {
                  final success = gardenController.buyDecoration(decoration);
                  if (success) {
                    HapticFeedback.mediumImpact();
                    gardenController.requestDecorationArrangement(decoration);
                    onOpenSpace();
                  } else {
                    HapticFeedback.selectionClick();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shop', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Collect pot styles and garden pieces for your space.',
                style: AppTextStyles.bodyMuted.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _CoinWallet(coins: coins),
      ],
    );
  }
}

class _CoinWallet extends StatelessWidget {
  const _CoinWallet({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.graySoft.withValues(alpha: .44)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: .06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GardenCoinIcon(size: 24),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$coins',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.grayWarm,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _ShopItemSection<T> extends StatelessWidget {
  const _ShopItemSection({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.isOwned,
    required this.isEquipped,
    this.isAvailable,
    this.unavailableLabel,
    required this.nameOf,
    required this.costOf,
    required this.assetOf,
    this.actionLabel,
    required this.coins,
    required this.onPrimaryAction,
  });

  final String title;
  final String subtitle;
  final List<T> items;
  final bool Function(T item) isOwned;
  final bool Function(T item) isEquipped;
  final bool Function(T item)? isAvailable;
  final String? Function(T item)? unavailableLabel;
  final String Function(T item) nameOf;
  final int Function(T item) costOf;
  final String Function(T item) assetOf;
  final String? Function(T item)? actionLabel;
  final int coins;
  final ValueChanged<T> onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title, subtitle: subtitle),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 210,
          child: ListView.separated(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              final owned = isOwned(item);
              final equipped = isEquipped(item);
              final cost = costOf(item);
              final available = isAvailable?.call(item) ?? true;
              final canBuy = available && coins >= cost;

              return _ShopProductCard(
                name: nameOf(item),
                assetPath: assetOf(item),
                cost: cost,
                owned: owned,
                equipped: equipped,
                available: available,
                unavailableLabel: unavailableLabel?.call(item),
                canBuy: canBuy,
                actionLabel: actionLabel?.call(item),
                onTap: () => onPrimaryAction(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShopProductCard extends StatelessWidget {
  const _ShopProductCard({
    required this.name,
    required this.assetPath,
    required this.cost,
    required this.owned,
    required this.equipped,
    required this.available,
    required this.unavailableLabel,
    required this.canBuy,
    required this.actionLabel,
    required this.onTap,
  });

  final String name;
  final String assetPath;
  final int cost;
  final bool owned;
  final bool equipped;
  final bool available;
  final String? unavailableLabel;
  final bool canBuy;
  final String? actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final resolvedActionLabel =
        actionLabel ??
        (equipped
            ? 'Equipped'
            : owned
            ? 'Use'
            : !available
            ? unavailableLabel ?? 'Locked'
            : canBuy
            ? '$cost'
            : 'Need $cost');

    return SizedBox(
      width: 146,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: equipped
                ? AppColors.sage.withValues(alpha: .58)
                : AppColors.graySoft.withValues(alpha: .42),
            width: equipped ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: .05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.sageSoft.withValues(alpha: .56),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: SizedBox.expand(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                name,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: equipped ? HapticFeedback.selectionClick : onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: equipped || owned
                        ? AppColors.sageSoft
                        : !available
                        ? AppColors.surfaceMuted.withValues(alpha: .64)
                        : canBuy
                        ? AppColors.charcoal
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!owned && available) ...[
                        GardenCoinIcon(size: 16),
                        const SizedBox(width: AppSpacing.xxs),
                      ],
                      Flexible(
                        child: Text(
                          resolvedActionLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: equipped || owned
                                ? AppColors.sagePressed
                                : !available
                                ? AppColors.grayWarm
                                : canBuy
                                ? AppColors.surface
                                : AppColors.grayWarm,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
