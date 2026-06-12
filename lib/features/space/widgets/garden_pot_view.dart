import 'package:flutter/widgets.dart';
import 'package:pats_space/core/assets/app_assets.dart';

class GardenPotView extends StatelessWidget {
  const GardenPotView({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        AppAssets.gardenPotDefault,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
