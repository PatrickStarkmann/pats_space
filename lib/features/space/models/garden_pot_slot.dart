import 'package:pats_space/features/space/models/garden_pot_style.dart';

class GardenPotSlot {
  const GardenPotSlot({
    required this.alignmentX,
    required this.alignmentY,
    required this.sizeFactor,
    this.useNoShadowPot = false,
    this.potStyleOverride,
  });

  final double alignmentX;
  final double alignmentY;
  final double sizeFactor;
  final bool useNoShadowPot;
  final GardenPotStyle? potStyleOverride;
}
