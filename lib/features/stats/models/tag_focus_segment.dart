import 'package:flutter/material.dart';

class TagFocusSegment {
  const TagFocusSegment({
    required this.label,
    required this.color,
    required this.duration,
    required this.percentage,
  });

  final String label;
  final Color color;
  final Duration duration;
  final double percentage;
}
