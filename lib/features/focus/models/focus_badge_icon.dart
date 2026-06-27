import 'package:pats_space/core/assets/app_assets.dart';

enum FocusBadgeIcon {
  character,
  none;

  String? get assetPath {
    return switch (this) {
      FocusBadgeIcon.character => AppAssets.focusStampCharacter,
      FocusBadgeIcon.none => null,
    };
  }
}
