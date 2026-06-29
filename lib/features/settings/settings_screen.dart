import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/app_icon_button.dart';
import 'package:pats_space/core/widgets/primary_button.dart';
import 'package:pats_space/features/settings/models/app_language.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';

const _settingsBackgroundColor = Color(0xFFF5F4FA);

extension _LocalizedAppLanguage on AppLanguage {
  String localizedName(AppLocalizations l10n) {
    return switch (this) {
      AppLanguage.system => l10n.languageSystem,
      AppLanguage.english => l10n.languageEnglish,
      AppLanguage.german => l10n.languageGerman,
    };
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundsEnabled = true;
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _settingsBackgroundColor,
      child: Navigator(
        onGenerateRoute: (_) => _settingsRoute(
          (routeContext) => _MainSettingsPage(
            language: widget.language,
            soundsEnabled: _soundsEnabled,
            notificationsEnabled: _notificationsEnabled,
            onLanguagePressed: () {
              Navigator.of(routeContext).push(
                _settingsRoute(
                  (languageContext) => _LanguageSettingsPage(
                    selectedLanguage: widget.language,
                    onBack: () => Navigator.of(languageContext).maybePop(),
                    onLanguageSelected: widget.onLanguageChanged,
                  ),
                ),
              );
            },
            onSoundsPressed: () {
              Navigator.of(routeContext).push(
                _settingsRoute(
                  (soundsContext) => _SoundsSettingsPage(
                    soundsEnabled: _soundsEnabled,
                    onBack: () => Navigator.of(soundsContext).maybePop(),
                    onSoundsChanged: (value) {
                      setState(() => _soundsEnabled = value);
                    },
                  ),
                ),
              );
            },
            onNotificationsPressed: () {
              Navigator.of(routeContext).push(
                _settingsRoute(
                  (notificationsContext) => _NotificationsSettingsPage(
                    notificationsEnabled: _notificationsEnabled,
                    onBack: () => Navigator.of(notificationsContext).maybePop(),
                    onNotificationsChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ),
              );
            },
            onFeedbackLabPressed: () {
              Navigator.of(routeContext).push(
                _settingsRoute(
                  (feedbackContext) => _FeedbackLabPage(
                    onBack: () => Navigator.of(feedbackContext).maybePop(),
                  ),
                ),
              );
            },
            onAccountPressed: () {
              Navigator.of(routeContext).push(
                _settingsRoute(
                  (accountContext) => _AccountSettingsPage(
                    onBack: () => Navigator.of(accountContext).maybePop(),
                  ),
                ),
              );
            },
            onOthersPressed: () {
              Navigator.of(routeContext).push(
                _settingsRoute(
                  (othersContext) => _OthersSettingsPage(
                    onBack: () => Navigator.of(othersContext).maybePop(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  CupertinoPageRoute<void> _settingsRoute(WidgetBuilder builder) {
    return CupertinoPageRoute<void>(
      builder: (context) =>
          ColoredBox(color: _settingsBackgroundColor, child: builder(context)),
    );
  }
}

class _MainSettingsPage extends StatelessWidget {
  const _MainSettingsPage({
    required this.language,
    required this.soundsEnabled,
    required this.notificationsEnabled,
    required this.onLanguagePressed,
    required this.onSoundsPressed,
    required this.onNotificationsPressed,
    required this.onFeedbackLabPressed,
    required this.onAccountPressed,
    required this.onOthersPressed,
  });

  final AppLanguage language;
  final bool soundsEnabled;
  final bool notificationsEnabled;
  final VoidCallback onLanguagePressed;
  final VoidCallback onSoundsPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onFeedbackLabPressed;
  final VoidCallback onAccountPressed;
  final VoidCallback onOthersPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsScrollView(
      title: l10n.settingsTitle,
      children: [
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.person_crop_circle,
              title: l10n.account,
              trailing: const _Chevron(),
              onTap: onAccountPressed,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.globe,
              title: l10n.language,
              subtitle: language.localizedName(l10n),
              trailing: const _Chevron(),
              onTap: onLanguagePressed,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.speaker_2,
              title: l10n.sounds,
              subtitle: soundsEnabled ? l10n.on : l10n.off,
              trailing: const _Chevron(),
              onTap: onSoundsPressed,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.bell,
              title: l10n.notifications,
              subtitle: notificationsEnabled ? l10n.on : l10n.off,
              trailing: const _Chevron(),
              onTap: onNotificationsPressed,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.envelope,
              title: l10n.contactUs,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.bolt,
              title: l10n.feedbackLab,
              subtitle: l10n.feedbackLabSubtitle,
              trailing: const _Chevron(),
              onTap: onFeedbackLabPressed,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.ellipsis_circle,
              title: l10n.others,
              trailing: const _Chevron(),
              onTap: onOthersPressed,
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageSettingsPage extends StatelessWidget {
  const _LanguageSettingsPage({
    required this.selectedLanguage,
    required this.onBack,
    required this.onLanguageSelected,
  });

  final AppLanguage selectedLanguage;
  final VoidCallback onBack;
  final ValueChanged<AppLanguage> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const languages = AppLanguage.values;

    return _SettingsScrollView(
      title: l10n.language,
      leading: _BackButton(onPressed: onBack),
      children: [
        _SettingsGroup(
          children: [
            for (var index = 0; index < languages.length; index++) ...[
              _SettingsRow(
                icon: CupertinoIcons.globe,
                title: languages[index].localizedName(l10n),
                trailing: selectedLanguage == languages[index]
                    ? const _Checkmark()
                    : null,
                onTap: () => onLanguageSelected(languages[index]),
              ),
              if (index != languages.length - 1) const _SettingsDivider(),
            ],
          ],
        ),
      ],
    );
  }
}

class _SoundsSettingsPage extends StatelessWidget {
  const _SoundsSettingsPage({
    required this.soundsEnabled,
    required this.onBack,
    required this.onSoundsChanged,
  });

  final bool soundsEnabled;
  final VoidCallback onBack;
  final ValueChanged<bool> onSoundsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsScrollView(
      title: l10n.sounds,
      leading: _BackButton(onPressed: onBack),
      children: [
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.speaker_2,
              title: l10n.alertSounds,
              subtitle: l10n.alertSoundsDescription,
              trailing: CupertinoSwitch(
                value: soundsEnabled,
                activeTrackColor: AppColors.charcoal,
                onChanged: onSoundsChanged,
              ),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.speaker_1,
              title: l10n.sound,
              subtitle: l10n.softBell,
              trailing: const _Chevron(),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationsSettingsPage extends StatelessWidget {
  const _NotificationsSettingsPage({
    required this.notificationsEnabled,
    required this.onBack,
    required this.onNotificationsChanged,
  });

  final bool notificationsEnabled;
  final VoidCallback onBack;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsScrollView(
      title: l10n.notifications,
      leading: _BackButton(onPressed: onBack),
      children: [
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.bell,
              title: l10n.notifications,
              subtitle: l10n.notificationsDescription,
              trailing: CupertinoSwitch(
                value: notificationsEnabled,
                activeTrackColor: AppColors.charcoal,
                onChanged: onNotificationsChanged,
              ),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.timer,
              title: l10n.focusReminder,
              subtitle: l10n.focusReminderDescription,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.moon,
              title: l10n.breakReminder,
              subtitle: l10n.breakReminderDescription,
              trailing: const _Chevron(),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackLabPage extends StatelessWidget {
  const _FeedbackLabPage({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsScrollView(
      title: l10n.feedbackLab,
      leading: _BackButton(onPressed: onBack),
      children: [
        _FeedbackSection(
          title: l10n.rawHaptics,
          children: [
            _FeedbackTestButton(
              title: l10n.selectionHaptic,
              subtitle: l10n.selectionHapticDescription,
              icon: CupertinoIcons.circle_grid_3x3,
              onTap: AppHaptics.selection,
            ),
            _FeedbackTestButton(
              title: l10n.lightImpactHaptic,
              subtitle: l10n.lightImpactHapticDescription,
              icon: CupertinoIcons.play,
              onTap: AppHaptics.lightImpact,
            ),
            _FeedbackTestButton(
              title: l10n.mediumImpactHaptic,
              subtitle: l10n.mediumImpactHapticDescription,
              icon: CupertinoIcons.forward_end,
              onTap: AppHaptics.mediumImpact,
            ),
            _FeedbackTestButton(
              title: l10n.heavyImpactHaptic,
              subtitle: l10n.heavyImpactHapticDescription,
              icon: CupertinoIcons.circle_fill,
              onTap: AppHaptics.heavyImpact,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _FeedbackSection(
          title: l10n.patternHaptics,
          children: [
            _FeedbackTestButton(
              title: l10n.successHaptic,
              subtitle: l10n.successHapticDescription,
              icon: CupertinoIcons.checkmark_circle,
              onTap: AppHaptics.success,
            ),
            _FeedbackTestButton(
              title: l10n.warningHaptic,
              subtitle: l10n.warningHapticDescription,
              icon: CupertinoIcons.exclamationmark_triangle,
              onTap: AppHaptics.warning,
            ),
            _FeedbackTestButton(
              title: l10n.rewardPatternHaptic,
              subtitle: l10n.rewardPatternHapticDescription,
              icon: CupertinoIcons.drop_fill,
              onTap: AppHaptics.reward,
            ),
            _FeedbackTestButton(
              title: l10n.purchasePatternHaptic,
              subtitle: l10n.purchasePatternHapticDescription,
              icon: CupertinoIcons.bag,
              onTap: AppHaptics.purchase,
            ),
            _FeedbackTestButton(
              title: l10n.unlockPatternHaptic,
              subtitle: l10n.unlockPatternHapticDescription,
              icon: CupertinoIcons.sparkles,
              onTap: AppHaptics.unlock,
            ),
            _FeedbackTestButton(
              title: l10n.errorPatternHaptic,
              subtitle: l10n.errorPatternHapticDescription,
              icon: CupertinoIcons.xmark_octagon,
              onTap: AppHaptics.error,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _FeedbackSection(
          title: l10n.appFeedback,
          children: [
            PrimaryButton(label: l10n.primaryButtonFeedback, onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _IconFeedbackDemo(
                    label: l10n.iconButtonLightFeedback,
                    icon: CupertinoIcons.play,
                    haptic: AppIconButtonHaptic.light,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _IconFeedbackDemo(
                    label: l10n.iconButtonMediumFeedback,
                    icon: CupertinoIcons.xmark,
                    haptic: AppIconButtonHaptic.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.grayWarm,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _FeedbackTestButton extends StatelessWidget {
  const _FeedbackTestButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted.withValues(alpha: .52),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.charcoal, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

class _IconFeedbackDemo extends StatelessWidget {
  const _IconFeedbackDemo({
    required this.label,
    required this.icon,
    required this.haptic,
  });

  final String label;
  final IconData icon;
  final AppIconButtonHaptic haptic;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: .52),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            AppIconButton(icon: icon, haptic: haptic, onPressed: () {}),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSettingsPage extends StatelessWidget {
  const _AccountSettingsPage({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsScrollView(
      title: l10n.account,
      leading: _BackButton(onPressed: onBack),
      children: [
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.person_crop_circle,
              title: l10n.signIn,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.arrow_counterclockwise_circle,
              title: l10n.restorePurchases,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.trash,
              title: l10n.deleteAccount,
              destructive: true,
              trailing: const _Chevron(),
            ),
          ],
        ),
      ],
    );
  }
}

class _OthersSettingsPage extends StatelessWidget {
  const _OthersSettingsPage({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsScrollView(
      title: l10n.others,
      leading: _BackButton(onPressed: onBack),
      children: [
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.shield,
              title: l10n.privacyPolicy,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.doc_text,
              title: l10n.termsOfUse,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.info_circle,
              title: l10n.version,
              subtitle: l10n.appVersion,
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsScrollView extends StatelessWidget {
  const _SettingsScrollView({
    required this.title,
    required this.children,
    this.leading,
  });

  final String title;
  final List<Widget> children;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _settingsBackgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            MediaQuery.paddingOf(context).bottom + AppSpacing.xxl * 2.4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(height: AppSpacing.lg),
              ] else
                const SizedBox(height: AppSpacing.xxl * 1.35),
              Text(
                title,
                style: AppTextStyles.title.copyWith(
                  color: CupertinoColors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.2,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Icon(
                icon,
                color: destructive
                    ? CupertinoColors.systemRed
                    : AppColors.charcoal,
                size: 27,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headline.copyWith(
                      color: destructive
                          ? CupertinoColors.systemRed
                          : CupertinoColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -.1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMuted.copyWith(fontSize: 15),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: AppSpacing.xl + AppSpacing.lg,
      color: AppColors.surfaceMuted,
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.chevron_forward,
      color: Color(0xFFC7C7CC),
      size: 23,
    );
  }
}

class _Checkmark extends StatelessWidget {
  const _Checkmark();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.check_mark,
      color: AppColors.charcoal,
      size: 22,
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: .04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const SizedBox.square(
          dimension: 54,
          child: Icon(
            CupertinoIcons.chevron_left,
            color: AppColors.charcoal,
            size: 30,
          ),
        ),
      ),
    );
  }
}
