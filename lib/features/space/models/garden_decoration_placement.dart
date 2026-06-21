class GardenDecorationPlacement {
  const GardenDecorationPlacement({
    required this.alignmentX,
    required this.alignmentY,
    this.scale = 1,
    this.inFront = false,
  });

  final double alignmentX;
  final double alignmentY;
  final double scale;
  final bool inFront;

  GardenDecorationPlacement copyWith({
    double? alignmentX,
    double? alignmentY,
    double? scale,
    bool? inFront,
  }) {
    return GardenDecorationPlacement(
      alignmentX: alignmentX ?? this.alignmentX,
      alignmentY: alignmentY ?? this.alignmentY,
      scale: scale ?? this.scale,
      inFront: inFront ?? this.inFront,
    );
  }
}
