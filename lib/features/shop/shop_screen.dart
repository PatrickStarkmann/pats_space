import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/models/garden_decoration.dart';
import 'package:pats_space/features/space/models/garden_pot_style.dart';
import 'package:pats_space/features/space/widgets/garden_coin_icon.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

Future<void> showShopSheet({
  required BuildContext context,
  required GardenController gardenController,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: .92,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          child: ShopScreen(
            gardenController: gardenController,
            onClose: () => Navigator.of(context).pop(),
            onOpenSpace: () => Navigator.of(context).pop(),
          ),
        ),
      );
    },
  );
}

class ShopScreen extends StatelessWidget {
  const ShopScreen({
    super.key,
    required this.gardenController,
    this.onClose,
    this.onOpenSpace,
  });

  final GardenController gardenController;
  final VoidCallback? onClose;
  final VoidCallback? onOpenSpace;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gardenController,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final garden = gardenController.state;

        return ColoredBox(
          color: AppColors.background,
          child: SafeArea(
            bottom: false,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: ListView(
                clipBehavior: Clip.hardEdge,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: 132),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: _ShopHeader(coins: garden.coins, onClose: onClose),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _ShopItemSection<GardenPotStyle>(
                    title: l10n.potStyles,
                    items: GardenPotStyle.shopStyles,
                    isOwned: garden.ownedPotStyles.contains,
                    isEquipped: (_) => false,
                    nameOf: (style) => _potStyleName(style, l10n),
                    costOf: (style) => style.cost,
                    assetOf: (style) => style.assetPath,
                    actionLabel: (style) {
                      if (garden.ownedPotStyles.contains(style)) {
                        return l10n.collected;
                      }
                      return null;
                    },
                    coins: garden.coins,
                    onPrimaryAction: (style) {
                      final owned = garden.ownedPotStyles.contains(style);
                      if (owned) {
                        AppHaptics.error();
                        return;
                      }

                      final success = gardenController.buyPotStyle(style);
                      if (success) {
                        AppHaptics.purchase();
                      } else {
                        AppHaptics.error();
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _ShopItemSection<GardenDecoration>(
                    title: l10n.decor,
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
                          : l10n.needItem(_decorationName(requirement, l10n));
                    },
                    nameOf: (decoration) => _decorationName(decoration, l10n),
                    costOf: (decoration) => decoration.cost,
                    assetOf: (decoration) => decoration.assetPath,
                    actionLabel: (decoration) {
                      if (garden.placedDecorations.contains(decoration)) {
                        return l10n.inGarden;
                      }
                      if (garden.ownedDecorations.contains(decoration)) {
                        return l10n.place;
                      }
                      return null;
                    },
                    coins: garden.coins,
                    onPrimaryAction: (decoration) {
                      final success = gardenController.buyDecoration(
                        decoration,
                      );
                      if (success) {
                        AppHaptics.purchase();
                        gardenController.requestDecorationArrangement(
                          decoration,
                        );
                        onOpenSpace?.call();
                      } else {
                        AppHaptics.error();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _potStyleName(GardenPotStyle style, AppLocalizations l10n) {
  return switch (style) {
    GardenPotStyle.classic => l10n.potClassic,
    GardenPotStyle.blue => l10n.potBlue,
    GardenPotStyle.colorful => l10n.potColorful,
    GardenPotStyle.hanging => l10n.potHanging,
    GardenPotStyle.round => l10n.potRound,
    GardenPotStyle.white => l10n.potWhite,
  };
}

String _decorationName(GardenDecoration decoration, AppLocalizations l10n) {
  return switch (decoration) {
    GardenDecoration.bench => l10n.decorBench,
    GardenDecoration.fountain => l10n.decorFountain,
    GardenDecoration.hangingPlantFrame => l10n.decorPlantFrame,
    GardenDecoration.hangingPot => l10n.decorHangingPot,
    GardenDecoration.lantern => l10n.decorLantern,
    GardenDecoration.stonePath => l10n.decorStonePath,
    GardenDecoration.wateringCan => l10n.decorWateringCan,
  };
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.coins, required this.onClose});

  final int coins;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        if (onClose != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: CupertinoButton(
              minimumSize: const Size(44, 44),
              padding: EdgeInsets.zero,
              onPressed: onClose,
              child: const Icon(
                CupertinoIcons.xmark,
                color: AppColors.charcoal,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.shop, style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.shopDescription,
                    style: AppTextStyles.bodyMuted.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _CoinWallet(coins: coins),
          ],
        ),
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
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _ShopItemSection<T> extends StatelessWidget {
  const _ShopItemSection({
    required this.title,
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
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: _SectionTitle(title: title),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 210,
          child: ListView.separated(
            clipBehavior: Clip.hardEdge,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
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
    final l10n = AppLocalizations.of(context);
    final resolvedActionLabel =
        actionLabel ??
        (equipped
            ? l10n.equipped
            : owned
            ? l10n.use
            : !available
            ? unavailableLabel ?? l10n.locked
            : '$cost');

    final buttonColor = equipped
        ? AppColors.sageSoft
        : owned
        ? AppColors.surfaceMuted.withValues(alpha: .75)
        : !available
        ? AppColors.surfaceMuted.withValues(alpha: .64)
        : canBuy
        ? AppColors.charcoal
        : AppColors.surfaceMuted;
    final buttonTextColor = equipped
        ? AppColors.sagePressed
        : owned
        ? AppColors.charcoal
        : !available
        ? AppColors.grayWarm
        : canBuy
        ? AppColors.surface
        : AppColors.grayWarm;

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
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox.expand(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: owned
                          ? AppColors.sageSoft.withValues(alpha: .5)
                          : AppColors.surfaceMuted.withValues(alpha: .42),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Center(
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: equipped ? AppHaptics.error : onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor,
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
                            color: buttonTextColor,
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
