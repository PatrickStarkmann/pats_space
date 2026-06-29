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
  String get notificationsDescription => 'Session reminders and break alerts';

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
  String get timeSettings => 'Time Settings';

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
}
