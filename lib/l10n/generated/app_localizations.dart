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

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Session reminders and break alerts'**
  String get notificationsDescription;

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
