import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/features/space/models/garden_growth_stage.dart';
import 'package:pats_space/features/space/widgets/garden_coin_icon.dart';

class GardenActionBubble extends StatelessWidget {
  const GardenActionBubble({
    super.key,
    required this.stage,
    required this.size,
    required this.onTap,
  });

  final GardenGrowthStage stage;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = stage.needsWater
        ? const Color(0xFF6FAAF7)
        : AppColors.grayWarm;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _GardenBubblePainter(
            borderColor: stage.isEmpty
                ? AppColors.grayWarm
                : AppColors.graySoft,
            fillColor: AppColors.surface.withValues(alpha: .9),
            dashed: stage.isEmpty,
          ),
          child: Center(
            child: stage.hasCoins
                ? GardenCoinIcon(size: size * .52)
                : Icon(stage.actionIcon, size: size * .44, color: color),
          ),
        ),
      ),
    );
  }
}

class _GardenBubblePainter extends CustomPainter {
  const _GardenBubblePainter({
    required this.borderColor,
    required this.fillColor,
    required this.dashed,
  });

  final Color borderColor;
  final Color fillColor;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final bubble = Path()..addOval(Offset.zero & size);

    canvas.drawPath(
      bubble,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    final stroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    if (!dashed) {
      canvas.drawPath(bubble, stroke);
      return;
    }

    _drawDashedPath(canvas, bubble, stroke);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GardenBubblePainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.dashed != dashed;
  }
}
