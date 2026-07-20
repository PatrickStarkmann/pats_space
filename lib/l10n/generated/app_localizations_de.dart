// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get yourProfile => 'Dein Profil';

  @override
  String get editName => 'Name bearbeiten';

  @override
  String get namePlaceholder => 'Dein Name';

  @override
  String get friendCode => 'Freundescode';

  @override
  String get addFriend => 'Freund hinzufügen';

  @override
  String get addFriendSubtitle => 'Code eines Freundes eingeben';

  @override
  String get friendCodePlaceholder => 'A7K9Q2';

  @override
  String get add => 'Hinzufügen';

  @override
  String get accept => 'Annehmen';

  @override
  String get remove => 'Entfernen';

  @override
  String get friendsSettingsSubtitle =>
      'Freunde hinzufügen und Anfragen verwalten';

  @override
  String get incomingRequests => 'Anfragen';

  @override
  String get sentRequests => 'Gesendete Anfragen';

  @override
  String get pending => 'Ausstehend';

  @override
  String get noIncomingRequests => 'Gerade keine Anfragen';

  @override
  String get noSentRequests => 'Keine gesendeten Anfragen';

  @override
  String get cancelRequest => 'Abbrechen';

  @override
  String get removeFriendTitle => 'Freund entfernen?';

  @override
  String removeFriendMessage(Object name) {
    return '$name aus deinen Freunden entfernen?';
  }

  @override
  String get friendRequest => 'Freundschaftsanfrage';

  @override
  String get friendRequestSent => 'Freundschaftsanfrage gesendet.';

  @override
  String get friendAdded => 'Freund hinzugefügt.';

  @override
  String get friendCodeCopied => 'Freundescode kopiert.';

  @override
  String get cannotAddYourself => 'Das ist dein eigener Code.';

  @override
  String get friendCodeNotFound =>
      'Für diesen Code wurde kein Freund gefunden.';

  @override
  String get friendAddFailed =>
      'Freund konnte gerade nicht hinzugefügt werden.';

  @override
  String get loading => 'Lädt...';

  @override
  String get account => 'Account';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get sounds => 'Sounds';

  @override
  String get notifications => 'Mitteilungen';

  @override
  String get on => 'Ein';

  @override
  String get off => 'Aus';

  @override
  String get contactUs => 'Kontakt';

  @override
  String get others => 'Andere';

  @override
  String get alertSounds => 'Hinweistöne';

  @override
  String get alertSoundsDescription =>
      'Töne für Fokus, Pause und Stop abspielen';

  @override
  String get sound => 'Ton';

  @override
  String get softBell => 'Sanfte Glocke';

  @override
  String get notificationsDescription => 'Erinnerungen für Sessions und Pausen';

  @override
  String get focusReminder => 'Fokus-Erinnerung';

  @override
  String get focusReminderDescription => 'Bevor eine geplante Session startet';

  @override
  String get breakReminder => 'Pausen-Erinnerung';

  @override
  String get breakReminderDescription => 'Wenn es Zeit für eine Pause ist';

  @override
  String get signIn => 'Anmelden';

  @override
  String get secureAccount => 'Account sichern';

  @override
  String get secureAccountSubtitle => 'Apple oder Google auswählen';

  @override
  String get accountSecured => 'Account gesichert';

  @override
  String get anonymousAccountSubtitle =>
      'Verknüpfe Apple oder Google, damit Freunde und Fortschritt erhalten bleiben.';

  @override
  String get signedInAccountSubtitle =>
      'Deine Freunde und dein Fortschritt sind gesichert.';

  @override
  String signedInWithProvider(Object provider) {
    return 'Angemeldet mit $provider';
  }

  @override
  String get chooseSignInMethod =>
      'Wähle aus, womit du diesen Account sichern möchtest.';

  @override
  String get continueWithApple => 'Mit Apple fortfahren';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String connectedAccounts(Object providers) {
    return 'Verbunden: $providers';
  }

  @override
  String get connected => 'Verbunden';

  @override
  String get accountSecureSuccess => 'Account gesichert.';

  @override
  String get accountSecureFailed =>
      'Account konnte gerade nicht gesichert werden.';

  @override
  String get existingAccountSignInSuccess => 'Angemeldet.';

  @override
  String get replaceGuestAccountTitle => 'Bestehenden Account nutzen?';

  @override
  String get replaceGuestAccountMessage =>
      'Dieser Apple- oder Google-Account ist bereits vorhanden. Dein aktueller Gaststand auf diesem Gerät wird ersetzt.';

  @override
  String get replaceGuestAccountAction => 'Bestehenden Account nutzen';

  @override
  String get providerAlreadyLinked =>
      'Apple oder Google ist bereits verbunden.';

  @override
  String get accountProviderInUse =>
      'Dieser Apple- oder Google-Account wird schon woanders genutzt.';

  @override
  String get providerNotEnabled =>
      'Diese Anmeldung ist noch nicht fertig eingerichtet.';

  @override
  String get signInCancelled => 'Anmeldung abgebrochen.';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutTitle => 'Abmelden?';

  @override
  String get signOutMessage =>
      'Du nutzt auf diesem Gerät danach einen neuen anonymen Account.';

  @override
  String get signedOutMessage =>
      'Abgemeldet. Du nutzt jetzt einen neuen anonymen Account.';

  @override
  String get deleteAccountTitle => 'Account löschen?';

  @override
  String get deleteAccountMessage =>
      'Profil, Freunde, Anfragen und Freundescode werden gelöscht. Das kann nicht rückgängig gemacht werden.';

  @override
  String get accountDeletedMessage => 'Account gelöscht.';

  @override
  String get accountDeleteFailed =>
      'Account konnte gerade nicht gelöscht werden.';

  @override
  String get accountDeleteNeedsSignIn =>
      'Bitte melde dich erneut an, bevor du den Account löschst.';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get deleteAccount => 'Account löschen';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get version => 'Version';

  @override
  String get appVersion => 'Pat\'s Space 0.1.0';

  @override
  String get timeSettings => 'Zeit-Einstellungen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get done => 'Fertig';

  @override
  String get back => 'Zurück';

  @override
  String get save => 'Speichern';

  @override
  String get focusMode => 'Fokusmodus';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get stopwatch => 'Stoppuhr';

  @override
  String get sessions => 'Sessions';

  @override
  String get longBreakInterval => 'Lange-Pause-Intervall';

  @override
  String get shortBreak => 'Kurze Pause';

  @override
  String get longBreak => 'Lange Pause';

  @override
  String get editTag => 'Tag bearbeiten';

  @override
  String get tagPlaceholder => 'z. B. Mathe';

  @override
  String get animation => 'Animation';

  @override
  String get focus => 'Fokus';

  @override
  String get breakLabel => 'Pause';

  @override
  String get choose => 'Auswählen';

  @override
  String get stopwatchDescription =>
      'Starte eine offene Fokus-Session, wenn du noch nicht weißt, wie lange du brauchst. Pausiere, wenn du weggehst, und beende sie, um die exakte Zeit zu speichern.';

  @override
  String get avgFocusTime => 'Ø Fokuszeit';

  @override
  String get monthlyFocusTime => 'Fokuszeit im Monat';

  @override
  String get focusByTags => 'Fokus nach Tags';

  @override
  String get noFocusData => 'Noch keine Fokusdaten';

  @override
  String get weekdaySun => 'So.';

  @override
  String get weekdayMon => 'Mo.';

  @override
  String get weekdayTue => 'Di.';

  @override
  String get weekdayWed => 'Mi.';

  @override
  String get weekdayThu => 'Do.';

  @override
  String get weekdayFri => 'Fr.';

  @override
  String get weekdaySat => 'Sa.';

  @override
  String get groupFocus => 'Gruppenfokus';

  @override
  String get friendsFocusingNow => 'Freunde fokussieren gerade';

  @override
  String get friends => 'Freunde';

  @override
  String get createOpenRoom => 'Offenen Raum erstellen';

  @override
  String get createOpenRoomSubtitle =>
      'Freunde können beitreten, während du fokussierst';

  @override
  String get noRoomsRightNow => 'Gerade keine Räume';

  @override
  String get noRoomsSubtitle =>
      'Erstelle einen Raum, damit Freunde beitreten können.';

  @override
  String get noFriendsYet => 'Noch keine Freunde';

  @override
  String get noFriendsSubtitle =>
      'Freunde, die du hinzufügst, erscheinen hier.';

  @override
  String get join => 'Beitreten';

  @override
  String get full => 'Voll';

  @override
  String get available => 'Verfügbar';

  @override
  String get online => 'online';

  @override
  String get offline => 'offline';

  @override
  String get focusing => 'fokussiert';

  @override
  String get chooseActivity => 'Aktivität wählen';

  @override
  String get reading => 'lesen';

  @override
  String get studying => 'lernen';

  @override
  String get working => 'arbeiten';

  @override
  String get notStarted => 'nicht gestartet';

  @override
  String get leaveRoom => 'Raum verlassen';

  @override
  String roomTitle(Object name) {
    return '${name}s Raum';
  }

  @override
  String friendsInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Freunde im Raum',
      one: '1 Freund im Raum',
    );
    return '$_temp0';
  }

  @override
  String get startingPomodoro => 'startet einen Pomodoro';

  @override
  String get fullRoom => 'voller Raum';

  @override
  String focusCount(int count) {
    return '$count fokussiert';
  }

  @override
  String breakCount(int count) {
    return '$count Pause';
  }

  @override
  String get shop => 'Shop';

  @override
  String get shopDescription =>
      'Sammle neue Looks und kleine Dinge für deinen Garten.';

  @override
  String get potStyles => 'Topf-Stile';

  @override
  String get decor => 'Deko';

  @override
  String get collected => 'Gesammelt';

  @override
  String get inGarden => 'Im Garten';

  @override
  String get place => 'Platzieren';

  @override
  String get equipped => 'Ausgerüstet';

  @override
  String get use => 'Nutzen';

  @override
  String get locked => 'Gesperrt';

  @override
  String get meadowLockedTitle => 'Ein neuer Space wartet';

  @override
  String meadowLockedMessage(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other:
          'Bringe noch $remaining Pflanzen zum Blühen, um ihn freizuschalten.',
      one: 'Bringe noch 1 Pflanze zum Blühen, um ihn freizuschalten.',
    );
    return '$_temp0';
  }

  @override
  String needItem(Object item) {
    return 'Benötigt $item';
  }

  @override
  String needAmount(int amount) {
    return 'Benötigt $amount';
  }

  @override
  String get leaveGroupFocusTitle => 'Gruppenfokus verlassen?';

  @override
  String get leaveGroupFocusMessage =>
      'Du kannst später wieder einem offenen Raum von Freunden beitreten.';

  @override
  String get stay => 'Bleiben';

  @override
  String get leave => 'Verlassen';

  @override
  String get focusRunningTitle => 'Fokus läuft gerade';

  @override
  String get focusRunningSettingsMessage =>
      'Wenn du die Einstellungen speicherst, wird der aktuelle Fokus abgebrochen.';

  @override
  String get cancelAndSave => 'Abbrechen & speichern';

  @override
  String get cancelFocusTitle => 'Fokus abbrechen?';

  @override
  String get cancelFocusMessage =>
      'Der aktuelle Fokuslauf wird beendet und dein Fortschritt in dieser Runde wird zurückgesetzt.';

  @override
  String get cancelFocus => 'Fokus abbrechen';

  @override
  String get skipFocusTitle => 'Fokus überspringen?';

  @override
  String get skipShortFocusMessage =>
      'Unter 5 Minuten bekommst du kein Wasser und dieser Fokus wird nicht in den Stats gespeichert.';

  @override
  String get skipAnyway => 'Trotzdem überspringen';

  @override
  String get finishStopwatchTitle => 'Stoppuhr beenden?';

  @override
  String get finishShortStopwatchMessage =>
      'Unter 5 Minuten bekommst du kein Wasser und diese Session wird nicht in den Stats gespeichert.';

  @override
  String get finishAnyway => 'Trotzdem beenden';

  @override
  String get keepFocusing => 'Weiter fokussieren';

  @override
  String get wellDone => 'Gut gemacht';

  @override
  String get takeABreath => 'Kurz durchatmen';

  @override
  String get rewardWaterMessage => 'Dein Garten hat jetzt mehr Wasser.';

  @override
  String get noRewardWaterMessage =>
      'Diesmal gibt es kein Wasser, aber du kannst jederzeit neu anfangen.';

  @override
  String waterReward(int amount) {
    return '+$amount Wasser';
  }

  @override
  String get noWater => 'Kein Wasser';

  @override
  String focusedDuration(Object duration) {
    return '$duration fokussiert';
  }

  @override
  String get continueAction => 'Weiter';

  @override
  String get goToSpace => 'Zum Space';

  @override
  String get animations => 'Animationen';

  @override
  String get select => 'Auswählen';

  @override
  String get cleanUpGardenTitle => 'Garten aufräumen?';

  @override
  String get cleanUpGardenMessage =>
      'Platzierte Deko wird zurück ins Inventar gelegt und Töpfe werden an ihre Standardplätze verschoben. Deine Pflanzen bleiben eingepflanzt.';

  @override
  String get cleanUp => 'Aufräumen';

  @override
  String get choosePlant => 'Pflanze wählen';

  @override
  String get feedbackLab => 'Feedback Lab';

  @override
  String get feedbackLabSubtitle => 'Haptik und Button-Feedback testen';

  @override
  String get rawHaptics => 'Direkte Haptik';

  @override
  String get patternHaptics => 'Pattern-Haptik';

  @override
  String get appFeedback => 'App-Feedback';

  @override
  String get selectionHaptic => 'Selection';

  @override
  String get selectionHapticDescription =>
      'Kleiner Tick für Tabs, Picker und Segment-Umschalter';

  @override
  String get lightImpactHaptic => 'Light Impact';

  @override
  String get lightImpactHapticDescription =>
      'Weicher Tap für Play, Pause und normale Buttons';

  @override
  String get mediumImpactHaptic => 'Medium Impact';

  @override
  String get mediumImpactHapticDescription =>
      'Stärkerer Tap für Skip, Abbrechen, Kaufen und Entfernen';

  @override
  String get successHaptic => 'Success';

  @override
  String get successHapticDescription =>
      'Reward, Unlock oder abgeschlossener Fokus';

  @override
  String get warningHaptic => 'Warning';

  @override
  String get warningHapticDescription =>
      'Kein Reward, nicht verfügbar oder blockierte Aktion';

  @override
  String get heavyImpactHaptic => 'Heavy Impact';

  @override
  String get heavyImpactHapticDescription =>
      'Ein einzelner starker System-Impuls';

  @override
  String get rewardPatternHaptic => 'Reward Pattern';

  @override
  String get rewardPatternHapticDescription =>
      'Spritziger Reward für Wasser, Coins oder Fortschritt';

  @override
  String get purchasePatternHaptic => 'Purchase Pattern';

  @override
  String get purchasePatternHapticDescription =>
      'Kurze Bestätigung für Kaufen oder Platzieren';

  @override
  String get unlockPatternHaptic => 'Unlock Pattern';

  @override
  String get unlockPatternHapticDescription =>
      'Größeres Reveal für neue Pflanzen oder Meilensteine';

  @override
  String get errorPatternHaptic => 'Error Pattern';

  @override
  String get errorPatternHapticDescription =>
      'Klares Nein/blockiert ohne lange Vibration';

  @override
  String get primaryButtonFeedback => 'Primary Button';

  @override
  String get iconButtonLightFeedback => 'Icon Button light';

  @override
  String get iconButtonMediumFeedback => 'Icon Button medium';

  @override
  String get monthJan => 'Jan.';

  @override
  String get monthFeb => 'Feb.';

  @override
  String get monthMar => 'März';

  @override
  String get monthApr => 'Apr.';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Juni';

  @override
  String get monthJul => 'Juli';

  @override
  String get monthAug => 'Aug.';

  @override
  String get monthSep => 'Sept.';

  @override
  String get monthOct => 'Okt.';

  @override
  String get monthNov => 'Nov.';

  @override
  String get monthDec => 'Dez.';

  @override
  String get potClassic => 'Klassisch';

  @override
  String get potBlue => 'Blauer Topf';

  @override
  String get potColorful => 'Bunter Topf';

  @override
  String get potHanging => 'Hängender Topf';

  @override
  String get potRound => 'Runder Topf';

  @override
  String get potWhite => 'Weißer Topf';

  @override
  String get decorBench => 'Gartenbank';

  @override
  String get decorFountain => 'Brunnen';

  @override
  String get decorPlantFrame => 'Pflanzenrahmen';

  @override
  String get decorHangingPot => 'Hängender Topf';

  @override
  String get decorLantern => 'Laterne';

  @override
  String get decorStonePath => 'Steinweg';

  @override
  String get decorWateringCan => 'Gießkanne';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei Patsspace';

  @override
  String get onboardingWelcomeBody =>
      'Dein ruhiger Ort für Fokus, Wachstum und gute Gewohnheiten.';

  @override
  String get onboardingPatTitle => 'Hi, ich bin Pat.';

  @override
  String get onboardingPatBody => 'Ich zeige dir kurz alles.';

  @override
  String get onboardingPatAction => 'Hi Pat';

  @override
  String get onboardingFocusEarnGrowTitle => 'Fokussieren, sammeln, wachsen';

  @override
  String get onboardingFocusEarnGrowBody =>
      'Bleib fokussiert, sammle Waterdrops und lass damit Pflanzen in deinem Space wachsen.';

  @override
  String get onboardingStepFocusTitle => '1. Fokussieren';

  @override
  String get onboardingStepFocusBody => 'Du fokussierst dich mit Absicht.';

  @override
  String get onboardingStepEarnTitle => '2. Sammeln';

  @override
  String get onboardingStepEarnBody => 'Du bekommst Waterdrops.';

  @override
  String get onboardingStepGrowTitle => '3. Wachsen';

  @override
  String get onboardingStepGrowBody =>
      'Deine Pflanze wächst, wenn du dranbleibst.';

  @override
  String get onboardingSourceEyebrow => 'Eine kurze Frage';

  @override
  String get onboardingSourceTitle => 'Wo hast du zuerst von Patsspace gehört?';

  @override
  String get onboardingSourceBody =>
      'Das hilft uns zu verstehen, was funktioniert.';

  @override
  String get onboardingSourceAlmostThere => 'Fast geschafft!';

  @override
  String get onboardingSourceTikTok => 'TikTok';

  @override
  String get onboardingSourceInstagram => 'Instagram';

  @override
  String get onboardingSourceYouTube => 'YouTube';

  @override
  String get onboardingSourceAppStore => 'App Store';

  @override
  String get onboardingSourceFriend => 'Freund';

  @override
  String get onboardingSourceSearch => 'Suche';

  @override
  String get onboardingSourceOther => 'Andere';

  @override
  String get onboardingStartSmallTitle => 'Fangen wir klein an';

  @override
  String get onboardingStartSmallBody =>
      'Mach eine 30-Sekunden-Fokus-Challenge mit mir.';

  @override
  String get onboardingStartChallenge => 'Challenge starten';

  @override
  String get onboardingChallengeNiceWorkTitle => 'Gut gemacht!';

  @override
  String get onboardingChallengeNiceWorkBody =>
      'Du hast deine erste Fokus-Challenge abgeschlossen.';

  @override
  String get onboardingChallengeAlmostThereTitle => 'Fast geschafft';

  @override
  String get onboardingChallengeAlmostThereBody =>
      'Bleib dran. Gleich ist es geschafft.';

  @override
  String get onboardingChallengeStayTitle => 'Bleib dabei';

  @override
  String get onboardingChallengeStayBody => 'Du machst das gut.';

  @override
  String get onboardingChallengeReadyTitle => 'Bereit, wenn du es bist';

  @override
  String get onboardingChallengeReadyBody =>
      'Tippe auf Start und bleib mit Pat dabei, bis der Timer endet.';

  @override
  String get onboardingChallengeOpeningGarden => 'Garten wird geöffnet...';

  @override
  String get onboardingChallengePlantFirstSeed => 'Pflanz deinen ersten Seed';

  @override
  String get onboardingChallengeStayFocused => 'Fokussiert bleiben';

  @override
  String get onboardingChallengeStart => 'Start';

  @override
  String get saveYourSpaceTitle => 'Sichere deinen Space';

  @override
  String get saveYourSpaceBody =>
      'Bewahre deine Pflanzen, Waterdrops und Fokus-Historie sicher auf allen Geräten.';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get gardenTutorialPickHomeTitle => 'Wähl einen Topf';

  @override
  String get gardenTutorialPickHomeBody => 'Tippe auf den leuchtenden Topf.';

  @override
  String get gardenTutorialPlantDaisyTitle => 'Pflanz deinen Seed';

  @override
  String get gardenTutorialPlantDaisyBody =>
      'Daisy ist bereit. Pflanz sie hier.';

  @override
  String get gardenTutorialGiveWaterTitle => 'Gieß sie';

  @override
  String get gardenTutorialGiveWaterBody =>
      'Tippe auf den Drop, bis sie sprießt.';

  @override
  String get gardenTutorialSpaceGrowingTitle => 'Sie sprießt';

  @override
  String get gardenTutorialSpaceGrowingBody => 'Dein Space wächst.';
}
