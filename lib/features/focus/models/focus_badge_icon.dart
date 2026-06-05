import 'package:flutter/cupertino.dart';

enum FocusBadgeIcon {
  cat,
  leaf,
  sparkles,
  moon;

  IconData get icon {
    return switch (this) {
      FocusBadgeIcon.cat => CupertinoIcons.smiley,
      FocusBadgeIcon.leaf => CupertinoIcons.leaf_arrow_circlepath,
      FocusBadgeIcon.sparkles => CupertinoIcons.sparkles,
      FocusBadgeIcon.moon => CupertinoIcons.moon_stars,
    };
  }
}
