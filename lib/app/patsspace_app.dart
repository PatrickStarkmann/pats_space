import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pats_space/app/navigation/app_shell.dart';
import 'package:pats_space/core/theme/app_theme.dart';
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
  late final Future<SharedPreferences> _preferencesFuture;
  late final FirebasePresenceRepository _presenceRepository;
  SharedPreferencesAppLanguageRepository? _languageRepository;
  AppLanguage _language = AppLanguage.system;

  @override
  void initState() {
    super.initState();
    _presenceRepository = FirebasePresenceRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    )..start();
    _preferencesFuture = _loadPreferences();
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
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          return AppShell(
            language: _language,
            onLanguageChanged: _handleLanguageChanged,
          );
        },
      ),
    );
  }

  void _handleLanguageChanged(AppLanguage language) {
    setState(() => _language = language);
    _languageRepository?.saveLanguage(language);
  }
}
