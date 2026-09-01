import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/analytics/app_analytics.dart';
import 'package:pats_space/core/app_links.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/looping_asset_animation.dart';
import 'package:pats_space/features/pro/controllers/pro_controller.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final _footerLinkStyle = AppTextStyles.caption.copyWith(
  color: AppColors.grayWarm,
  fontWeight: FontWeight.w700,
);

Future<void> _openLegalPage(Uri uri) async {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Opens the branded Pro purchase experience.
///
/// RevenueCat supplies the offering, products and entitlement. The
/// presentation stays native to Patsspace.
Future<void> openProScreen(
  BuildContext context, {
  required ProController controller,
}) {
  unawaited(AppAnalytics.instance.logPaywallOpened(source: 'pro_screen'));
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ProScreen(controller: controller),
      fullscreenDialog: true,
    ),
  );
}

class ProScreen extends StatelessWidget {
  const ProScreen({super.key, required this.controller});

  final ProController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _CloseButton(
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Text(
                          l10n.patsspacePro,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 31,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.proFocusThatGrows,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMuted,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const _PatVisual(),
                        const SizedBox(height: AppSpacing.md),
                        _ValueList(l10n: l10n),
                        const SizedBox(height: AppSpacing.xl),
                        AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) =>
                              _PurchaseArea(controller: controller, l10n: l10n),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: MaterialLocalizations.of(context).closeButtonTooltip,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppHaptics.lightImpact();
        onPressed();
      },
      child: const SizedBox(
        width: 48,
        height: 48,
        child: Icon(
          CupertinoIcons.chevron_back,
          color: AppColors.charcoal,
          size: 27,
        ),
      ),
    ),
  );
}

class _PatVisual extends StatelessWidget {
  const _PatVisual();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 238,
    child: LoopingAssetAnimation(
      frames: AppAssets.onboardingPatTalking,
      frameDuration: Duration(milliseconds: 1150),
      fit: BoxFit.contain,
      alignment: Alignment(0, .54),
    ),
  );
}

