import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pats_space/app/navigation/app_tab.dart';
import 'package:pats_space/core/auth/account_auth_service.dart';
import 'package:pats_space/core/auth/firebase_account_auth_service.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_radii.dart';
import 'package:pats_space/core/theme/app_spacing.dart';
import 'package:pats_space/core/theme/app_text_styles.dart';
import 'package:pats_space/core/widgets/app_scaffold.dart';
import 'package:pats_space/core/widgets/patsspace_bottom_nav_bar.dart';
import 'package:pats_space/features/focus/controllers/focus_history_controller.dart';
import 'package:pats_space/features/focus/controllers/focus_timer_controller.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/models/focus_timer_settings.dart';
import 'package:pats_space/features/focus/repositories/firebase_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/focus_settings_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_history_repository.dart';
import 'package:pats_space/features/focus/repositories/shared_preferences_focus_settings_repository.dart';
import 'package:pats_space/features/home/home_screen.dart';
import 'package:pats_space/features/onboarding/onboarding_screen.dart';
import 'package:pats_space/features/settings/models/app_language.dart';
import 'package:pats_space/features/settings/settings_screen.dart';
import 'package:pats_space/features/space/controllers/garden_controller.dart';
import 'package:pats_space/features/space/models/garden_state.dart';
import 'package:pats_space/features/space/repositories/firebase_garden_repository.dart';
import 'package:pats_space/features/space/repositories/shared_preferences_garden_repository.dart';
import 'package:pats_space/features/space/space_screen.dart';
import 'package:pats_space/features/stats/stats_screen.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _onboardingCompletedKey = 'onboarding.completed.v1';
  static const _gardenTutorialCompletedKey =
      'onboarding.garden_tutorial_completed.v1';

  AppTab _selectedTab = AppTab.home;
  late Future<_AppPersistenceBundle> _persistenceFuture;
  StreamSubscription<User?>? _authSubscription;
  String? _requestedPersistenceUid;
  FocusHistoryController? _historyController;
  GardenController? _gardenController;
  bool _gardenTutorialActive = false;
  late final AccountAuthService _accountAuthService =
      FirebaseAccountAuthService(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      );

  @override
  void initState() {
    super.initState();
    _requestedPersistenceUid = FirebaseAuth.instance.currentUser?.uid;
    _persistenceFuture = _loadPersistence();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      final uid = user?.uid;
      if (uid == null) {
        return;
      }
      if (uid == _requestedPersistenceUid) {
        return;
      }

      _requestedPersistenceUid = uid;
      _historyController?.dispose();
      _gardenController?.dispose();
      _historyController = null;
      _gardenController = null;
      setState(() {
        _persistenceFuture = _loadPersistence();
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _historyController?.dispose();
    _gardenController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppPersistenceBundle>(
      future: _persistenceFuture,
      builder: (context, snapshot) {
        final bundle = snapshot.connectionState == ConnectionState.done
            ? snapshot.data
            : null;
        if (bundle == null) {
          return const AppScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        return _AppShellContent(
          selectedTab: _selectedTab,
          onTabSelected: (tab) {
            setState(() => _selectedTab = tab);
          },
          onOnboardingFinished: _handleOnboardingFinished,
          gardenTutorialActive: _gardenTutorialActive,
          onGardenTutorialCompleted: () {
            _handleGardenTutorialCompleted();
          },
          bundle: bundle,
          language: widget.language,
          onLanguageChanged: widget.onLanguageChanged,
        );
      },
    );
  }

  Future<_AppPersistenceBundle> _loadPersistence() async {
    final preferences = await SharedPreferences.getInstance();
    final settingsRepository = SharedPreferencesFocusSettingsRepository(
      preferences,
    );
    final localHistoryRepository = SharedPreferencesFocusHistoryRepository(
      preferences,
    );
    final localGardenRepository = SharedPreferencesGardenRepository(
      preferences,
    );
    final historyRepository = FirebaseFocusHistoryRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
    final gardenRepository = FirebaseGardenRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
    final settings =
        await settingsRepository.loadSettings() ??
        FocusTimerController.defaultSettings;
    final records = await _loadMigratedFocusHistory(
      localRepository: localHistoryRepository,
      firebaseRepository: historyRepository,
    );
    final gardenState = await _loadMigratedGardenState(
      localRepository: localGardenRepository,
      firebaseRepository: gardenRepository,
    );
    final historyController = FocusHistoryController(
      repository: historyRepository,
      initialRecords: records,
    );
    final gardenController = GardenController(
      repository: gardenRepository,
      initialState: gardenState,
    );
    const onboardingCompleted = false;
    _gardenTutorialActive = false;
    _historyController = historyController;
    _gardenController = gardenController;

    return _AppPersistenceBundle(
      preferences: preferences,
      onboardingCompleted: onboardingCompleted,
      settings: settings,
      settingsRepository: settingsRepository,
      historyController: historyController,
      gardenController: gardenController,
    );
  }

  Future<List<FocusSessionRecord>> _loadMigratedFocusHistory({
    required SharedPreferencesFocusHistoryRepository localRepository,
    required FirebaseFocusHistoryRepository firebaseRepository,
  }) async {
    final localRecords = await localRepository.loadRecords();
    final firebaseRecords = await firebaseRepository.loadRecords();
    if (firebaseRecords.isNotEmpty) {
      if (localRecords.isNotEmpty) {
        await localRepository.clearRecords();
      }
      return firebaseRecords;
    }

    if (localRecords.isEmpty) {
      return const [];
    }

    await firebaseRepository.saveRecords(localRecords);
    await localRepository.clearRecords();
    return localRecords;
  }

  Future<GardenState?> _loadMigratedGardenState({
    required SharedPreferencesGardenRepository localRepository,
    required FirebaseGardenRepository firebaseRepository,
  }) async {
    final localState = await localRepository.loadState();
    final firebaseState = await firebaseRepository.loadState();
    if (firebaseState != null) {
      if (localState != null) {
        await localRepository.clearState();
      }
      return firebaseState;
    }

    if (localState == null) {
      return null;
    }

    await firebaseRepository.saveState(localState);
    await localRepository.clearState();
    return localState;
  }

  Future<void> _handleOnboardingFinished(
    String? source,
    int waterReward,
  ) async {
    final bundle = await _persistenceFuture;
    if (source != null) {
      await _saveOnboardingSource(source);
    }
    await bundle.preferences.setBool(_onboardingCompletedKey, true);
    await bundle.preferences.setBool(_gardenTutorialCompletedKey, false);
    bundle.gardenController.addWater(waterReward);

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedTab = AppTab.space;
      _gardenTutorialActive = true;
      _persistenceFuture = Future.value(bundle.copyWithOnboardingCompleted());
    });
  }

  Future<void> _saveOnboardingSource(String source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Could not save onboarding source: no Firebase user.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'onboardingSource': source,
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      debugPrint('Could not save onboarding source: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _handleGardenTutorialCompleted() async {
    final bundle = await _persistenceFuture;
    await bundle.preferences.setBool(_gardenTutorialCompletedKey, true);
    if (!mounted) {
      return;
    }

    setState(() => _gardenTutorialActive = false);
    await _showSaveSpacePromptIfNeeded();
  }

  Future<void> _showSaveSpacePromptIfNeeded() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !user.isAnonymous) {
      return;
    }

    final method = await showCupertinoModalPopup<_SaveSpaceAuthMethod>(
      context: context,
      builder: (context) {
        return _SaveSpaceSheet(
          appleAvailable: _accountAuthService.isAppleSignInAvailable,
        );
      },
    );

    if (method == null) {
      return;
    }

    switch (method) {
      case _SaveSpaceAuthMethod.apple:
        await _secureAccount(_accountAuthService.secureWithApple);
      case _SaveSpaceAuthMethod.google:
        await _secureAccount(_accountAuthService.secureWithGoogle);
    }
  }

  Future<void> _secureAccount(
    Future<AccountAuthResult> Function() secure,
  ) async {
    try {
      final result = await secure();
      final resolvedResult = await _resolveAccountAuthResult(result);
      if (!mounted) {
        return;
      }

      await _showMessage(_successMessage(resolvedResult));
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      await _showMessage(
        _messageForAuthError(error, AppLocalizations.of(context)),
      );
    } on GoogleSignInException catch (error) {
      if (!mounted) {
        return;
      }

      if (error.code != GoogleSignInExceptionCode.canceled) {
        await _showMessage(AppLocalizations.of(context).accountSecureFailed);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      await _showMessage(AppLocalizations.of(context).accountSecureFailed);
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

  String _successMessage(AccountAuthResult result) {
    final l10n = AppLocalizations.of(context);
    return switch (result) {
      ExistingAccountSignedIn() => l10n.existingAccountSignInSuccess,
      _ => l10n.accountSecureSuccess,
    };
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

  Future<void> _showMessage(String message) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

enum _SaveSpaceAuthMethod { apple, google }

class _SaveSpaceSheet extends StatelessWidget {
  const _SaveSpaceSheet({required this.appleAvailable});

  final bool appleAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.graySoft.withValues(alpha: .5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: .12),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.saveYourSpaceTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline.copyWith(
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.saveYourSpaceBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted.copyWith(
                    height: 1.28,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (appleAvailable) ...[
                  _SaveSpaceAuthButton(
                    mark: '',
                    label: l10n.continueWithApple,
                    onTap: () {
                      Navigator.of(context).pop(_SaveSpaceAuthMethod.apple);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                _SaveSpaceAuthButton(
                  mark: 'G',
                  label: l10n.continueWithGoogle,
                  onTap: () {
                    Navigator.of(context).pop(_SaveSpaceAuthMethod.google);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      l10n.notNow,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.grayWarm,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.none,
                      ),
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

class _SaveSpaceAuthButton extends StatefulWidget {
  const _SaveSpaceAuthButton({
    required this.mark,
    required this.label,
    required this.onTap,
  });

  final String mark;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SaveSpaceAuthButton> createState() => _SaveSpaceAuthButtonState();
}

class _SaveSpaceAuthButtonState extends State<_SaveSpaceAuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        scale: _pressed ? .985 : 1,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: .16),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                child: widget.mark == 'G'
                    ? Center(
                        child: Image.asset(
                          AppAssets.googleLogo,
                          width: 18,
                          height: 18,
                        ),
                      )
                    : Text(
                        widget.mark,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.surface,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.surface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
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

class _AppShellContent extends StatelessWidget {
  const _AppShellContent({
    required this.selectedTab,
    required this.onTabSelected,
    required this.onOnboardingFinished,
    required this.gardenTutorialActive,
    required this.onGardenTutorialCompleted,
    required this.bundle,
    required this.language,
    required this.onLanguageChanged,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;
  final Future<void> Function(String? source, int waterReward)
  onOnboardingFinished;
  final bool gardenTutorialActive;
  final VoidCallback onGardenTutorialCompleted;
  final _AppPersistenceBundle bundle;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    if (!bundle.onboardingCompleted) {
      return OnboardingScreen(onFinished: onOnboardingFinished);
    }

    return AppScaffold(
      backgroundColor:
          selectedTab == AppTab.stats || selectedTab == AppTab.settings
          ? const Color(0xFFF5F4FA)
          : AppColors.background,
      horizontalPadding: switch (selectedTab) {
        AppTab.stats => 0,
        AppTab.settings => 0,
        AppTab.space => 0,
        _ => AppSpacing.screenHorizontal,
      },
      bottomNavigation: PatsspaceBottomNavBar(
        selectedTab: selectedTab,
        enabled: !gardenTutorialActive,
        onTabSelected: onTabSelected,
      ),
      child: IndexedStack(
        index: selectedTab.index,
        children: [
          HomeScreen(
            historyController: bundle.historyController,
            gardenController: bundle.gardenController,
            initialSettings: bundle.settings,
            settingsRepository: bundle.settingsRepository,
            onOpenSpace: () => onTabSelected(AppTab.space),
          ),
          SpaceScreen(
            gardenController: bundle.gardenController,
            tutorialActive: gardenTutorialActive,
            onTutorialCompleted: onGardenTutorialCompleted,
          ),
          StatsScreen(historyController: bundle.historyController),
          SettingsScreen(
            language: language,
            onLanguageChanged: onLanguageChanged,
          ),
        ],
      ),
    );
  }
}

class _AppPersistenceBundle {
  const _AppPersistenceBundle({
    required this.preferences,
    required this.onboardingCompleted,
    required this.settings,
    required this.settingsRepository,
    required this.historyController,
    required this.gardenController,
  });

  final SharedPreferences preferences;
  final bool onboardingCompleted;
  final FocusTimerSettings settings;
  final FocusSettingsRepository settingsRepository;
  final FocusHistoryController historyController;
  final GardenController gardenController;

  _AppPersistenceBundle copyWithOnboardingCompleted() {
    return _AppPersistenceBundle(
      preferences: preferences,
      onboardingCompleted: true,
      settings: settings,
      settingsRepository: settingsRepository,
      historyController: historyController,
      gardenController: gardenController,
    );
  }
}
