import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pats_space/core/auth/account_auth_service.dart';
import 'package:pats_space/core/auth/firebase_account_auth_service.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/haptics/app_haptics.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/app_icon_button.dart';
import 'package:pats_space/core/widgets/primary_button.dart';
import 'package:pats_space/features/settings/models/app_language.dart';
import 'package:pats_space/features/settings/models/user_profile.dart';
import 'package:pats_space/features/settings/models/week_start_day.dart';
import 'package:pats_space/features/settings/repositories/firebase_user_profile_repository.dart';
import 'package:pats_space/features/settings/repositories/user_profile_repository.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

extension _LocalizedWeekStartDay on WeekStartDay {
  String localizedName(AppLocalizations l10n) {
    return switch (this) {
      WeekStartDay.monday => l10n.weekStartMonday,
      WeekStartDay.sunday => l10n.weekStartSunday,
    };
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required this.onAccountDeleted,
    required this.onSignedOutToGuest,
    required this.weekStartDay,
    required this.onWeekStartDayChanged,
    required this.remoteAvailable,
    required this.onEnsureOnlineAction,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final Future<void> Function(String deletedUserId) onAccountDeleted;
  final Future<void> Function() onSignedOutToGuest;
  final WeekStartDay weekStartDay;
  final ValueChanged<WeekStartDay> onWeekStartDayChanged;
  final bool remoteAvailable;
  final Future<bool> Function() onEnsureOnlineAction;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundsEnabled = true;
  bool _notificationsEnabled = false;
  late final UserProfileRepository _profileRepository;

  @override
  void initState() {
    super.initState();
    _profileRepository = FirebaseUserProfileRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _settingsBackgroundColor,
      child: Navigator(
        onGenerateRoute: (_) => _settingsRoute(
          (routeContext) => _MainSettingsPage(
            language: widget.language,
            profileRepository: _profileRepository,
            remoteAvailable: widget.remoteAvailable,
            onEnsureOnlineAction: widget.onEnsureOnlineAction,
            soundsEnabled: _soundsEnabled,
            notificationsEnabled: _notificationsEnabled,
            weekStartDay: widget.weekStartDay,
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
            onWeekStartDayPressed: () {
              Navigator.of(routeContext).push(
                _settingsRoute(
                  (weekStartContext) => _WeekStartDaySettingsPage(
                    selectedWeekStartDay: widget.weekStartDay,
                    onBack: () => Navigator.of(weekStartContext).maybePop(),
                    onWeekStartDaySelected: widget.onWeekStartDayChanged,
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
                    onAccountDeleted: widget.onAccountDeleted,
                    onSignedOutToGuest: widget.onSignedOutToGuest,
                    onEnsureOnlineAction: widget.onEnsureOnlineAction,
                  ),
                ),
              );
            },
            onFriendsPressed: () {
              Navigator.of(routeContext).push(
                _settingsRoute(
                  (friendsContext) => _FriendsSettingsPage(
                    repository: _profileRepository,
                    onEnsureOnlineAction: widget.onEnsureOnlineAction,
                    onBack: () => Navigator.of(friendsContext).maybePop(),
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
    required this.profileRepository,
    required this.remoteAvailable,
    required this.onEnsureOnlineAction,
    required this.soundsEnabled,
    required this.notificationsEnabled,
    required this.weekStartDay,
    required this.onLanguagePressed,
    required this.onSoundsPressed,
    required this.onNotificationsPressed,
    required this.onWeekStartDayPressed,
    required this.onFeedbackLabPressed,
    required this.onAccountPressed,
    required this.onFriendsPressed,
    required this.onOthersPressed,
  });

  final AppLanguage language;
  final UserProfileRepository profileRepository;
  final bool remoteAvailable;
  final Future<bool> Function() onEnsureOnlineAction;
  final bool soundsEnabled;
  final bool notificationsEnabled;
  final WeekStartDay weekStartDay;
  final VoidCallback onLanguagePressed;
  final VoidCallback onSoundsPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onWeekStartDayPressed;
  final VoidCallback onFeedbackLabPressed;
  final VoidCallback onAccountPressed;
  final VoidCallback onFriendsPressed;
  final VoidCallback onOthersPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsScrollView(
      title: l10n.settingsTitle,
      children: [
        _ProfileCard(
          repository: profileRepository,
          remoteAvailable: remoteAvailable,
          onEnsureOnlineAction: onEnsureOnlineAction,
        ),
        const SizedBox(height: AppSpacing.lg),
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: PhosphorIconsRegular.userCircleGear,
              title: l10n.account,
              trailing: const _Chevron(),
              onTap: onAccountPressed,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.users,
              title: l10n.friends,
              subtitle: l10n.friendsSettingsSubtitle,
              trailing: const _Chevron(),
              onTap: onFriendsPressed,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.globe,
              title: l10n.language,
              subtitle: language.localizedName(l10n),
              trailing: const _Chevron(),
              onTap: onLanguagePressed,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.calendarBlank,
              title: l10n.weekStartDay,
              subtitle: weekStartDay.localizedName(l10n),
              trailing: const _Chevron(),
              onTap: onWeekStartDayPressed,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: PhosphorIconsRegular.speakerHigh,
              title: l10n.sounds,
              subtitle: soundsEnabled ? l10n.on : l10n.off,
              trailing: const _Chevron(),
              onTap: onSoundsPressed,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.bell,
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
              icon: PhosphorIconsRegular.envelope,
              title: l10n.contactUs,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.lightning,
              title: l10n.feedbackLab,
              subtitle: l10n.feedbackLabSubtitle,
              trailing: const _Chevron(),
              onTap: onFeedbackLabPressed,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.dotsThreeCircle,
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

class _ProfileCard extends StatefulWidget {
  const _ProfileCard({
    required this.repository,
    required this.remoteAvailable,
    required this.onEnsureOnlineAction,
  });

  final UserProfileRepository repository;
  final bool remoteAvailable;
  final Future<bool> Function() onEnsureOnlineAction;

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  StreamSubscription<User?>? _authSubscription;
  Future<UserProfile>? _profileFuture;
  UserProfile? _profile;
  int _profileLoadGeneration = 0;
  String? _loadedUserId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) {
        return;
      }

      if (user == null) {
        setState(() {
          _profile = null;
          _profileFuture = null;
          _loadedUserId = null;
        });
        return;
      }

      if (_loadedUserId == user.uid && _profile != null) {
        return;
      }

      setState(() {
        _profile = null;
        _profileFuture = _loadProfile();
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<UserProfile> _loadProfile() async {
    final generation = ++_profileLoadGeneration;
    final profile = await widget.repository.loadProfile();
    if (mounted && generation == _profileLoadGeneration) {
      setState(() {
        _profile = profile;
        _loadedUserId = profile.uid;
      });
    }
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = _profile ?? snapshot.data;
        final displayName = profile?.displayName ?? l10n.loading;
        final friendCode = profile?.friendCode ?? l10n.loading;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.person_crop_circle_fill,
                    color: AppColors.charcoal,
                    size: 42,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.yourProfile,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.grayWarm,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headline.copyWith(
                            color: CupertinoColors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: profile == null || _saving
                        ? null
                        : () => _editDisplayName(context, profile),
                    icon: _saving
                        ? const CupertinoActivityIndicator()
                        : const PhosphorIcon(
                            PhosphorIconsRegular.pencilSimple,
                            size: 23,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _settingsBackgroundColor,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.friendCode,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grayWarm,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            friendCode,
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.charcoal,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: profile == null
                          ? null
                          : () => _copyFriendCode(profile.friendCode),
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.copy,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyFriendCode(String friendCode) async {
    await Clipboard.setData(ClipboardData(text: friendCode));
    AppHaptics.selection();
    if (!mounted) {
      return;
    }

    await _showMessage(AppLocalizations.of(context).friendCodeCopied);
  }

  Future<void> _editDisplayName(
    BuildContext context,
    UserProfile profile,
  ) async {
    AppHaptics.selection();

    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: profile.displayName);
    final updatedName = await showCupertinoDialog<String>(
      context: context,
      builder: (context) {
        return _EditDisplayNameDialog(
          controller: controller,
          title: l10n.editName,
          placeholder: l10n.namePlaceholder,
          cancelLabel: l10n.cancel,
          saveLabel: l10n.save,
        );
      },
    );
    controller.dispose();

    final trimmedName = updatedName?.trim();
    if (trimmedName == null ||
        trimmedName.isEmpty ||
        trimmedName == profile.displayName) {
      return;
    }

    if (!await widget.onEnsureOnlineAction()) {
      await _showMessage(l10n.settingsOnlineRequired);
      return;
    }

    setState(() => _saving = true);
    final UserProfile savedProfile;
    try {
      savedProfile = await widget.repository.saveDisplayName(trimmedName);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _saving = false);
      await _showMessage(l10n.accountSecureFailed);
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _profile = savedProfile;
      _saving = false;
    });
  }

  Future<void> _showMessage(String message) {
    final l10n = AppLocalizations.of(context);
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.done),
            ),
          ],
        );
      },
    );
  }
}

class _EditDisplayNameDialog extends StatefulWidget {
  const _EditDisplayNameDialog({
    required this.controller,
    required this.title,
    required this.placeholder,
    required this.cancelLabel,
    required this.saveLabel,
  });

  final TextEditingController controller;
  final String title;
  final String placeholder;
  final String cancelLabel;
  final String saveLabel;

  @override
  State<_EditDisplayNameDialog> createState() => _EditDisplayNameDialogState();
}

class _EditDisplayNameDialogState extends State<_EditDisplayNameDialog> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) {
        return;
      }

      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.title),
      content: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: CupertinoTextField(
          controller: widget.controller,
          focusNode: _focusNode,
          clearButtonMode: OverlayVisibilityMode.editing,
          maxLength: 24,
          placeholder: widget.placeholder,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            Navigator.of(context).pop(widget.controller.text);
          },
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(widget.controller.text),
          child: Text(widget.saveLabel),
        ),
      ],
    );
  }
}

