import 'package:pats_space/core/assets/app_assets.dart';

enum GardenArea {
  main,
  second;

  String get displayName => switch (this) {
    GardenArea.main => 'Garden',
    GardenArea.second => 'Meadow',
  };

  String get assetPath => switch (this) {
    GardenArea.main => AppAssets.gardenBackgroundMain,
    GardenArea.second => AppAssets.gardenBackgroundSecond,
  };

  int get potCount => switch (this) {
    GardenArea.main => 4,
    GardenArea.second => 9,
  };

  bool isHangingPotSlot(int index) {
    return this == GardenArea.second && index >= 0 && index <= 2;
  }

  static GardenArea? fromStoredName(Object? value) {
    if (value is! String) {
      return null;
    }

    for (final area in values) {
      if (area.name == value) {
        return area;
      }
    }
    return null;
  }
}
