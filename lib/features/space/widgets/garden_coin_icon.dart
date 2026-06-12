import 'package:flutter/widgets.dart';
import 'package:pats_space/core/theme/app_colors.dart';

class GardenCoinIcon extends StatelessWidget {
  const GardenCoinIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GardenCoinIconPainter()),
    );
  }
}

class _GardenCoinIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final fill = Paint()
      ..color = AppColors.accentWarm
      ..style = PaintingStyle.fill;
    final highlight = Paint()
      ..color = const Color(0xFFFFE68A)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final stroke = Paint()
      ..color = const Color(0xFFD7A91D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * .08
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius * .88, fill);
    canvas.drawCircle(center, radius * .72, stroke);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * .58),
      -2.4,
      1.2,
      false,
      highlight..strokeWidth = size.shortestSide * .1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