class _FriendsSettingsPage extends StatefulWidget {
  const _FriendsSettingsPage({
    required this.repository,
    required this.onEnsureOnlineAction,
    required this.onBack,
  });

  final UserProfileRepository repository;
  final Future<bool> Function() onEnsureOnlineAction;
  final VoidCallback onBack;

  @override
  State<_FriendsSettingsPage> createState() => _FriendsSettingsPageState();
}

class _FriendsSettingsPageState extends State<_FriendsSettingsPage> {
  late Future<void> _loadFuture = _loadFriends();
  List<UserFriend> _friends = const [];
  List<FriendRequest> _incomingRequests = const [];
  List<FriendRequest> _sentRequests = const [];
  bool _sendingRequest = false;
  String? _busyId;

  Future<void> _loadFriends() async {
    final results = await Future.wait([
      widget.repository.loadFriends(),
      widget.repository.loadIncomingFriendRequests(),
      widget.repository.loadSentFriendRequests(),
    ]);
    if (!mounted) {
      return;
    }

    setState(() {
      _friends = results[0] as List<UserFriend>;
      _incomingRequests = results[1] as List<FriendRequest>;
      _sentRequests = results[2] as List<FriendRequest>;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsScrollView(
      title: l10n.friends,
      leading: _BackButton(onPressed: widget.onBack),
      children: [
        FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CupertinoActivityIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsGroup(
                  children: [
                    _SettingsRow(
                      icon: PhosphorIconsRegular.userPlus,
                      title: l10n.addFriend,
                      subtitle: l10n.addFriendSubtitle,
                      trailing: _sendingRequest
                          ? const CupertinoActivityIndicator()
                          : const _Chevron(),
                      onTap: _sendingRequest ? null : _sendFriendRequest,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _FriendsSection(
                  title: l10n.incomingRequests,
                  emptyText: l10n.noIncomingRequests,
                  children: [
                    for (final request in _incomingRequests)
                      _ProfileActionRow(
                        icon: PhosphorIconsRegular.users,
                        title: request.displayName,
                        subtitle: request.friendCode,
                        trailing: _busyId == request.uid
                            ? const CupertinoActivityIndicator()
                            : _ActionText(l10n.accept),
                        onTap: _busyId == null
                            ? () => _acceptFriendRequest(request)
                            : null,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _FriendsSection(
                  title: l10n.sentRequests,
                  emptyText: l10n.noSentRequests,
                  children: [
                    for (final request in _sentRequests)
                      _ProfileActionRow(
                        icon: PhosphorIconsRegular.paperPlaneTilt,
                        title: request.displayName,
                        subtitle: l10n.pending,
                        trailing: _busyId == request.uid
                            ? const CupertinoActivityIndicator()
                            : _ActionText(l10n.cancelRequest),
                        onTap: _busyId == null
                            ? () => _cancelFriendRequest(request)
                            : null,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _FriendsSection(
                  title: l10n.friends,
                  emptyText: l10n.noFriendsYet,
                  children: [
                    for (final friend in _friends)
                      _ProfileActionRow(
                        icon: PhosphorIconsRegular.user,
                        title: friend.displayName,
                        subtitle: friend.friendCode,
                        trailing: _busyId == friend.uid
                            ? const CupertinoActivityIndicator()
                            : _ActionText(l10n.remove),
                        onTap: _busyId == null
                            ? () => _deleteFriend(friend)
                            : null,
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _sendFriendRequest() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final friendCode = await showCupertinoDialog<String>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.addFriend),
          content: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: CupertinoTextField(
              controller: controller,
              autofocus: true,
              clearButtonMode: OverlayVisibilityMode.editing,
              placeholder: l10n.friendCodePlaceholder,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
    controller.dispose();

    final trimmedCode = friendCode?.trim();
    if (trimmedCode == null || trimmedCode.isEmpty) {
      return;
    }

    if (!await widget.onEnsureOnlineAction()) {
      await _showMessage(l10n.settingsOnlineRequired);
      return;
    }

    setState(() => _sendingRequest = true);
    try {
      await widget.repository.sendFriendRequestByCode(trimmedCode);
      if (!mounted) {
        return;
      }

      await _refresh();
      await _showMessage(l10n.friendRequestSent);
    } on FriendCodeException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _sendingRequest = false);
      await _showMessage(
        error.failure == FriendCodeFailure.self
            ? l10n.cannotAddYourself
            : l10n.friendCodeNotFound,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _sendingRequest = false);
      await _showMessage(l10n.friendAddFailed);
    }
  }

  Future<void> _acceptFriendRequest(FriendRequest request) async {
    final l10n = AppLocalizations.of(context);
    if (!await widget.onEnsureOnlineAction()) {
      await _showMessage(l10n.settingsOnlineRequired);
      return;
    }

    setState(() => _busyId = request.uid);
    try {
      await widget.repository.acceptFriendRequest(request);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _busyId = null);
      await _showMessage(l10n.friendAddFailed);
      return;
    }
    if (!mounted) {
      return;
    }

    await _refresh();
    await _showMessage(l10n.friendAdded);
  }

  Future<void> _cancelFriendRequest(FriendRequest request) async {
    final l10n = AppLocalizations.of(context);
    if (!await widget.onEnsureOnlineAction()) {
      await _showMessage(l10n.settingsOnlineRequired);
      return;
    }

    setState(() => _busyId = request.uid);
    try {
      await widget.repository.cancelFriendRequest(request);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _busyId = null);
      await _showMessage(l10n.friendAddFailed);
      return;
    }
    if (!mounted) {
      return;
    }

    await _refresh();
  }

  Future<void> _deleteFriend(UserFriend friend) async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.removeFriendTitle),
          content: Text(l10n.removeFriendMessage(friend.displayName)),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.remove),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) {
      return;
    }

    if (!await widget.onEnsureOnlineAction()) {
      await _showMessage(l10n.settingsOnlineRequired);
      return;
    }

    setState(() => _busyId = friend.uid);
    try {
      await widget.repository.deleteFriend(friend);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _busyId = null);
      await _showMessage(l10n.friendAddFailed);
      return;
    }
    if (!mounted) {
      return;
    }

    await _refresh();
  }

  Future<void> _refresh() async {
    await _loadFriends();
    if (!mounted) {
      return;
    }

    setState(() {
      _sendingRequest = false;
      _busyId = null;
      _loadFuture = Future.value();
    });
  }

  Future<void> _showMessage(String message) {
    final l10n = AppLocalizations.of(context);
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.done),
            ),
          ],
        );
      },
    );
  }
}

class _FriendsSection extends StatelessWidget {
  const _FriendsSection({
    required this.title,
    required this.emptyText,
    required this.children,
  });

