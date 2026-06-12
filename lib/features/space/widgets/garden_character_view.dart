import 'package:flutter/widgets.dart';
import 'package:pats_space/core/assets/app_assets.dart';
import 'package:pats_space/core/widgets/looping_asset_animation.dart';

class GardenCharacterView extends StatelessWidget {
  const GardenCharacterView({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const LoopingAssetAnimation(frames: AppAssets.focusPair02Focus),
    );
  }
}
