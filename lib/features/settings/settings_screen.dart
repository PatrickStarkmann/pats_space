import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';

const _settingsBackgroundColor = Color(0xFFF5F4FA);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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
            soundsEnabled: _soundsEnabled,
            notificationsEnabled: _notificationsEnabled,
            onSoundsChanged: (value) {
              setState(() => _soundsEnabled = value);
            },
            onNotificationsChanged: (value) {
              setState(() => _notificationsEnabled = value);
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
    required this.soundsEnabled,
    required this.notificationsEnabled,
    required this.onSoundsChanged,
    required this.onNotificationsChanged,
    required this.onAccountPressed,
    required this.onOthersPressed,
  });

  final bool soundsEnabled;
  final bool notificationsEnabled;
  final ValueChanged<bool> onSoundsChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onAccountPressed;
  final VoidCallback onOthersPressed;

  @override
  Widget build(BuildContext context) {
    return _SettingsScrollView(
      title: 'Settings',
      children: [
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.person_crop_circle,
              title: 'Account',
              trailing: const _Chevron(),
              onTap: onAccountPressed,
            ),
            const _SettingsDivider(),
            const _SettingsRow(
              icon: CupertinoIcons.globe,
              title: 'Language',
              subtitle: 'English',
              trailing: _Chevron(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.speaker_2,
              title: 'Sounds',
              subtitle: 'Focus and break alerts',
              trailing: CupertinoSwitch(
                value: soundsEnabled,
                activeTrackColor: AppColors.charcoal,
                onChanged: onSoundsChanged,
              ),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.bell,
              title: 'Notifications',
              subtitle: 'Session reminders and updates',
              trailing: CupertinoSwitch(
                value: notificationsEnabled,
                activeTrackColor: AppColors.charcoal,
                onChanged: onNotificationsChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SettingsGroup(
          children: [
            const _SettingsRow(
              icon: CupertinoIcons.envelope,
              title: 'Contact us',
              trailing: _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.ellipsis_circle,
              title: 'Others',
              trailing: const _Chevron(),
              onTap: onOthersPressed,
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountSettingsPage extends StatelessWidget {
  const _AccountSettingsPage({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _SettingsScrollView(
      title: 'Account',
      leading: _BackButton(onPressed: onBack),
      children: const [
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.person_crop_circle,
              title: 'Sign in',
              trailing: _Chevron(),
            ),
            _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.arrow_counterclockwise_circle,
              title: 'Restore purchases',
              trailing: _Chevron(),
            ),
            _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.trash,
              title: 'Delete account',
              destructive: true,
              trailing: _Chevron(),
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
    return _SettingsScrollView(
      title: 'Others',
      leading: _BackButton(onPressed: onBack),
      children: const [
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: CupertinoIcons.shield,
              title: 'Privacy policy',
              trailing: _Chevron(),
            ),
            _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.doc_text,
              title: 'Terms of use',
              trailing: _Chevron(),
            ),
            _SettingsDivider(),
            _SettingsRow(
              icon: CupertinoIcons.info_circle,
              title: 'Version',
              subtitle: 'Pat\'s Space 0.1.0',
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
