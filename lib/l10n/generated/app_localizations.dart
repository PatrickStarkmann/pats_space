import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get yourProfile;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get namePlaceholder;

  /// No description provided for @friendCode.
  ///
  /// In en, this message translates to:
  /// **'Friend code'**
  String get friendCode;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get addFriend;

  /// No description provided for @addFriendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a friend\'s code'**
  String get addFriendSubtitle;

  /// No description provided for @friendCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'A7K9Q2'**
  String get friendCodePlaceholder;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @friendsSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add friends and manage requests'**
  String get friendsSettingsSubtitle;

  /// No description provided for @incomingRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get incomingRequests;

  /// No description provided for @sentRequests.
  ///
  /// In en, this message translates to:
  /// **'Sent requests'**
  String get sentRequests;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @noIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests right now'**
  String get noIncomingRequests;

  /// No description provided for @noSentRequests.
  ///
  /// In en, this message translates to:
  /// **'No sent requests'**
  String get noSentRequests;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelRequest;

  /// No description provided for @removeFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove friend?'**
  String get removeFriendTitle;

  /// No description provided for @removeFriendMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your friends?'**
  String removeFriendMessage(Object name);

  /// No description provided for @friendRequest.
  ///
  /// In en, this message translates to:
  /// **'Friend request'**
  String get friendRequest;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent.'**
  String get friendRequestSent;

  /// No description provided for @friendAdded.
  ///
  /// In en, this message translates to:
  /// **'Friend added.'**
  String get friendAdded;

  /// No description provided for @friendCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Friend code copied.'**
  String get friendCodeCopied;

  /// No description provided for @cannotAddYourself.
  ///
  /// In en, this message translates to:
  /// **'This is your own code.'**
  String get cannotAddYourself;

  /// No description provided for @friendCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No friend found for this code.'**
  String get friendCodeNotFound;

  /// No description provided for @friendAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add friend right now.'**
  String get friendAddFailed;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @weekStartDay.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStartDay;

  /// No description provided for @weekStartMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekStartMonday;

  /// No description provided for @weekStartSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekStartSunday;

  /// No description provided for @sounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get sounds;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @alertSounds.
  ///
  /// In en, this message translates to:
  /// **'Alert sounds'**
  String get alertSounds;

  /// No description provided for @alertSoundsDescription.
  ///
  /// In en, this message translates to:
  /// **'Play sounds for focus, break and stop'**
  String get alertSoundsDescription;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @softBell.
  ///
  /// In en, this message translates to:
  /// **'Soft bell'**
  String get softBell;

  /// No description provided for @ambientSounds.
  ///
  /// In en, this message translates to:
  /// **'Background sounds'**
  String get ambientSounds;

  /// No description provided for @ambientSoundsDescription.
  ///
  /// In en, this message translates to:
  /// **'Play a calming sound while your focus timer is running'**
  String get ambientSoundsDescription;

  /// No description provided for @noAmbientSound.
  ///
  /// In en, this message translates to:
  /// **'No background sound'**
  String get noAmbientSound;

  /// No description provided for @firewood.
  ///
  /// In en, this message translates to:
  /// **'Fireplace'**
  String get firewood;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rain;

  /// No description provided for @rainforest.
  ///
  /// In en, this message translates to:
  /// **'Rainforest'**
  String get rainforest;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @timerSignals.
  ///
  /// In en, this message translates to:
  /// **'Timer signals'**
  String get timerSignals;

  /// No description provided for @timerSignalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Bell at focus and break endings, finish sound after a full round'**
  String get timerSignalsDescription;

  /// No description provided for @holdForSoundSelection.
  ///
  /// In en, this message translates to:
  /// **'Press and hold the sound button to choose a different sound'**
  String get holdForSoundSelection;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Session reminders and break alerts'**
  String get notificationsDescription;

  /// No description provided for @timerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Timer notifications'**
  String get timerNotifications;

  /// No description provided for @timerNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notify me when a running focus or break ends'**
  String get timerNotificationsDescription;

  /// No description provided for @focusEndNotification.
  ///
  /// In en, this message translates to:
  /// **'Focus completed'**
  String get focusEndNotification;

  /// No description provided for @focusEndNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'When it is time to take a break'**
  String get focusEndNotificationDescription;

  /// No description provided for @breakEndNotification.
  ///
  /// In en, this message translates to:
  /// **'Break completed'**
  String get breakEndNotification;

  /// No description provided for @breakEndNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'When it is time to focus again'**
  String get breakEndNotificationDescription;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled in the system settings.'**
  String get notificationPermissionDenied;

  /// No description provided for @focusFinishedNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus complete'**
  String get focusFinishedNotificationTitle;

  /// No description provided for @focusFinishedNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Time for a well-earned break.'**
  String get focusFinishedNotificationBody;

  /// No description provided for @breakFinishedNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Break complete'**
  String get breakFinishedNotificationTitle;

  /// No description provided for @breakFinishedNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Ready for the next focus session?'**
  String get breakFinishedNotificationBody;

  /// No description provided for @roundFinishedNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Round complete'**
  String get roundFinishedNotificationTitle;

  /// No description provided for @roundFinishedNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Great work — your focus round is finished.'**
  String get roundFinishedNotificationBody;

  /// No description provided for @focusReminder.
  ///
  /// In en, this message translates to:
  /// **'Focus reminder'**
  String get focusReminder;

  /// No description provided for @focusReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Before a planned session starts'**
  String get focusReminderDescription;

  /// No description provided for @breakReminder.
  ///
  /// In en, this message translates to:
  /// **'Break reminder'**
  String get breakReminder;

  /// No description provided for @breakReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'When it is time to rest'**
  String get breakReminderDescription;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @secureAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure account'**
  String get secureAccount;

  /// No description provided for @secureAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Apple or Google'**
  String get secureAccountSubtitle;

  /// No description provided for @accountSecured.
  ///
  /// In en, this message translates to:
  /// **'Account secured'**
  String get accountSecured;

  /// No description provided for @anonymousAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link Apple or Google so your friends and progress stay safe.'**
  String get anonymousAccountSubtitle;

  /// No description provided for @signedInAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your friends and progress are saved.'**
  String get signedInAccountSubtitle;

  /// No description provided for @signedInWithProvider.
  ///
  /// In en, this message translates to:
  /// **'Signed in with {provider}'**
  String signedInWithProvider(Object provider);

  /// No description provided for @chooseSignInMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to secure this account.'**
  String get chooseSignInMethod;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @connectedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Connected: {providers}'**
  String connectedAccounts(Object providers);

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @accountSecureSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account secured.'**
  String get accountSecureSuccess;

  /// No description provided for @accountSecureFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not secure your account right now.'**
  String get accountSecureFailed;

  /// No description provided for @existingAccountSignInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed in.'**
  String get existingAccountSignInSuccess;

  /// No description provided for @replaceGuestAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Use existing account?'**
  String get replaceGuestAccountTitle;

  /// No description provided for @replaceGuestAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This Apple or Google account already exists. Your current guest progress on this device will be replaced.'**
  String get replaceGuestAccountMessage;

  /// No description provided for @replaceGuestAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Use existing account'**
  String get replaceGuestAccountAction;

  /// No description provided for @providerAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'Apple or Google is already connected.'**
  String get providerAlreadyLinked;

  /// No description provided for @accountProviderInUse.
  ///
  /// In en, this message translates to:
  /// **'This Apple or Google account is already used somewhere else.'**
  String get accountProviderInUse;

  /// No description provided for @providerNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'This sign-in option is not ready yet.'**
  String get providerNotEnabled;

  /// No description provided for @signInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get signInCancelled;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will continue with a new anonymous account on this device.'**
  String get signOutMessage;

  /// No description provided for @signedOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Signed out. You are now using a new anonymous account.'**
  String get signedOutMessage;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes your profile, friends, requests and friend code. This cannot be undone.'**
  String get deleteAccountMessage;

  /// No description provided for @accountDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeletedMessage;

  /// No description provided for @accountDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account right now.'**
  String get accountDeleteFailed;

  /// No description provided for @accountDeleteNeedsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again before deleting your account.'**
  String get accountDeleteNeedsSignIn;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Pat\'s Space 0.1.0'**
  String get appVersion;

  /// No description provided for @timeSettings.
  ///
  /// In en, this message translates to:
  /// **'Time Settings'**
  String get timeSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @focusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusMode;

  /// No description provided for @deepFocus.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus'**
  String get deepFocus;

  /// No description provided for @deepFocusDescription.
  ///
  /// In en, this message translates to:
  /// **'Block selected distractions during this session'**
  String get deepFocusDescription;

  /// No description provided for @deepFocusSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the apps, categories, and websites that should stay out of reach while you focus. Your selection remains private on this device.'**
  String get deepFocusSettingsDescription;

  /// No description provided for @deepFocusReadyDescription.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String deepFocusReadyDescription(int count);

  /// No description provided for @deepFocusActive.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus active'**
  String get deepFocusActive;

  /// No description provided for @deepFocusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get deepFocusUnavailable;

  /// No description provided for @deepFocusNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get deepFocusNotSetUp;

  /// No description provided for @deepFocusPermission.
  ///
  /// In en, this message translates to:
  /// **'Screen Time access'**
  String get deepFocusPermission;

  /// No description provided for @deepFocusPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Access granted'**
  String get deepFocusPermissionGranted;

  /// No description provided for @deepFocusPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Permission needed'**
  String get deepFocusPermissionNeeded;

  /// No description provided for @deepFocusPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get deepFocusPermissionDenied;

  /// No description provided for @deepFocusBlockedApps.
  ///
  /// In en, this message translates to:
  /// **'Blocked distractions'**
  String get deepFocusBlockedApps;

  /// No description provided for @deepFocusNoAppsSelected.
  ///
  /// In en, this message translates to:
  /// **'No apps selected yet'**
  String get deepFocusNoAppsSelected;

  /// No description provided for @deepFocusChooseApps.
  ///
  /// In en, this message translates to:
  /// **'Choose distractions'**
  String get deepFocusChooseApps;

  /// No description provided for @deepFocusSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up Deep Focus'**
  String get deepFocusSetUp;

  /// No description provided for @deepFocusAndroidLater.
  ///
  /// In en, this message translates to:
  /// **'Android support is prepared and will be added later.'**
  String get deepFocusAndroidLater;

  /// No description provided for @deepFocusSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus could not be set up. Please try again.'**
  String get deepFocusSetupFailed;

  /// No description provided for @deepFocusCouldNotStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus could not start'**
  String get deepFocusCouldNotStartTitle;

  /// No description provided for @deepFocusCouldNotStartMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your Screen Time permission and selected apps, or start this session without blocking.'**
  String get deepFocusCouldNotStartMessage;

  /// No description provided for @startWithoutDeepFocus.
  ///
  /// In en, this message translates to:
  /// **'Start without blocking'**
  String get startWithoutDeepFocus;

  /// No description provided for @pomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get pomodoro;

  /// No description provided for @stopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get stopwatch;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @longBreakInterval.
  ///
  /// In en, this message translates to:
  /// **'Long Break Interval'**
  String get longBreakInterval;

  /// No description provided for @shortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get shortBreak;

  /// No description provided for @longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get longBreak;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit tag'**
  String get editTag;

  /// No description provided for @tagPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Math'**
  String get tagPlaceholder;

  /// No description provided for @animation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get animation;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @breakLabel.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakLabel;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @stopwatchDescription.
  ///
  /// In en, this message translates to:
  /// **'Start an open-ended focus session when you do not know how long you need. Pause when you step away, then finish to save the exact time.'**
  String get stopwatchDescription;

  /// No description provided for @avgFocusTime.
  ///
  /// In en, this message translates to:
  /// **'Avg Focus Time'**
  String get avgFocusTime;

  /// No description provided for @monthlyFocusTime.
  ///
  /// In en, this message translates to:
  /// **'Monthly Focus Time'**
  String get monthlyFocusTime;

  /// No description provided for @focusByTags.
  ///
  /// In en, this message translates to:
  /// **'Focus by Tags'**
  String get focusByTags;

  /// No description provided for @noFocusData.
  ///
  /// In en, this message translates to:
  /// **'No focus data yet'**
  String get noFocusData;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @groupFocus.
  ///
  /// In en, this message translates to:
  /// **'Group Focus'**
  String get groupFocus;

  /// No description provided for @friendsFocusingNow.
  ///
  /// In en, this message translates to:
  /// **'Friends focusing now'**
  String get friendsFocusingNow;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @createOpenRoom.
  ///
  /// In en, this message translates to:
  /// **'Create open room'**
  String get createOpenRoom;

  /// No description provided for @createOpenRoomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Friends can join while you focus'**
  String get createOpenRoomSubtitle;

  /// No description provided for @noRoomsRightNow.
  ///
  /// In en, this message translates to:
  /// **'No rooms right now'**
  String get noRoomsRightNow;

  /// No description provided for @noRoomsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a room so friends can join you.'**
  String get noRoomsSubtitle;

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// No description provided for @noFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Friends you add will appear here.'**
  String get noFriendsSubtitle;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get offline;

  /// No description provided for @connectionOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Offline. Some actions are unavailable.'**
  String get connectionOfflineMessage;

  /// No description provided for @connectionOnlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Back online.'**
  String get connectionOnlineMessage;

  /// No description provided for @settingsOnlineRequired.
  ///
  /// In en, this message translates to:
  /// **'Reconnect to use this action.'**
  String get settingsOnlineRequired;

  /// No description provided for @focusing.
  ///
  /// In en, this message translates to:
  /// **'focusing'**
  String get focusing;

  /// No description provided for @chooseActivity.
  ///
  /// In en, this message translates to:
  /// **'Choose activity'**
  String get chooseActivity;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'reading'**
  String get reading;

  /// No description provided for @studying.
  ///
  /// In en, this message translates to:
  /// **'studying'**
  String get studying;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'working'**
  String get working;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'not started'**
  String get notStarted;

  /// No description provided for @leaveRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave Room'**
  String get leaveRoom;

  /// No description provided for @roomTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s room'**
  String roomTitle(Object name);

  /// No description provided for @friendsInRoom.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 friend in room} other{{count} friends in room}}'**
  String friendsInRoom(int count);

  /// No description provided for @startingPomodoro.
  ///
  /// In en, this message translates to:
  /// **'starting a pomodoro'**
  String get startingPomodoro;

  /// No description provided for @fullRoom.
  ///
  /// In en, this message translates to:
  /// **'full room'**
  String get fullRoom;

  /// No description provided for @focusCount.
  ///
  /// In en, this message translates to:
  /// **'{count} focusing'**
  String focusCount(int count);

  /// No description provided for @breakCount.
  ///
  /// In en, this message translates to:
  /// **'{count} break'**
  String breakCount(int count);

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @shopDescription.
  ///
  /// In en, this message translates to:
  /// **'Collect new looks and little pieces for your garden.'**
  String get shopDescription;

  /// No description provided for @potStyles.
  ///
  /// In en, this message translates to:
  /// **'Pot styles'**
  String get potStyles;

  /// No description provided for @decor.
  ///
  /// In en, this message translates to:
  /// **'Decor'**
  String get decor;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @inGarden.
  ///
  /// In en, this message translates to:
  /// **'In garden'**
  String get inGarden;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get place;

  /// No description provided for @equipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get equipped;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @gardenOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden is offline'**
  String get gardenOfflineTitle;

  /// No description provided for @gardenOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Reconnect to use the garden and shop.'**
  String get gardenOfflineMessage;

  /// No description provided for @meadowLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'A new space is waiting'**
  String get meadowLockedTitle;

  /// No description provided for @meadowLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'{remaining, plural, =1{Bloom 1 more plant to unlock it.} other{Bloom {remaining} more plants to unlock it.}}'**
  String meadowLockedMessage(int remaining);

  /// No description provided for @needItem.
  ///
  /// In en, this message translates to:
  /// **'Need {item}'**
  String needItem(Object item);

  /// No description provided for @needAmount.
  ///
  /// In en, this message translates to:
  /// **'Need {amount}'**
  String needAmount(int amount);

  /// No description provided for @leaveGroupFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave group focus?'**
  String get leaveGroupFocusTitle;

  /// No description provided for @leaveGroupFocusMessage.
  ///
  /// In en, this message translates to:
  /// **'You can rejoin an open friend room from the group lobby later.'**
  String get leaveGroupFocusMessage;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @focusRunningTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus is running'**
  String get focusRunningTitle;

  /// No description provided for @focusRunningSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'If you save the settings, the current focus will be cancelled.'**
  String get focusRunningSettingsMessage;

  /// No description provided for @cancelAndSave.
  ///
  /// In en, this message translates to:
  /// **'Cancel & save'**
  String get cancelAndSave;

  /// No description provided for @cancelFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel focus?'**
  String get cancelFocusTitle;

  /// No description provided for @cancelFocusMessage.
  ///
  /// In en, this message translates to:
  /// **'The current focus run will end and your progress in this round will be reset.'**
  String get cancelFocusMessage;

  /// No description provided for @cancelFocus.
  ///
  /// In en, this message translates to:
  /// **'Cancel focus'**
  String get cancelFocus;

  /// No description provided for @skipFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip focus?'**
  String get skipFocusTitle;

  /// No description provided for @skipShortFocusMessage.
  ///
  /// In en, this message translates to:
  /// **'Under 5 minutes you do not get water and this focus will not be saved in your stats.'**
  String get skipShortFocusMessage;

  /// No description provided for @skipAnyway.
  ///
  /// In en, this message translates to:
  /// **'Skip anyway'**
  String get skipAnyway;

  /// No description provided for @finishStopwatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish stopwatch?'**
  String get finishStopwatchTitle;

  /// No description provided for @finishShortStopwatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Under 5 minutes you do not get water and this session will not be saved in your stats.'**
  String get finishShortStopwatchMessage;

  /// No description provided for @finishAnyway.
  ///
  /// In en, this message translates to:
  /// **'Finish anyway'**
  String get finishAnyway;

  /// No description provided for @keepFocusing.
  ///
  /// In en, this message translates to:
  /// **'Keep focusing'**
  String get keepFocusing;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done'**
  String get wellDone;

  /// No description provided for @takeABreath.
  ///
  /// In en, this message translates to:
  /// **'Take a breath'**
  String get takeABreath;

  /// No description provided for @rewardWaterMessage.
  ///
  /// In en, this message translates to:
  /// **'Your garden has more water now.'**
  String get rewardWaterMessage;

  /// No description provided for @noRewardWaterMessage.
  ///
  /// In en, this message translates to:
  /// **'No water this time, but you can always begin again.'**
  String get noRewardWaterMessage;

  /// No description provided for @waterReward.
  ///
  /// In en, this message translates to:
  /// **'+{amount} water'**
  String waterReward(int amount);

  /// No description provided for @noWater.
  ///
  /// In en, this message translates to:
  /// **'No water'**
  String get noWater;

  /// No description provided for @focusedDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} focused'**
  String focusedDuration(Object duration);

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @autoContinue.
  ///
  /// In en, this message translates to:
  /// **'Auto continue'**
  String get autoContinue;

  /// No description provided for @autoContinueDescription.
  ///
  /// In en, this message translates to:
  /// **'Start the next focus or break automatically'**
  String get autoContinueDescription;

  /// No description provided for @goToSpace.
  ///
  /// In en, this message translates to:
  /// **'Go to Space'**
  String get goToSpace;

  /// No description provided for @animations.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animations;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @cleanUpGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Clean up garden?'**
  String get cleanUpGardenTitle;

  /// No description provided for @cleanUpGardenMessage.
  ///
  /// In en, this message translates to:
  /// **'This stores placed decor back in your inventory and moves pots to their default spots. Your plants stay planted.'**
  String get cleanUpGardenMessage;

  /// No description provided for @cleanUp.
  ///
  /// In en, this message translates to:
  /// **'Clean up'**
  String get cleanUp;

  /// No description provided for @choosePlant.
  ///
  /// In en, this message translates to:
  /// **'Choose plant'**
  String get choosePlant;

  /// No description provided for @mysteryPlant.
  ///
  /// In en, this message translates to:
  /// **'Mystery plant'**
  String get mysteryPlant;

  /// No description provided for @plantDaisy.
  ///
  /// In en, this message translates to:
  /// **'Daisy'**
  String get plantDaisy;

  /// No description provided for @plantTulip.
  ///
  /// In en, this message translates to:
  /// **'Tulip'**
  String get plantTulip;

  /// No description provided for @plantClover.
  ///
  /// In en, this message translates to:
  /// **'Clover'**
  String get plantClover;

  /// No description provided for @plantSunflower.
  ///
  /// In en, this message translates to:
  /// **'Sunflower'**
  String get plantSunflower;

  /// No description provided for @plantHangingFlower.
  ///
  /// In en, this message translates to:
  /// **'Hanging flower'**
  String get plantHangingFlower;

  /// No description provided for @plantUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get plantUnlocked;

  /// No description provided for @plantBloomRequirement.
  ///
  /// In en, this message translates to:
  /// **'Bloom {plant}'**
  String plantBloomRequirement(Object plant);

  /// No description provided for @plantSpecialStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get plantSpecialStarter;

  /// No description provided for @plantSpecialBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get plantSpecialBonus;

  /// No description provided for @plantSpecialLucky.
  ///
  /// In en, this message translates to:
  /// **'Lucky'**
  String get plantSpecialLucky;

  /// No description provided for @plantSpecialJackpot.
  ///
  /// In en, this message translates to:
  /// **'Jackpot'**
  String get plantSpecialJackpot;

  /// No description provided for @plantSpecialHanging.
  ///
  /// In en, this message translates to:
  /// **'Hanging'**
  String get plantSpecialHanging;

  /// No description provided for @plantDescriptionBonus.
  ///
  /// In en, this message translates to:
  /// **'More coins, slower drops'**
  String get plantDescriptionBonus;

  /// No description provided for @plantDescriptionLucky.
  ///
  /// In en, this message translates to:
  /// **'20% chance for double coins'**
  String get plantDescriptionLucky;

  /// No description provided for @plantDescriptionJackpot.
  ///
  /// In en, this message translates to:
  /// **'Biggest payout, slowest drop'**
  String get plantDescriptionJackpot;

  /// No description provided for @plantDescriptionHanging.
  ///
  /// In en, this message translates to:
  /// **'Only grows in hanging pots'**
  String get plantDescriptionHanging;

  /// No description provided for @potSkin.
  ///
  /// In en, this message translates to:
  /// **'Pot skin'**
  String get potSkin;

  /// No description provided for @plantAction.
  ///
  /// In en, this message translates to:
  /// **'Plant {plant}'**
  String plantAction(Object plant);

  /// No description provided for @plantActionWithCost.
  ///
  /// In en, this message translates to:
  /// **'Plant {plant} · {cost} water'**
  String plantActionWithCost(Object cost, Object plant);

  /// No description provided for @plantNeedWater.
  ///
  /// In en, this message translates to:
  /// **'Need {cost} water'**
  String plantNeedWater(Object cost);

  /// No description provided for @plantLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get plantLocked;

  /// No description provided for @readyToHarvest.
  ///
  /// In en, this message translates to:
  /// **'Ready to harvest · {count} harvests left'**
  String readyToHarvest(Object count);

  /// No description provided for @nextDropIn.
  ///
  /// In en, this message translates to:
  /// **'Next drop in {time}'**
  String nextDropIn(Object time);

  /// No description provided for @needsWaterToRecover.
  ///
  /// In en, this message translates to:
  /// **'Needs water to recover'**
  String get needsWaterToRecover;

  /// No description provided for @waterToGrow.
  ///
  /// In en, this message translates to:
  /// **'Water to grow'**
  String get waterToGrow;

  /// No description provided for @collect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get collect;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @recoveryProgress.
  ///
  /// In en, this message translates to:
  /// **'Recovery progress'**
  String get recoveryProgress;

  /// No description provided for @growthProgress.
  ///
  /// In en, this message translates to:
  /// **'Growth progress'**
  String get growthProgress;

  /// No description provided for @coinsEvery.
  ///
  /// In en, this message translates to:
  /// **'+{coins} every {interval}'**
  String coinsEvery(Object coins, Object interval);

  /// No description provided for @removePlant.
  ///
  /// In en, this message translates to:
  /// **'Remove plant'**
  String get removePlant;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'soon'**
  String get soon;

  /// No description provided for @hoursMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String hoursMinutesShort(Object hours, Object minutes);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String minutesShort(Object minutes);

  /// No description provided for @growthStageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty pot'**
  String get growthStageEmpty;

  /// No description provided for @growthStageSeed.
  ///
  /// In en, this message translates to:
  /// **'Seed planted'**
  String get growthStageSeed;

  /// No description provided for @growthStageSprout.
  ///
  /// In en, this message translates to:
  /// **'Needs water'**
  String get growthStageSprout;

  /// No description provided for @growthStageBud.
  ///
  /// In en, this message translates to:
  /// **'Growing'**
  String get growthStageBud;

  /// No description provided for @growthStageBloom.
  ///
  /// In en, this message translates to:
  /// **'Blooming'**
  String get growthStageBloom;

  /// No description provided for @growthStageDry.
  ///
  /// In en, this message translates to:
  /// **'Dried out'**
  String get growthStageDry;

  /// No description provided for @feedbackLab.
  ///
  /// In en, this message translates to:
  /// **'Feedback Lab'**
  String get feedbackLab;

  /// No description provided for @feedbackLabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try haptics and button feedback'**
  String get feedbackLabSubtitle;

  /// No description provided for @rawHaptics.
  ///
  /// In en, this message translates to:
  /// **'Raw haptics'**
  String get rawHaptics;

  /// No description provided for @patternHaptics.
  ///
  /// In en, this message translates to:
  /// **'Pattern haptics'**
  String get patternHaptics;

  /// No description provided for @appFeedback.
  ///
  /// In en, this message translates to:
  /// **'App feedback'**
  String get appFeedback;

  /// No description provided for @selectionHaptic.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get selectionHaptic;

  /// No description provided for @selectionHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'Tiny tick for tabs, pickers and segmented controls'**
  String get selectionHapticDescription;

  /// No description provided for @lightImpactHaptic.
  ///
  /// In en, this message translates to:
  /// **'Light impact'**
  String get lightImpactHaptic;

  /// No description provided for @lightImpactHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'Soft tap for play, pause and normal buttons'**
  String get lightImpactHapticDescription;

  /// No description provided for @mediumImpactHaptic.
  ///
  /// In en, this message translates to:
  /// **'Medium impact'**
  String get mediumImpactHaptic;

  /// No description provided for @mediumImpactHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'Stronger tap for skip, cancel, buy and remove'**
  String get mediumImpactHapticDescription;

  /// No description provided for @successHaptic.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successHaptic;

  /// No description provided for @successHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'Reward, unlock or completed focus'**
  String get successHapticDescription;

  /// No description provided for @warningHaptic.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningHaptic;

  /// No description provided for @warningHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'No reward, unavailable or blocked action'**
  String get warningHapticDescription;

  /// No description provided for @heavyImpactHaptic.
  ///
  /// In en, this message translates to:
  /// **'Heavy impact'**
  String get heavyImpactHaptic;

  /// No description provided for @heavyImpactHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'Single strong system impact'**
  String get heavyImpactHapticDescription;

  /// No description provided for @rewardPatternHaptic.
  ///
  /// In en, this message translates to:
  /// **'Reward pattern'**
  String get rewardPatternHaptic;

  /// No description provided for @rewardPatternHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'Sparkly water, coin or progress reward'**
  String get rewardPatternHapticDescription;

  /// No description provided for @purchasePatternHaptic.
  ///
  /// In en, this message translates to:
  /// **'Purchase pattern'**
  String get purchasePatternHaptic;

  /// No description provided for @purchasePatternHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'Short confirmation for buying or placing'**
  String get purchasePatternHapticDescription;

  /// No description provided for @unlockPatternHaptic.
  ///
  /// In en, this message translates to:
  /// **'Unlock pattern'**
  String get unlockPatternHaptic;

  /// No description provided for @unlockPatternHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'Bigger reveal for new plants or milestones'**
  String get unlockPatternHapticDescription;

  /// No description provided for @errorPatternHaptic.
  ///
  /// In en, this message translates to:
  /// **'Error pattern'**
  String get errorPatternHaptic;

  /// No description provided for @errorPatternHapticDescription.
  ///
  /// In en, this message translates to:
  /// **'Clear no/blocked feedback without a long vibration'**
  String get errorPatternHapticDescription;

  /// No description provided for @primaryButtonFeedback.
  ///
  /// In en, this message translates to:
  /// **'Primary button'**
  String get primaryButtonFeedback;

  /// No description provided for @iconButtonLightFeedback.
  ///
  /// In en, this message translates to:
  /// **'Icon button light'**
  String get iconButtonLightFeedback;

  /// No description provided for @iconButtonMediumFeedback.
  ///
  /// In en, this message translates to:
  /// **'Icon button medium'**
  String get iconButtonMediumFeedback;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @potClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get potClassic;

  /// No description provided for @potBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue pot'**
  String get potBlue;

  /// No description provided for @potColorful.
  ///
  /// In en, this message translates to:
  /// **'Colorful pot'**
  String get potColorful;

  /// No description provided for @potHanging.
  ///
  /// In en, this message translates to:
  /// **'Hanging pot'**
  String get potHanging;

  /// No description provided for @potRound.
  ///
  /// In en, this message translates to:
  /// **'Round pot'**
  String get potRound;

  /// No description provided for @potWhite.
  ///
  /// In en, this message translates to:
  /// **'White pot'**
  String get potWhite;

  /// No description provided for @decorBench.
  ///
  /// In en, this message translates to:
  /// **'Garden bench'**
  String get decorBench;

  /// No description provided for @decorFountain.
  ///
  /// In en, this message translates to:
  /// **'Fountain'**
  String get decorFountain;

  /// No description provided for @decorPlantFrame.
  ///
  /// In en, this message translates to:
  /// **'Plant frame'**
  String get decorPlantFrame;

  /// No description provided for @decorHangingPot.
  ///
  /// In en, this message translates to:
  /// **'Hanging pot'**
  String get decorHangingPot;

  /// No description provided for @decorLantern.
  ///
  /// In en, this message translates to:
  /// **'Lantern'**
  String get decorLantern;

  /// No description provided for @decorStonePath.
  ///
  /// In en, this message translates to:
  /// **'Stone path'**
  String get decorStonePath;

  /// No description provided for @decorWateringCan.
  ///
  /// In en, this message translates to:
  /// **'Watering can'**
  String get decorWateringCan;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Patsspace'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your quiet place for focus, growth, and good habits.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingPatTitle.
  ///
  /// In en, this message translates to:
  /// **'Hi, I’m Pat.'**
  String get onboardingPatTitle;

  /// No description provided for @onboardingPatBody.
  ///
  /// In en, this message translates to:
  /// **'I’ll show you around.'**
  String get onboardingPatBody;

  /// No description provided for @onboardingPatAction.
  ///
  /// In en, this message translates to:
  /// **'Hi Pat'**
  String get onboardingPatAction;

  /// No description provided for @onboardingFocusEarnGrowTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus, earn, grow'**
  String get onboardingFocusEarnGrowTitle;

  /// No description provided for @onboardingFocusEarnGrowBody.
  ///
  /// In en, this message translates to:
  /// **'Stay focused, earn Waterdrops, and use them to grow plants in your space.'**
  String get onboardingFocusEarnGrowBody;

  /// No description provided for @onboardingStepFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Focus'**
  String get onboardingStepFocusTitle;

  /// No description provided for @onboardingStepFocusBody.
  ///
  /// In en, this message translates to:
  /// **'You focus with intention.'**
  String get onboardingStepFocusBody;

  /// No description provided for @onboardingStepEarnTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Earn'**
  String get onboardingStepEarnTitle;

  /// No description provided for @onboardingStepEarnBody.
  ///
  /// In en, this message translates to:
  /// **'You earn Waterdrops.'**
  String get onboardingStepEarnBody;

  /// No description provided for @onboardingStepGrowTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Grow'**
  String get onboardingStepGrowTitle;

  /// No description provided for @onboardingStepGrowBody.
  ///
  /// In en, this message translates to:
  /// **'Your plant grows as you keep going.'**
  String get onboardingStepGrowBody;

  /// No description provided for @onboardingSourceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'One quick question'**
  String get onboardingSourceEyebrow;

  /// No description provided for @onboardingSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Where did you first hear about Patsspace?'**
  String get onboardingSourceTitle;

  /// No description provided for @onboardingSourceBody.
  ///
  /// In en, this message translates to:
  /// **'This helps us understand what’s working.'**
  String get onboardingSourceBody;

  /// No description provided for @onboardingSourceAlmostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get onboardingSourceAlmostThere;

  /// No description provided for @onboardingSourceTikTok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get onboardingSourceTikTok;

  /// No description provided for @onboardingSourceInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get onboardingSourceInstagram;

  /// No description provided for @onboardingSourceYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get onboardingSourceYouTube;

  /// No description provided for @onboardingSourceAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get onboardingSourceAppStore;

  /// No description provided for @onboardingSourceFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get onboardingSourceFriend;

  /// No description provided for @onboardingSourceSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get onboardingSourceSearch;

  /// No description provided for @onboardingSourceOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get onboardingSourceOther;

  /// No description provided for @onboardingStartSmallTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s start small'**
  String get onboardingStartSmallTitle;

  /// No description provided for @onboardingStartSmallBody.
  ///
  /// In en, this message translates to:
  /// **'Try a 30-second focus challenge with me.'**
  String get onboardingStartSmallBody;

  /// No description provided for @onboardingStartChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start challenge'**
  String get onboardingStartChallenge;

  /// No description provided for @onboardingChallengeNiceWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Nice work!'**
  String get onboardingChallengeNiceWorkTitle;

  /// No description provided for @onboardingChallengeNiceWorkBody.
  ///
  /// In en, this message translates to:
  /// **'You completed your first focus challenge.'**
  String get onboardingChallengeNiceWorkBody;

  /// No description provided for @onboardingChallengeAlmostThereTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get onboardingChallengeAlmostThereTitle;

  /// No description provided for @onboardingChallengeAlmostThereBody.
  ///
  /// In en, this message translates to:
  /// **'Keep going. You’re nearly done.'**
  String get onboardingChallengeAlmostThereBody;

  /// No description provided for @onboardingChallengeStayTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay with it'**
  String get onboardingChallengeStayTitle;

  /// No description provided for @onboardingChallengeStayBody.
  ///
  /// In en, this message translates to:
  /// **'You’re doing great.'**
  String get onboardingChallengeStayBody;

  /// No description provided for @onboardingChallengeReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are'**
  String get onboardingChallengeReadyTitle;

  /// No description provided for @onboardingChallengeReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap start and stay with Pat until the timer ends.'**
  String get onboardingChallengeReadyBody;

  /// No description provided for @onboardingChallengeOpeningGarden.
  ///
  /// In en, this message translates to:
  /// **'Opening Garden...'**
  String get onboardingChallengeOpeningGarden;

  /// No description provided for @onboardingChallengePlantFirstSeed.
  ///
  /// In en, this message translates to:
  /// **'Plant your first seed'**
  String get onboardingChallengePlantFirstSeed;

  /// No description provided for @onboardingChallengeStayFocused.
  ///
  /// In en, this message translates to:
  /// **'Stay focused'**
  String get onboardingChallengeStayFocused;

  /// No description provided for @onboardingChallengeStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingChallengeStart;

  /// No description provided for @saveYourSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your space'**
  String get saveYourSpaceTitle;

  /// No description provided for @saveYourSpaceBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your plants, Waterdrops, and focus history safe across devices.'**
  String get saveYourSpaceBody;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @gardenTutorialPickHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a pot'**
  String get gardenTutorialPickHomeTitle;

  /// No description provided for @gardenTutorialPickHomeBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the glowing pot.'**
  String get gardenTutorialPickHomeBody;

  /// No description provided for @gardenTutorialPlantDaisyTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant your seed'**
  String get gardenTutorialPlantDaisyTitle;

  /// No description provided for @gardenTutorialPlantDaisyBody.
  ///
  /// In en, this message translates to:
  /// **'Daisy is ready. Plant it here.'**
  String get gardenTutorialPlantDaisyBody;

  /// No description provided for @gardenTutorialGiveWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Give it water'**
  String get gardenTutorialGiveWaterTitle;

  /// No description provided for @gardenTutorialGiveWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the drop until it sprouts.'**
  String get gardenTutorialGiveWaterBody;

  /// No description provided for @gardenTutorialSpaceGrowingTitle.
  ///
  /// In en, this message translates to:
  /// **'It sprouted'**
  String get gardenTutorialSpaceGrowingTitle;

  /// No description provided for @gardenTutorialSpaceGrowingBody.
  ///
  /// In en, this message translates to:
  /// **'Your space has begun.'**
  String get gardenTutorialSpaceGrowingBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
