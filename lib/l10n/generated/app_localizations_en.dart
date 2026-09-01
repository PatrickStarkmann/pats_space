// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get yourProfile => 'Your profile';

  @override
  String get editName => 'Edit name';

  @override
  String get namePlaceholder => 'Your name';

  @override
  String get friendCode => 'Friend code';

  @override
  String get addFriend => 'Add friend';

  @override
  String get addFriendSubtitle => 'Enter a friend\'s code';

  @override
  String get friendCodePlaceholder => 'A7K9Q2';

  @override
  String get add => 'Add';

  @override
  String get accept => 'Accept';

  @override
  String get remove => 'Remove';

  @override
  String get friendsSettingsSubtitle => 'Add friends and manage requests';

  @override
  String get incomingRequests => 'Requests';

  @override
  String get sentRequests => 'Sent requests';

  @override
  String get pending => 'Pending';

  @override
  String get noIncomingRequests => 'No requests right now';

  @override
  String get noSentRequests => 'No sent requests';

  @override
  String get cancelRequest => 'Cancel';

  @override
  String get removeFriendTitle => 'Remove friend?';

  @override
  String removeFriendMessage(Object name) {
    return 'Remove $name from your friends?';
  }

  @override
  String get friendRequest => 'Friend request';

  @override
  String get friendRequestSent => 'Friend request sent.';

  @override
  String get friendAdded => 'Friend added.';

  @override
  String get friendCodeCopied => 'Friend code copied.';

  @override
  String get cannotAddYourself => 'This is your own code.';

  @override
  String get friendCodeNotFound => 'No friend found for this code.';

  @override
  String get friendAddFailed => 'Could not add friend right now.';

  @override
  String get loading => 'Loading...';

  @override
  String get friendsThisWeek => 'Weekly ranking';

  @override
  String get friendsLeaderboard => 'Friends leaderboard';

  @override
  String focusMinutes(Object minutes) {
    return '${minutes}min';
  }

  @override
  String get noFriendsLeaderboard =>
      'Add friends to compare your focus time each week.';

  @override
  String get viewLeaderboard => 'View leaderboard';

  @override
  String get you => 'You';

  @override
  String get account => 'Account';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get weekStartDay => 'Week starts on';

  @override
  String get weekStartMonday => 'Monday';

  @override
  String get weekStartSunday => 'Sunday';

  @override
  String get sounds => 'Sounds';

  @override
  String get notifications => 'Notifications';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get contactUs => 'Contact us';

  @override
  String get others => 'Others';

  @override
  String get alertSounds => 'Alert sounds';

  @override
  String get alertSoundsDescription => 'Play sounds for focus, break and stop';

  @override
  String get sound => 'Sound';

  @override
  String get softBell => 'Soft bell';

  @override
  String get ambientSounds => 'Background sounds';

  @override
  String get ambientSoundsDescription =>
      'Play a calming sound while your focus timer is running';

  @override
  String get noAmbientSound => 'No background sound';

  @override
  String get firewood => 'Fireplace';

  @override
  String get rain => 'Rain';

  @override
  String get rainforest => 'Rainforest';

  @override
  String get volume => 'Volume';

  @override
  String get timerSignals => 'Timer signals';

  @override
  String get timerSignalsDescription =>
      'Bell at focus and break endings, finish sound after a full round';

  @override
  String get holdForSoundSelection =>
      'Press and hold the sound button to choose a different sound';

  @override
  String get notificationsDescription => 'Session reminders and break alerts';

  @override
  String get timerNotifications => 'Timer notifications';

  @override
  String get timerNotificationsDescription =>
      'Notify me when a running focus or break ends';

  @override
  String get focusEndNotification => 'Focus completed';

  @override
  String get focusEndNotificationDescription =>
      'When it is time to take a break';

  @override
  String get breakEndNotification => 'Break completed';

  @override
  String get breakEndNotificationDescription =>
      'When it is time to focus again';

  @override
  String get notificationPermissionDenied =>
      'Notifications are disabled in the system settings.';

  @override
  String get focusFinishedNotificationTitle => 'Focus complete';

  @override
  String get focusFinishedNotificationBody => 'Time for a well-earned break.';

  @override
  String get breakFinishedNotificationTitle => 'Break complete';

  @override
  String get breakFinishedNotificationBody =>
      'Ready for the next focus session?';

  @override
  String get roundFinishedNotificationTitle => 'Round complete';

  @override
  String get roundFinishedNotificationBody =>
      'Great work — your focus round is finished.';

  @override
  String get focusReminder => 'Focus reminder';

  @override
  String get focusReminderDescription => 'Before a planned session starts';

  @override
  String get breakReminder => 'Break reminder';

  @override
  String get breakReminderDescription => 'When it is time to rest';

  @override
  String get signIn => 'Sign in';

  @override
  String get secureAccount => 'Secure account';

  @override
  String get secureAccountSubtitle => 'Choose Apple or Google';

  @override
  String get accountSecured => 'Account secured';

  @override
  String get anonymousAccountSubtitle =>
      'Link Apple or Google so your friends and progress stay safe.';

  @override
  String get signedInAccountSubtitle => 'Your friends and progress are saved.';

  @override
  String signedInWithProvider(Object provider) {
    return 'Signed in with $provider';
  }

  @override
  String get chooseSignInMethod =>
      'Choose how you want to secure this account.';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String connectedAccounts(Object providers) {
    return 'Connected: $providers';
  }

  @override
  String get connected => 'Connected';

  @override
  String get accountSecureSuccess => 'Account secured.';

  @override
  String get accountSecureFailed => 'Could not secure your account right now.';

  @override
  String get existingAccountSignInSuccess => 'Signed in.';

  @override
  String get replaceGuestAccountTitle => 'Use existing account?';

  @override
  String get replaceGuestAccountMessage =>
      'This Apple or Google account already exists. Your current guest progress on this device will be replaced.';

  @override
  String get replaceGuestAccountAction => 'Use existing account';

  @override
  String get providerAlreadyLinked => 'Apple or Google is already connected.';

  @override
  String get accountProviderInUse =>
      'This Apple or Google account is already used somewhere else.';

  @override
  String get providerNotEnabled => 'This sign-in option is not ready yet.';

  @override
  String get signInCancelled => 'Sign-in was cancelled.';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutMessage =>
      'You will continue with a new anonymous account on this device.';

  @override
  String get signedOutMessage =>
      'Signed out. You are now using a new anonymous account.';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountMessage =>
      'This removes your profile, friends, requests and friend code. This cannot be undone.';

  @override
  String get accountDeletedMessage => 'Account deleted.';

  @override
  String get accountDeleteFailed => 'Could not delete your account right now.';

  @override
  String get accountDeleteNeedsSignIn =>
      'Please sign in again before deleting your account.';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get version => 'Version';

  @override
  String get appVersion => 'Pat\'s Space 0.1.0';

  @override
  String get timeSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get focusMode => 'Focus Mode';

  @override
  String get deepFocus => 'Deep Focus';

  @override
  String get deepFocusDescription =>
      'Block selected distractions during this session';

  @override
  String get deepFocusSettingsDescription =>
      'Choose the apps, categories, and websites that should stay out of reach while you focus. Your selection remains private on this device.';

  @override
  String deepFocusReadyDescription(int count) {
    return '$count selected';
  }

  @override
  String get deepFocusActive => 'Deep Focus active';

  @override
  String get deepFocusUnavailable => 'Not available on this device';

  @override
  String get deepFocusNotSetUp => 'Not set up';

  @override
  String get deepFocusPermission => 'Screen Time access';

  @override
  String get deepFocusPermissionGranted => 'Access granted';

  @override
  String get deepFocusPermissionNeeded => 'Permission needed';

  @override
  String get deepFocusPermissionDenied => 'Permission denied';

  @override
  String get deepFocusBlockedApps => 'Blocked distractions';

  @override
  String get deepFocusNoAppsSelected => 'No apps selected yet';

  @override
  String get deepFocusChooseApps => 'Choose distractions';

  @override
  String get deepFocusSetUp => 'Set up Deep Focus';

  @override
  String get deepFocusAndroidLater =>
      'Android support is prepared and will be added later.';

  @override
  String get deepFocusSetupFailed =>
      'Deep Focus could not be set up. Please try again.';

  @override
  String get deepFocusCouldNotStartTitle => 'Deep Focus could not start';

  @override
  String get deepFocusCouldNotStartMessage =>
      'Check your Screen Time permission and selected apps, or start this session without blocking.';

  @override
  String get startWithoutDeepFocus => 'Start without blocking';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get stopwatch => 'Stopwatch';

  @override
  String get sessions => 'Sessions';

  @override
  String get longBreakInterval => 'Long Break Interval';

  @override
  String get shortBreak => 'Short Break';

  @override
  String get longBreak => 'Long Break';

  @override
  String get editTag => 'Edit tag';

  @override
  String get tagPlaceholder => 'e.g. Math';

  @override
  String get animation => 'Animation';

  @override
  String get focus => 'Focus';

  @override
  String get breakLabel => 'Break';

  @override
  String get choose => 'Choose';

  @override
  String get stopwatchDescription =>
      'Start an open-ended focus session when you do not know how long you need. Pause when you step away, then finish to save the exact time.';

  @override
  String get avgFocusTime => 'Avg Focus Time';

  @override
  String get monthlyFocusTime => 'Monthly Focus Time';

  @override
  String get focusByTags => 'Focus by Tags';

  @override
  String get noFocusData => 'No focus data yet';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get groupFocus => 'Group Focus';

  @override
  String get friendsFocusingNow => 'Friends focusing now';

  @override
  String get friends => 'Friends';

  @override
  String get createOpenRoom => 'Create open room';

  @override
  String get createOpenRoomSubtitle => 'Friends can join while you focus';

  @override
  String get noRoomsRightNow => 'No rooms right now';

  @override
  String get noRoomsSubtitle => 'Create a room so friends can join you.';

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get noFriendsSubtitle => 'Friends you add will appear here.';

  @override
  String get join => 'Join';

  @override
  String get full => 'Full';

  @override
  String get available => 'Available';

  @override
  String get online => 'online';

  @override
  String get offline => 'offline';

  @override
  String get connectionOfflineMessage =>
      'Offline. Some actions are unavailable.';

  @override
  String get connectionOnlineMessage => 'Back online.';

  @override
  String get settingsOnlineRequired => 'Reconnect to use this action.';

  @override
  String get focusing => 'focusing';

  @override
  String get chooseActivity => 'Choose activity';

  @override
  String get reading => 'reading';

  @override
  String get studying => 'studying';

  @override
  String get working => 'working';

  @override
  String get notStarted => 'not started';

  @override
  String get leaveRoom => 'Leave Room';

  @override
  String roomTitle(Object name) {
    return '$name\'s room';
  }

  @override
  String friendsInRoom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count friends in room',
      one: '1 friend in room',
    );
    return '$_temp0';
  }

  @override
  String get startingPomodoro => 'starting a pomodoro';

  @override
  String get fullRoom => 'full room';

  @override
  String focusCount(int count) {
    return '$count focusing';
  }

  @override
  String breakCount(int count) {
    return '$count break';
  }

  @override
  String get shop => 'Shop';

  @override
  String get shopDescription =>
      'Collect new looks and little pieces for your garden.';

  @override
  String get potStyles => 'Pot styles';

  @override
  String get decor => 'Decor';

  @override
  String get collected => 'Collected';

  @override
  String get inGarden => 'In garden';

  @override
  String get place => 'Place';

  @override
  String get equipped => 'Equipped';

  @override
  String get use => 'Use';

  @override
  String get locked => 'Locked';

  @override
  String get gardenOfflineTitle => 'Garden is offline';

  @override
  String get gardenOfflineMessage => 'Reconnect to use the garden and shop.';

  @override
  String get meadowLockedTitle => 'A new space is waiting';

  @override
  String meadowLockedMessage(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'Bloom $remaining more plants to unlock it.',
      one: 'Bloom 1 more plant to unlock it.',
    );
    return '$_temp0';
  }

  @override
  String get meadowUnlockedTitle => 'New space unlocked';

  @override
  String get meadowUnlockedBody => 'Your Meadow is ready.';

  @override
  String get meadowUnlockAction => 'Explore space';

  @override
  String needItem(Object item) {
    return 'Need $item';
  }

  @override
  String needAmount(int amount) {
    return 'Need $amount';
  }

  @override
  String get leaveGroupFocusTitle => 'Leave group focus?';

  @override
  String get leaveGroupFocusMessage =>
      'You can rejoin an open friend room from the group lobby later.';

  @override
  String get stay => 'Stay';

  @override
  String get leave => 'Leave';

  @override
  String get focusRunningTitle => 'Focus is running';

  @override
  String get focusRunningSettingsMessage =>
      'If you save the settings, the current focus will be cancelled.';

  @override
  String get cancelAndSave => 'Cancel & save';

  @override
  String get cancelFocusTitle => 'Cancel focus?';

  @override
  String get cancelFocusMessage =>
      'The current focus run will end and your progress in this round will be reset.';

  @override
  String get cancelFocus => 'Cancel focus';

  @override
  String get skipFocusTitle => 'Skip focus?';

  @override
  String get skipShortFocusMessage =>
      'Under 5 minutes you do not get water and this focus will not be saved in your stats.';

  @override
  String get skipAnyway => 'Skip anyway';

  @override
  String get finishStopwatchTitle => 'Finish stopwatch?';

  @override
  String get finishShortStopwatchMessage =>
      'Under 5 minutes you do not get water and this session will not be saved in your stats.';

  @override
  String get finishAnyway => 'Finish anyway';

  @override
  String get keepFocusing => 'Keep focusing';

  @override
  String get wellDone => 'Well done';

  @override
  String get takeABreath => 'Take a breath';

  @override
  String get rewardWaterMessage => 'Your garden has more water now.';

  @override
  String get noRewardWaterMessage =>
      'No water this time, but you can always begin again.';

  @override
  String waterReward(int amount) {
    return '+$amount water';
  }

  @override
  String get noWater => 'No water';

  @override
  String focusedDuration(Object duration) {
    return '$duration focused';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get autoContinue => 'Auto continue';

  @override
  String get autoContinueDescription =>
      'Start the next focus or break automatically';

  @override
  String get goToSpace => 'Go to Space';

  @override
  String get animations => 'Animations';

  @override
  String get select => 'Select';

  @override
  String get cleanUpGardenTitle => 'Clean up garden?';

  @override
  String get cleanUpGardenMessage =>
      'This stores placed decor back in your inventory and moves pots to their default spots. Your plants stay planted.';

  @override
  String get cleanUp => 'Clean up';

  @override
  String get choosePlant => 'Choose plant';

  @override
  String get mysteryPlant => 'Mystery plant';

  @override
  String get plantDaisy => 'Daisy';

  @override
  String get plantTulip => 'Tulip';

  @override
  String get plantClover => 'Clover';

  @override
  String get plantSunflower => 'Sunflower';

  @override
  String get plantHangingFlower => 'Hanging flower';

  @override
  String get plantCherryBlossom => 'Cherry blossom';

  @override
  String get plantStrawberry => 'Strawberry';

  @override
  String get plantUnlocked => 'Unlocked';

  @override
  String get plantPremium => 'Pro plant';

  @override
  String plantBloomRequirement(Object plant) {
    return 'Bloom $plant';
  }

  @override
  String get plantSpecialStarter => 'Starter';

  @override
  String get plantSpecialBonus => 'Bonus';

  @override
  String get plantSpecialLucky => 'Lucky';

  @override
  String get plantSpecialJackpot => 'Jackpot';

  @override
  String get plantSpecialHanging => 'Hanging';

  @override
  String get plantSpecialPetalRain => 'Petal rain';

  @override
  String get plantSpecialStoredHarvest => 'Stored harvest';

  @override
  String get plantDescriptionBonus => 'More coins, slower drops';

  @override
  String get plantDescriptionLucky => '20% chance for double coins';

  @override
  String get plantDescriptionJackpot => 'Biggest payout, slowest drop';

  @override
  String get plantDescriptionHanging => 'Only grows in hanging pots';

  @override
  String get plantDescriptionPetalRain =>
      'Gives another blooming plant an instant coin drop';

  @override
  String get plantDescriptionStoredHarvest => 'Stores up to 2 coin drops';

  @override
  String get seedUnlocked => 'Seed unlocked';

  @override
  String get plantReadyToPlant => 'Ready to plant';

  @override
  String get tapAnywhereToContinue => 'Tap anywhere to continue';

  @override
  String get plantUnlockBenefitStarter => 'Starter';

  @override
  String get plantUnlockBenefitBonus => 'Bigger drops';

  @override
  String get plantUnlockBenefitLucky => 'Double chance';

  @override
  String get plantUnlockBenefitJackpot => 'Big payout';

  @override
  String get plantUnlockBenefitHanging => 'Hanging pot';

  @override
  String get plantUnlockBenefitPetalRain => 'Extra drop';

  @override
  String get plantUnlockBenefitStoredHarvest => 'Up to 2 drops';

  @override
  String get potSkin => 'Pot skin';

  @override
  String plantAction(Object plant) {
    return 'Plant $plant';
  }

  @override
  String plantActionWithCost(Object cost) {
    return 'Plant · $cost water';
  }

  @override
  String plantNeedWater(Object cost) {
    return 'Need $cost water';
  }

  @override
  String get plantLocked => 'Locked';

  @override
  String readyToHarvest(Object count) {
    return 'Ready to harvest · $count harvests left';
  }

  @override
  String nextDropIn(Object time) {
    return 'Next drop in $time';
  }

  @override
  String get needsWaterToRecover => 'Needs water to recover';

  @override
  String get waterToGrow => 'Water to grow';

  @override
  String get collect => 'Collect';

  @override
  String get waiting => 'Waiting';

  @override
  String get water => 'Water';

  @override
  String get rewardedWaterTitle => 'More Waterdrops';

  @override
  String get rewardedWaterShopTitle => 'Refill Waterdrops';

  @override
  String rewardedWaterBody(Object amount) {
    return 'Choose to watch a short ad and receive $amount Waterdrops for your Space.';
  }

  @override
  String rewardedWaterRemaining(Object remaining, Object total) {
    return '$remaining of $total videos left today';
  }

  @override
  String get rewardedWaterWatch => 'Watch ad';

  @override
  String get rewardedWaterPreparing => 'Preparing ad …';

  @override
  String get rewardedWaterLater => 'Not now';

  @override
  String rewardedWaterEarned(Object amount) {
    return '+$amount Waterdrops';
  }

  @override
  String get rewardedWaterUnavailable =>
      'The video is still preparing. Please try again shortly.';

  @override
  String get rewardedWaterDailyLimit => 'You have used all videos for today.';

  @override
  String get adPrivacy => 'Privacy choices';

  @override
  String get recoveryProgress => 'Recovery progress';

  @override
  String get growthProgress => 'Growth progress';

  @override
  String coinsEvery(Object coins, Object interval) {
    return '+$coins every $interval';
  }

  @override
  String get removePlant => 'Remove plant';

  @override
  String get soon => 'soon';

  @override
  String hoursMinutesShort(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String minutesShort(Object minutes) {
    return '${minutes}m';
  }

  @override
  String get growthStageEmpty => 'Empty pot';

  @override
  String get growthStageSeed => 'Seed planted';

  @override
  String get growthStageSprout => 'Needs water';

  @override
  String get growthStageBud => 'Growing';

  @override
  String get growthStageBloom => 'Blooming';

  @override
  String get growthStageDry => 'Dried out';

  @override
  String get feedbackLab => 'Feedback Lab';

  @override
  String get feedbackLabSubtitle => 'Try haptics and button feedback';

  @override
  String get rawHaptics => 'Raw haptics';

  @override
  String get patternHaptics => 'Pattern haptics';

  @override
  String get appFeedback => 'App feedback';

  @override
  String get selectionHaptic => 'Selection';

  @override
  String get selectionHapticDescription =>
      'Tiny tick for tabs, pickers and segmented controls';

  @override
  String get lightImpactHaptic => 'Light impact';

  @override
  String get lightImpactHapticDescription =>
      'Soft tap for play, pause and normal buttons';

  @override
  String get mediumImpactHaptic => 'Medium impact';

  @override
  String get mediumImpactHapticDescription =>
      'Stronger tap for skip, cancel, buy and remove';

  @override
  String get successHaptic => 'Success';

  @override
  String get successHapticDescription => 'Reward, unlock or completed focus';

  @override
  String get warningHaptic => 'Warning';

  @override
  String get warningHapticDescription =>
      'No reward, unavailable or blocked action';

  @override
  String get heavyImpactHaptic => 'Heavy impact';

  @override
  String get heavyImpactHapticDescription => 'Single strong system impact';

  @override
  String get rewardPatternHaptic => 'Reward pattern';

  @override
  String get rewardPatternHapticDescription =>
      'Sparkly water, coin or progress reward';

  @override
  String get purchasePatternHaptic => 'Purchase pattern';

  @override
  String get purchasePatternHapticDescription =>
      'Short confirmation for buying or placing';

  @override
  String get unlockPatternHaptic => 'Unlock pattern';

  @override
  String get unlockPatternHapticDescription =>
      'Bigger reveal for new plants or milestones';

  @override
  String get errorPatternHaptic => 'Error pattern';

  @override
  String get errorPatternHapticDescription =>
      'Clear no/blocked feedback without a long vibration';

  @override
  String get primaryButtonFeedback => 'Primary button';

  @override
  String get iconButtonLightFeedback => 'Icon button light';

  @override
  String get iconButtonMediumFeedback => 'Icon button medium';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get potClassic => 'Classic';

  @override
  String get potBlue => 'Blue pot';

  @override
  String get potColorful => 'Colorful pot';

  @override
  String get potHanging => 'Hanging pot';

  @override
  String get potRound => 'Round pot';

  @override
  String get potWhite => 'White pot';

  @override
  String get potFrog => 'Frog pot';

  @override
  String get potCloud => 'Cloud pot';

  @override
  String get decorBench => 'Garden bench';

  @override
  String get decorFountain => 'Fountain';

  @override
  String get decorPlantFrame => 'Plant frame';

  @override
  String get decorHangingPot => 'Hanging pot';

  @override
  String get decorLantern => 'Lantern';

  @override
  String get decorStonePath => 'Stone path';

  @override
  String get decorWateringCan => 'Watering can';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Patsspace';

  @override
  String get onboardingWelcomeBody =>
      'Your quiet place for focus, growth, and good habits.';

  @override
  String get onboardingPatTitle => 'Hi, I’m Pat.';

  @override
  String get onboardingPatBody => 'I’ll show you around.';

  @override
  String get onboardingPatAction => 'Hi Pat';

  @override
  String get onboardingFocusEarnGrowTitle => 'Focus, earn, grow';

  @override
  String get onboardingFocusEarnGrowBody =>
      'Stay focused, earn Waterdrops, and use them to grow plants in your space.';

  @override
  String get onboardingStepFocusTitle => '1. Focus';

  @override
  String get onboardingStepFocusBody => 'You focus with intention.';

  @override
  String get onboardingStepEarnTitle => '2. Earn';

  @override
  String get onboardingStepEarnBody => 'You earn Waterdrops.';

  @override
  String get onboardingStepGrowTitle => '3. Grow';

  @override
  String get onboardingStepGrowBody => 'Your plant grows as you keep going.';

  @override
  String get onboardingSourceEyebrow => 'One quick question';

  @override
  String get onboardingSourceTitle =>
      'Where did you first hear about Patsspace?';

  @override
  String get onboardingSourceBody => 'This helps us understand what’s working.';

  @override
  String get onboardingSourceAlmostThere => 'Almost there!';

  @override
  String get onboardingSourceTikTok => 'TikTok';

  @override
  String get onboardingSourceInstagram => 'Instagram';

  @override
  String get onboardingSourceYouTube => 'YouTube';

  @override
  String get onboardingSourceAppStore => 'App Store';

  @override
  String get onboardingSourceFriend => 'Friend';

  @override
  String get onboardingSourceSearch => 'Search';

  @override
  String get onboardingSourceOther => 'Other';

  @override
  String get onboardingStartSmallTitle => 'Let’s start small';

  @override
  String get onboardingStartSmallBody =>
      'Try a 30-second focus challenge with me.';

  @override
  String get onboardingStartChallenge => 'Start challenge';

  @override
  String get onboardingChallengeNiceWorkTitle => 'Nice work!';

  @override
  String get onboardingChallengeNiceWorkBody =>
      'You completed your first focus challenge.';

  @override
  String get onboardingChallengeAlmostThereTitle => 'Almost there';

  @override
  String get onboardingChallengeAlmostThereBody =>
      'Keep going. You’re nearly done.';

  @override
  String get onboardingChallengeStayTitle => 'Stay with it';

  @override
  String get onboardingChallengeStayBody => 'You’re doing great.';

  @override
  String get onboardingChallengeReadyTitle => 'Ready when you are';

  @override
  String get onboardingChallengeReadyBody =>
      'Tap start and stay with Pat until the timer ends.';

  @override
  String get onboardingChallengeOpeningGarden => 'Opening Garden...';

  @override
  String get onboardingChallengePlantFirstSeed => 'Plant your first seed';

  @override
  String get onboardingChallengeStayFocused => 'Stay focused';

  @override
  String get onboardingChallengeStart => 'Start';

  @override
  String get saveYourSpaceTitle => 'Save your space';

  @override
  String get saveYourSpaceBody =>
      'Keep your plants, Waterdrops, and focus history safe across devices.';

  @override
  String get notNow => 'Not now';

  @override
  String get gardenTutorialPickHomeTitle => 'Pick a pot';

  @override
  String get gardenTutorialPickHomeBody => 'Tap the glowing pot.';

  @override
  String get gardenTutorialPlantDaisyTitle => 'Plant a seed';

  @override
  String get gardenTutorialPlantDaisyBody => 'Tap Plant.';

  @override
  String get gardenTutorialGiveWaterTitle => 'Give it water';

  @override
  String get gardenTutorialGiveWaterBody => 'Tap the drop until it sprouts.';

  @override
  String get gardenTutorialSpaceGrowingTitle => 'It sprouted';

  @override
  String get gardenTutorialSpaceGrowingBody => 'Your space has begun.';

  @override
  String get patsspacePro => 'Patsspace Pro';

  @override
  String get unlockPatsspacePro => 'Unlock Patsspace Pro';

  @override
  String get unlockPro => 'Unlock Pro';

  @override
  String get proBannerSubtitle => 'More room for your focus.';

  @override
  String get proExplore => 'Explore';

  @override
  String get proFocusThatGrows => 'Focus that grows with you.';

  @override
  String get proAllPlantsAndPots => 'Every plant and pot';

  @override
  String get proAllFocusAnimationSets => 'Every focus animation set';

  @override
  String get proNewContent => 'New content as it is released';

  @override
  String get proYearly => 'Yearly';

  @override
  String get proMonthly => 'Monthly';

  @override
  String get proLifetime => 'Lifetime';

  @override
  String get proCancelAnytime => 'Cancel anytime';

  @override
  String get proUnlockedForever => 'Unlocked forever';

  @override
  String get proActiveForAccount => 'Patsspace Pro is active for this account.';

  @override
  String get proBeingSetUp => 'Patsspace Pro is being set up.';

  @override
  String get proOptionsSoon => 'Pro options will be available soon.';

  @override
  String get proContinue => 'Continue';

  @override
  String get proRestorePurchases => 'Restore Purchases';

  @override
  String get proTerms => 'Terms';

  @override
  String get proPrivacy => 'Privacy';

  @override
  String proMonthlyPrice(Object price) {
    return '$price / month';
  }

  @override
  String proApproximateMonthlyPrice(Object price, Object currency) {
    return '≈ $price $currency / month';
  }

  @override
  String proSavePercent(Object percent) {
    return 'Save $percent%';
  }

  @override
  String get proPurchasesRestoredTitle => 'Purchases restored';

  @override
  String get proPurchasesRestoredMessage =>
      'Patsspace Pro is active for this account again.';

  @override
  String get proWelcomeTitle => 'Welcome to Patsspace Pro';

  @override
  String get proWelcomeMessage =>
      'Everything is unlocked. Glad to have you with us.';

  @override
  String get proNotActiveYetTitle => 'Pro is not active yet';

  @override
  String get proNotActiveYetMessage =>
      'The purchase was registered, but access is not active yet. Please try again in a moment.';

  @override
  String get proNothingToRestoreTitle => 'Nothing to restore';

  @override
  String get proNothingToRestoreMessage =>
      'No active Pro purchase was found for this account.';

  @override
  String get proPurchaseFailedTitle => 'Purchase not completed';

  @override
  String get proPurchaseFailedMessage =>
      'Please check your connection and try again in a moment.';

  @override
  String get proRestoreFailedTitle => 'Could not restore purchases';

  @override
  String get proRestoreFailedMessage =>
      'Please check your connection and try again in a moment.';

  @override
  String get proActiveShort => 'Pro is active';

  @override
  String get proExclusiveContent => 'Exclusive plants, pots and animations';

  @override
  String get proManageSubscription => 'Manage subscription';

  @override
  String get proPaymentRetry => 'Payment is being retried';

  @override
  String proRenewsOn(Object date) {
    return 'Renews on $date';
  }

  @override
  String proEndsOn(Object date) {
    return 'Ends on $date';
  }

  @override
  String get focusStart => 'Start';
}
