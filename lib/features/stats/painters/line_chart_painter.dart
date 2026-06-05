import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:pats_space/core/theme/app_colors.dart';

class LineChartPainter extends CustomPainter {
  const LineChartPainter({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const leftLabelInset = 18.0;
    const rightLabelWidth = 30.0;
    const bottomLabelHeight = 26.0;
    final chartRect = Rect.fromLTWH(
      leftLabelInset,
      0,
      size.width - leftLabelInset - rightLabelWidth,
      size.height - bottomLabelHeight,
    );
    final gridPaint = Paint()
      ..color = const Color(0xFFD4D4D8)
      ..strokeWidth = 1;
    final dashedPaint = Paint()
      ..color = const Color(0xFFC9C9CE)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xFF35C962)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i <= 4; i++) {
      final y = chartRect.top + chartRect.height * i / 4;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
      _drawText(
        canvas,
        '${4 - i}h',
        Offset(chartRect.right + 8, y - 11),
        color: AppColors.grayWarm,
        fontSize: 16,
      );
    }

    final verticalCount = labels.length;
    for (var i = 0; i < verticalCount; i++) {
      final x = verticalCount == 1
          ? chartRect.left
          : chartRect.left + chartRect.width * i / (verticalCount - 1);
      _drawDashedLine(
        canvas,
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom + 10),
        dashedPaint,
      );
      _drawText(
        canvas,
        labels[i],
        Offset(x, chartRect.bottom + 4),
        color: AppColors.grayWarm,
        fontSize: 14,
        horizontalAnchor: _TextHorizontalAnchor.center,
      );
    }

    if (values.isEmpty) {
      return;
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? chartRect.left
          : chartRect.left + chartRect.width * i / (values.length - 1);
      final normalized = (values[i] / 4).clamp(0.0, 1.0);
      final y = chartRect.bottom - chartRect.height * normalized;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashHeight = 5.0;
    const dashSpace = 5.0;
    var distance = 0.0;
    final totalDistance = (end - start).distance;
    final direction = (end - start) / totalDistance;
    while (distance < totalDistance) {
      final dashStart = start + direction * distance;
      final dashEnd =
          start + direction * math.min(distance + dashHeight, totalDistance);
      canvas.drawLine(dashStart, dashEnd, paint);
      distance += dashHeight + dashSpace;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    required double fontSize,
    _TextHorizontalAnchor horizontalAnchor = _TextHorizontalAnchor.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (horizontalAnchor) {
      _TextHorizontalAnchor.left => offset.dx,
      _TextHorizontalAnchor.center => offset.dx - painter.width / 2,
    };
    painter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}

enum _TextHorizontalAnchor { left, center }
