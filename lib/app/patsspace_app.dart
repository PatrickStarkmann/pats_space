import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/app/navigation/app_shell.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/core/theme/app_theme.dart';
import 'package:pats_space/core/widgets/app_loading_screen.dart';
import 'package:pats_space/features/settings/models/app_language.dart';
import 'package:pats_space/features/settings/repositories/shared_preferences_app_language_repository.dart';
import 'package:pats_space/features/social_focus/repositories/firebase_presence_repository.dart';
import 'package:pats_space/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatsspaceApp extends StatefulWidget {
  const PatsspaceApp({super.key});

  @override
  State<PatsspaceApp> createState() => _PatsspaceAppState();
}

class _PatsspaceAppState extends State<PatsspaceApp> {
  static const _minimumIntroDuration = Duration(milliseconds: 2200);
  static const _appShellMountDelay = Duration(milliseconds: 950);

  late final Future<SharedPreferences> _preferencesFuture;
  late final FirebasePresenceRepository _presenceRepository;
  SharedPreferencesAppLanguageRepository? _languageRepository;
  AppLanguage _language = AppLanguage.system;
  bool _canMountAppShell = false;
  bool _minimumIntroElapsed = false;
  bool _initialAppShellReady = false;

  @override
  void initState() {
    super.initState();
    _presenceRepository = FirebasePresenceRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    )..start();
    _preferencesFuture = _loadPreferences();
    Future<void>.delayed(_minimumIntroDuration, () {
      if (!mounted) {
        return;
      }
      setState(() => _minimumIntroElapsed = true);
    });
    Future<void>.delayed(_appShellMountDelay, () {
      if (!mounted) {
        return;
      }
      setState(() => _canMountAppShell = true);
    });
  }

  @override
  void dispose() {
    _presenceRepository.dispose();
    super.dispose();
  }

  Future<SharedPreferences> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesAppLanguageRepository(preferences);
    final language = await repository.loadLanguage();
    if (mounted) {
      setState(() {
        _languageRepository = repository;
        _language = language;
      });
    }
    return preferences;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patsspace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: _language.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FutureBuilder<SharedPreferences>(
        future: _preferencesFuture,
        builder: (context, snapshot) {
          final canBuildAppShell = snapshot.hasData && _canMountAppShell;
          final appReady = _minimumIntroElapsed && _initialAppShellReady;
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.background),
              if (canBuildAppShell)
                AppShell(
                  language: _language,
                  onLanguageChanged: _handleLanguageChanged,
                  showInitialLoadingScreen: false,
                  onInitialPersistenceLoaded: _handleInitialAppShellReady,
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: _overlaySwitcherLayout,
                transitionBuilder: _fadeTransition,
                child: appReady
                    ? const SizedBox.shrink(key: ValueKey('intro-complete'))
                    : const AppLoadingScreen(key: ValueKey('app-intro')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleInitialAppShellReady() {
    if (_initialAppShellReady) {
      return;
    }
    setState(() => _initialAppShellReady = true);
  }

  void _handleLanguageChanged(AppLanguage language) {
    setState(() => _language = language);
    _languageRepository?.saveLanguage(language);
  }

  Widget _overlaySwitcherLayout(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [...previousChildren, ?currentChild],
    );
  }

  Widget _fadeTransition(Widget child, Animation<double> animation) {
    return FadeTransition(opacity: animation, child: child);
  }
}
