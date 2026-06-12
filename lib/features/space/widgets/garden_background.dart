import 'package:flutter/widgets.dart';
import 'package:pats_space/core/assets/app_assets.dart';

class GardenBackground extends StatelessWidget {
  const GardenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.gardenBackgroundMain,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }
}
