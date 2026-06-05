import 'package:pats_space/features/focus/models/focus_accent_color.dart';
import 'package:pats_space/features/focus/models/focus_badge_icon.dart';

class FocusTag {
  const FocusTag({
    required this.name,
    required this.accentColor,
    required this.badgeIcon,
  });

  final String name;
  final FocusAccentColor accentColor;
  final FocusBadgeIcon badgeIcon;
}