  final String title;
  final String emptyText;
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
        if (children.isEmpty)
          _SettingsGroup(
            children: [
              _SettingsRow(icon: PhosphorIconsRegular.user, title: emptyText),
            ],
          )
        else
          Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1)
                  const SizedBox(height: AppSpacing.xs),
              ],
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
                icon: PhosphorIconsRegular.globe,
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

class _WeekStartDaySettingsPage extends StatelessWidget {
  const _WeekStartDaySettingsPage({
    required this.selectedWeekStartDay,
    required this.onBack,
    required this.onWeekStartDaySelected,
  });

  final WeekStartDay selectedWeekStartDay;
  final VoidCallback onBack;
  final ValueChanged<WeekStartDay> onWeekStartDaySelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const weekStartDays = WeekStartDay.values;

    return _SettingsScrollView(
      title: l10n.weekStartDay,
      leading: _BackButton(onPressed: onBack),
      children: [
        _SettingsGroup(
          children: [
            for (var index = 0; index < weekStartDays.length; index++) ...[
              _SettingsRow(
                icon: PhosphorIconsRegular.calendarBlank,
                title: weekStartDays[index].localizedName(l10n),
                trailing: selectedWeekStartDay == weekStartDays[index]
                    ? const _Checkmark()
                    : null,
                onTap: () => onWeekStartDaySelected(weekStartDays[index]),
              ),
              if (index != weekStartDays.length - 1) const _SettingsDivider(),
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
              icon: PhosphorIconsRegular.speakerHigh,
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
              icon: PhosphorIconsRegular.speakerLow,
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
              icon: PhosphorIconsRegular.bell,
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
              icon: PhosphorIconsRegular.timer,
              title: l10n.focusReminder,
              subtitle: l10n.focusReminderDescription,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.moon,
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
  final Object icon;
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
                _SettingsIcon(icon, color: AppColors.charcoal, size: 24),
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

class _AccountSettingsPage extends StatefulWidget {
  const _AccountSettingsPage({
    required this.onBack,
    required this.onAccountDeleted,
    required this.onSignedOutToGuest,
    required this.onEnsureOnlineAction,
  });

  final VoidCallback onBack;
  final Future<void> Function(String deletedUserId) onAccountDeleted;
  final Future<void> Function() onSignedOutToGuest;
  final Future<bool> Function() onEnsureOnlineAction;

  @override
  State<_AccountSettingsPage> createState() => _AccountSettingsPageState();
}

enum _AccountSignInMethod { apple, google }

class _AccountSettingsPageState extends State<_AccountSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final AccountAuthService _accountAuthService =
      FirebaseAccountAuthService(
        auth: _auth,
        firestore: FirebaseFirestore.instance,
      );
  bool _linking = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = _auth.currentUser;
    final secured = user != null && !user.isAnonymous;
    final providerIds =
        user?.providerData.map((provider) => provider.providerId).toSet() ??
        const <String>{};

    return _SettingsScrollView(
      title: l10n.account,
      leading: _BackButton(onPressed: widget.onBack),
      children: [
        _SettingsGroup(
          children: [
            _SettingsRow(
              icon: secured
                  ? PhosphorIconsRegular.shieldCheck
                  : PhosphorIconsRegular.userCirclePlus,
              title: secured
                  ? l10n.signedInWithProvider(
                      _connectedProviderName(providerIds),
                    )
                  : l10n.signIn,
              subtitle: secured
                  ? l10n.signedInAccountSubtitle
                  : l10n.anonymousAccountSubtitle,
              trailing: _linking
                  ? const CupertinoActivityIndicator()
                  : secured
                  ? null
                  : const _Chevron(),
              onTap: secured || _linking ? null : _showSignInOptions,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.arrowCounterClockwise,
              title: l10n.restorePurchases,
              trailing: const _Chevron(),
            ),
            if (secured) ...[
              const _SettingsDivider(),
              _SettingsRow(
                icon: PhosphorIconsRegular.signOut,
                title: l10n.signOut,
                destructive: true,
                onTap: _linking ? null : _confirmSignOut,
              ),
            ],
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.trash,
              title: l10n.deleteAccount,
              destructive: true,
              trailing: const _Chevron(),
              onTap: _linking ? null : _confirmDeleteAccount,
            ),
          ],
        ),
      ],
    );
  }

  String _connectedProviderName(Set<String> providerIds) {
    final connected = <String>[
      if (providerIds.contains(AppleAuthProvider.PROVIDER_ID)) 'Apple',
      if (providerIds.contains(GoogleAuthProvider.PROVIDER_ID)) 'Google',
    ];
    if (connected.isEmpty) {
      return 'Apple / Google';
    }

    return connected.join(', ');
  }

  Future<void> _showSignInOptions() async {
    final l10n = AppLocalizations.of(context);
    if (!await widget.onEnsureOnlineAction()) {
      await _showMessage(l10n.settingsOnlineRequired);
      return;
    }
    if (!mounted) {
      return;
    }

    final user = _auth.currentUser;
    final providerIds =
        user?.providerData.map((provider) => provider.providerId).toSet() ??
        const <String>{};
    final appleLinked = providerIds.contains(AppleAuthProvider.PROVIDER_ID);
    final googleLinked = providerIds.contains(GoogleAuthProvider.PROVIDER_ID);

    final method = await showCupertinoModalPopup<_AccountSignInMethod>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(l10n.signIn),
          message: Text(l10n.chooseSignInMethod),
          actions: [
            if (_accountAuthService.isAppleSignInAvailable)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(
                  context,
                ).pop(appleLinked ? null : _AccountSignInMethod.apple),
                child: _ProviderActionLabel(
                  mark: '',
                  label: l10n.continueWithApple,
                  connected: appleLinked,
                ),
              ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(
                context,
              ).pop(googleLinked ? null : _AccountSignInMethod.google),
              child: _ProviderActionLabel(
                mark: 'G',
                label: l10n.continueWithGoogle,
                connected: googleLinked,
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        );
      },
    );

    if (method == null) {
      return;
    }

    switch (method) {
      case _AccountSignInMethod.apple:
        await _secureAccount(_accountAuthService.secureWithApple);
      case _AccountSignInMethod.google:
        await _secureAccount(_accountAuthService.secureWithGoogle);
    }
  }

  Future<void> _secureAccount(
    Future<AccountAuthResult> Function() secure,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (!await widget.onEnsureOnlineAction()) {
      await _showMessage(l10n.settingsOnlineRequired);
      return;
    }

    setState(() => _linking = true);
    try {
      final result = await secure();
      final resolvedResult = await _resolveAccountAuthResult(result);
      if (!mounted) {
        return;
      }

      await _showMessage(_successMessage(resolvedResult));
      setState(() => _linking = false);
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      await _showMessage(
        _messageForAuthError(error, AppLocalizations.of(context)),
      );
      setState(() => _linking = false);
    } on GoogleSignInException catch (error) {
      if (!mounted) {
        return;
      }

      if (error.code != GoogleSignInExceptionCode.canceled) {
        await _showMessage(AppLocalizations.of(context).accountSecureFailed);
      }
      setState(() => _linking = false);
    } catch (_) {
      if (!mounted) {
        return;
      }

      await _showMessage(AppLocalizations.of(context).accountSecureFailed);
      setState(() => _linking = false);
    }
  }

  Future<AccountAuthResult> _resolveAccountAuthResult(
    AccountAuthResult result,
  ) async {
    if (result is! GuestReplacementRequired) {
      return result;
    }

    final shouldReplace = await _confirmReplaceGuestAccount();
    if (shouldReplace != true) {
      throw FirebaseAuthException(code: 'canceled');
    }

    return _accountAuthService.replaceGuestWithExistingAccount(result);
  }

  String _successMessage(AccountAuthResult result) {
    final l10n = AppLocalizations.of(context);
    return switch (result) {
      ExistingAccountSignedIn() => l10n.existingAccountSignInSuccess,
      _ => l10n.accountSecureSuccess,
    };
  }

  Future<bool?> _confirmReplaceGuestAccount() {
    final l10n = AppLocalizations.of(context);
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.replaceGuestAccountTitle),
          content: Text(l10n.replaceGuestAccountMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.replaceGuestAccountAction),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmSignOut() async {
    final l10n = AppLocalizations.of(context);
    final shouldSignOut = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.signOutTitle),
          content: Text(l10n.signOutMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.signOut),
            ),
          ],
        );
      },
    );
    if (shouldSignOut != true) {
      return;
    }

    if (!await widget.onEnsureOnlineAction()) {
      await _showMessage(l10n.settingsOnlineRequired);
      return;
    }

    setState(() => _linking = true);
    try {
      await _accountAuthService.signOutToGuest();
      await widget.onSignedOutToGuest();
      if (!mounted) {
        return;
      }

      setState(() => _linking = false);
      await _showMessage(l10n.signedOutMessage);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _linking = false);
      await _showMessage(l10n.accountSecureFailed);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.deleteAccountTitle),
          content: Text(l10n.deleteAccountMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteAccount),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) {
      return;
    }

    if (!await widget.onEnsureOnlineAction()) {
      await _showMessage(l10n.settingsOnlineRequired);
      return;
    }

    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final deletedUserId = _auth.currentUser?.uid;
    if (deletedUserId == null) {
      await _showMessage(l10n.accountDeleteFailed);
      return;
    }

    setState(() => _linking = true);
    try {
      await _accountAuthService.deleteCurrentAccount();
      await widget.onAccountDeleted(deletedUserId);
      if (!mounted) {
        return;
      }

      setState(() => _linking = false);
      await _showMessage(l10n.accountDeletedMessage);
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _linking = false);
      await _showMessage(_messageForDeleteError(error, l10n));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _linking = false);
      await _showMessage(l10n.accountDeleteFailed);
    }
  }

  String _messageForAuthError(
    FirebaseAuthException error,
    AppLocalizations l10n,
  ) {
    return switch (error.code) {
      'provider-already-linked' => l10n.providerAlreadyLinked,
      'credential-already-in-use' ||
      'account-exists-with-different-credential' ||
      'email-already-in-use' => l10n.accountProviderInUse,
      'operation-not-allowed' => l10n.providerNotEnabled,
      'web-context-cancelled' ||
      'popup-closed-by-user' ||
      'canceled' ||
      'cancelled' => l10n.signInCancelled,
      _ => l10n.accountSecureFailed,
    };
  }

  String _messageForDeleteError(
    FirebaseAuthException error,
    AppLocalizations l10n,
  ) {
    return switch (error.code) {
      'requires-recent-login' => l10n.accountDeleteNeedsSignIn,
      'web-context-cancelled' ||
      'popup-closed-by-user' ||
      'canceled' ||
      'cancelled' => l10n.signInCancelled,
      _ => l10n.accountDeleteFailed,
    };
  }

  Future<void> _showMessage(String message) {
    final l10n = AppLocalizations.of(context);
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.done),
            ),
          ],
        );
      },
    );
  }
}