class _ValueList extends StatelessWidget {
  const _ValueList({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _ValueRow(title: l10n.proAllPlantsAndPots),
      const SizedBox(height: AppSpacing.sm),
      _ValueRow(title: l10n.proAllFocusAnimationSets),
      const SizedBox(height: AppSpacing.sm),
      _ValueRow(title: l10n.proNewContent),
    ],
  );
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 30,
        child: Text(
          '•',
          textAlign: TextAlign.center,
          style: AppTextStyles.headline.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _PurchaseArea extends StatefulWidget {
  const _PurchaseArea({required this.controller, required this.l10n});

  final ProController controller;
  final AppLocalizations l10n;

  @override
  State<_PurchaseArea> createState() => _PurchaseAreaState();
}

class _PurchaseAreaState extends State<_PurchaseArea> {
  String? _selectedPackageId;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = widget.l10n;
    final annualPackage = controller.annualPackage;
    final monthlyPackage = controller.monthlyPackage;
    final options = <_ProOption>[
      if (annualPackage != null)
        _ProOption(
          package: annualPackage,
          title: l10n.proYearly,
          subtitle: _annualMonthlyPrice(annualPackage, l10n),
          badge: _annualSavingsLabel(annualPackage, monthlyPackage, l10n),
        ),
      if (monthlyPackage != null)
        _ProOption(
          package: monthlyPackage,
          title: l10n.proMonthly,
          subtitle: l10n.proCancelAnytime,
        ),
      if (controller.lifetimePackage case final lifetime?)
        _ProOption(
          package: lifetime,
          title: l10n.proLifetime,
          subtitle: l10n.proUnlockedForever,
        ),
    ];

    if (controller.isPro) {
      return _StatusCard(
        icon: CupertinoIcons.checkmark_seal_fill,
        text: l10n.proActiveForAccount,
      );
    }
    if (!controller.isStoreConfigured) {
      return _StatusCard(icon: CupertinoIcons.clock, text: l10n.proBeingSetUp);
    }
    if (options.isEmpty) {
      return _StatusCard(icon: CupertinoIcons.clock, text: l10n.proOptionsSoon);
    }

    var selected = options.first;
    for (final option in options) {
      if (option.package.identifier == _selectedPackageId) {
        selected = option;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in options) ...[
          _OptionRow(
            option: option,
            selected: option.package.identifier == selected.package.identifier,
            onTap: controller.isBusy
                ? null
                : () {
                    AppHaptics.selection();
                    setState(
                      () => _selectedPackageId = option.package.identifier,
                    );
                  },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.xs),
        _PurchaseButton(
          label: l10n.proContinue,
          loading: controller.isBusy,
          onTap: controller.isBusy
              ? null
              : () async {
                  AppHaptics.mediumImpact();
                  final purchased = await controller.purchase(selected.package);
                  if (!context.mounted) return;
                  if (purchased) {
                    await _showPurchaseDialog(
                      context,
                      l10n: l10n,
                      restored: false,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  } else if (controller.error != null) {
                    await _showPurchaseDialog(
                      context,
                      l10n: l10n,
                      error: controller.error,
                    );
                  }
                },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.isBusy
                    ? null
                    : () async {
                        final restored = await controller.restorePurchases();
                        if (!context.mounted) return;
                        if (restored) {
                          await _showPurchaseDialog(
                            context,
                            l10n: l10n,
                            restored: true,
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        } else if (controller.error != null) {
                          await _showPurchaseDialog(
                            context,
                            l10n: l10n,
                            error: controller.error,
                          );
                        }
                      },
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Text(
                    l10n.proRestorePurchases,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: _footerLinkStyle,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _FooterLink(
                label: l10n.proTerms,
                onTap: () => unawaited(_openLegalPage(AppLinks.termsOfUse)),
              ),
            ),
            Expanded(
              child: _FooterLink(
                label: l10n.proPrivacy,
                onTap: () => unawaited(_openLegalPage(AppLinks.privacyPolicy)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _showPurchaseDialog(
  BuildContext context, {
  required AppLocalizations l10n,
  String? error,
  bool restored = false,
}) {
  final (title, detail) = switch (error) {
    null when restored => (
      l10n.proPurchasesRestoredTitle,
      l10n.proPurchasesRestoredMessage,
    ),
    null => (l10n.proWelcomeTitle, l10n.proWelcomeMessage),
    'missing_pro_entitlement' => (
      l10n.proNotActiveYetTitle,
      l10n.proNotActiveYetMessage,
    ),
    'no_restorable_pro_purchase' => (
      l10n.proNothingToRestoreTitle,
      l10n.proNothingToRestoreMessage,
    ),
    _ => (l10n.proPurchaseFailedTitle, l10n.proPurchaseFailedMessage),
  };

  return showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(
        title,
        style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w800),
      ),
      content: Text(detail, style: AppTextStyles.bodyMuted),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.done),
        ),
      ],
    ),
  );
}

String _annualMonthlyPrice(Package annualPackage, AppLocalizations l10n) {
  final monthlyPrice = annualPackage.storeProduct.pricePerMonthString;
  if (monthlyPrice != null && monthlyPrice.isNotEmpty) {
    return l10n.proMonthlyPrice(monthlyPrice);
  }

  final amount = (annualPackage.storeProduct.price / 12).toStringAsFixed(2);
  final currency = annualPackage.storeProduct.currencyCode;
  return l10n.proApproximateMonthlyPrice(amount, currency);
}

String? _annualSavingsLabel(
  Package annualPackage,
  Package? monthlyPackage,
  AppLocalizations l10n,
) {
  if (monthlyPackage == null || monthlyPackage.storeProduct.price <= 0) {
    return null;
  }

  final savings =
      (100 *
              (1 -
                  annualPackage.storeProduct.price /
                      (monthlyPackage.storeProduct.price * 12)))
          .round();
  if (savings <= 0) {
    return null;
  }
  return l10n.proSavePercent(savings);
}

class _ProOption {
  const _ProOption({
    required this.package,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  final Package package;
  final String title;
  final String subtitle;
  final String? badge;
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: _footerLinkStyle,
        ),
      ),
    ),
  );
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _ProOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '${option.title}, ${option.package.storeProduct.priceString}',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.sagePressed : AppColors.graySoft,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.charcoal : AppColors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.charcoal : AppColors.graySoft,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      CupertinoIcons.check_mark,
                      size: 14,
                      color: AppColors.surface,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        option.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (option.badge case final badge?) ...[
                        const SizedBox(width: AppSpacing.xs),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            child: Text(
                              badge,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.charcoal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(option.subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              option.package.storeProduct.priceString,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 140),
        opacity: onTap == null ? .65 : 1,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: loading
              ? const CupertinoActivityIndicator(color: AppColors.surface)
              : Text(label, style: AppTextStyles.button),
        ),
      ),
    ),
  );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.sageSoft,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.sagePressed),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.bodyMuted)),
        ],
      ),
    ),
  );
}
