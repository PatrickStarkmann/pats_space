import 'package:flutter/widgets.dart';

class GardenPotView extends StatelessWidget {
  const GardenPotView({super.key, required this.size, required this.assetPath});

  final double size;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