class _ProviderActionLabel extends StatelessWidget {
  const _ProviderActionLabel({
    required this.mark,
    required this.label,
    required this.connected,
  });

  final String mark;
  final String label;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = connected ? AppColors.grayWarm : CupertinoColors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          child: mark == 'G'
              ? Opacity(
                  opacity: connected ? .45 : 1,
                  child: Center(
                    child: Image.asset(
                      AppAssets.googleLogo,
                      width: 18,
                      height: 18,
                    ),
                  ),
                )
              : Text(
                  mark,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          connected ? '$label · ${l10n.connected}' : label,
          style: AppTextStyles.body.copyWith(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
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
              icon: PhosphorIconsRegular.lockKey,
              title: l10n.privacyPolicy,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.scroll,
              title: l10n.termsOfUse,
              trailing: const _Chevron(),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: PhosphorIconsRegular.info,
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

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _settingsBackgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            _SettingsIcon(icon, color: AppColors.charcoal, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: CupertinoColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMuted.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ActionText extends StatelessWidget {
  const _ActionText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.charcoal,
        fontWeight: FontWeight.w800,
      ),
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

  final Object icon;
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
              child: _SettingsIcon(
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

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon(this.icon, {required this.color, required this.size});

  final Object icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    if (icon is PhosphorIconData) {
      return PhosphorIcon(icon, color: color, size: size);
    }
    if (icon is IconData) {
      return Icon(icon, color: color, size: size);
    }

    throw ArgumentError.value(icon, 'icon', 'Unsupported settings icon type');
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
