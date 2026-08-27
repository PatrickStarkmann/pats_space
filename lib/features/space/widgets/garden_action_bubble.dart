import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:pats_space/core/theme/app_colors.dart';
import 'package:pats_space/features/space/models/garden_pot.dart';
import 'package:pats_space/features/space/widgets/garden_coin_icon.dart';

class GardenActionBubble extends StatelessWidget {
  const GardenActionBubble({
    super.key,
    required this.pot,
    required this.enabled,
    required this.size,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  final GardenPot pot;
  final bool enabled;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final stage = pot.stage;
    final color = stage.needsWater
        ? const Color(0xFF6FAAF7).withValues(alpha: enabled ? 1 : .34)
        : AppColors.grayWarm;
    final hitSize = size * 1.55;
    final progress = pot.waterRequired == 0
        ? 0.0
        : (pot.waterProgress / pot.waterRequired).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPressStart: onLongPressStart == null
          ? null
          : (_) => onLongPressStart?.call(),
      onLongPressEnd: onLongPressEnd == null
          ? null
          : (_) => onLongPressEnd?.call(),
      onLongPressCancel: onLongPressEnd,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled || stage.isEmpty ? 1 : .52,
        child: SizedBox.square(
          dimension: hitSize,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (stage.needsWater)
                  SizedBox.square(
                    dimension: size * 1.18,
                    child: CustomPaint(
                      painter: _BubbleProgressRingPainter(
                        progress: progress,
                        enabled: enabled,
                      ),
                    ),
                  ),
                SizedBox.square(
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (stage.hasCoins)
                            GardenCoinIcon(size: size * .52)
                          else
                            Icon(
                              stage.actionIcon,
                              size: size * .44,
                              color: color,
                            ),
                          if (stage.hasCoins && pot.bloomCharges > 1)
                            Positioned(
                              top: -size * .06,
                              right: -size * .14,
                              child: _StoredHarvestBadge(
                                count: pot.bloomCharges,
                                size: size * .38,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoredHarvestBadge extends StatelessWidget {
  const _StoredHarvestBadge({required this.count, required this.size});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 1.5),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: AppColors.surface,
          fontSize: size * .54,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _BubbleProgressRingPainter extends CustomPainter {
  const _BubbleProgressRingPainter({
    required this.progress,
    required this.enabled,
  });

  final double progress;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = size.shortestSide * .055;
    final track = Paint()
      ..color = AppColors.graySoft.withValues(alpha: .38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = const Color(0xFF6FAAF7).withValues(alpha: enabled ? 1 : .34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);
    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.enabled != enabled;
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
