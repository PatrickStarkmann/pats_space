import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:pats_space/features/stats/models/tag_focus_segment.dart';

class DonutChartPainter extends CustomPainter {
  const DonutChartPainter({required this.segments});

  final List<TagFocusSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = size.width * 0.23;
    final center = rect.center;
    final radius = size.width / 2 - strokeWidth / 2;
    final basePaint = Paint()
      ..color = const Color(0xFFE9EAEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (segments.isEmpty) {
      canvas.drawCircle(center, radius, basePaint);
      return;
    }

    var startAngle = -math.pi / 2;
    final total = segments.fold<double>(
      0,
      (total, segment) => total + segment.duration.inSeconds,
    );

    for (final segment in segments) {
      final sweepAngle = segment.duration.inSeconds / total * math.pi * 2;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.08,
        math.max(0, sweepAngle - 0.16),
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
