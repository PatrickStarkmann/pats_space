import 'package:flutter/material.dart';
import 'package:pats_space/core/theme/app_colors.dart';

class PatsspaceCharacterView extends StatelessWidget {
  const PatsspaceCharacterView({
    super.key,
    required this.compact,
    required this.assetPath,
  });

  final bool compact;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 260.0 : 330.0;
    final height = compact ? 210.0 : 270.0;

    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const _CharacterFallback(),
      ),
    );
  }
}

class _CharacterFallback extends StatelessWidget {
  const _CharacterFallback();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CharacterFallbackPainter());
  }
}

class _CharacterFallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.7;
    final fill = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
    final accent = Paint()
      ..color = AppColors.accentWarm
      ..style = PaintingStyle.fill;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.38,
        size.height * 0.18,
        size.width * 0.38,
        size.height * 0.54,
      ),
      Radius.circular(size.width * 0.15),
    );
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);

    final leftEar = Path()
      ..moveTo(size.width * 0.46, size.height * 0.2)
      ..lineTo(size.width * 0.51, size.height * 0.05)
      ..lineTo(size.width * 0.57, size.height * 0.23);
    final rightEar = Path()
      ..moveTo(size.width * 0.6, size.height * 0.23)
      ..lineTo(size.width * 0.7, size.height * 0.08)
      ..lineTo(size.width * 0.72, size.height * 0.28);
    canvas.drawPath(leftEar, fill);
    canvas.drawPath(leftEar, stroke);
    canvas.drawPath(rightEar, fill);
    canvas.drawPath(rightEar, stroke);

    canvas.drawCircle(
      Offset(size.width * 0.51, size.height * 0.36),
      2.5,
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.64, size.height * 0.36),
      2.5,
      stroke,
    );

    final mouth = Path()
      ..moveTo(size.width * 0.56, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.58,
        size.height * 0.46,
        size.width * 0.61,
        size.height * 0.42,
      );
    canvas.drawPath(mouth, stroke);

    final book = Path()
      ..moveTo(size.width * 0.48, size.height * 0.55)
      ..lineTo(size.width * 0.58, size.height * 0.5)
      ..lineTo(size.width * 0.68, size.height * 0.55)
      ..lineTo(size.width * 0.66, size.height * 0.68)
      ..lineTo(size.width * 0.58, size.height * 0.64)
      ..lineTo(size.width * 0.5, size.height * 0.68)
      ..close();
    canvas.drawPath(book, accent);
    canvas.drawPath(book, stroke);
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.5),
      Offset(size.width * 0.58, size.height * 0.64),
      stroke,
    );

    final fireCan = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.58,
        size.width * 0.23,
        size.height * 0.22,
      ),
      Radius.circular(size.width * 0.035),
    );
    canvas.drawRRect(fireCan, fill);
    canvas.drawRRect(fireCan, stroke);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.54,
        size.width * 0.23,
        size.height * 0.08,
      ),
      stroke,
    );

    for (final x in [0.13, 0.18, 0.23]) {
      final flame = Path()
        ..moveTo(size.width * x, size.height * 0.56)
        ..quadraticBezierTo(
          size.width * (x - 0.035),
          size.height * 0.48,
          size.width * x,
          size.height * 0.43,
        )
        ..quadraticBezierTo(
          size.width * (x + 0.035),
          size.height * 0.5,
          size.width * x,
          size.height * 0.56,
        );
      canvas.drawPath(flame, stroke);
    }

    final chair = Path()
      ..moveTo(size.width * 0.74, size.height * 0.33)
      ..lineTo(size.width * 0.8, size.height * 0.78)
      ..moveTo(size.width * 0.42, size.height * 0.77)
      ..lineTo(size.width * 0.72, size.height * 0.77)
      ..moveTo(size.width * 0.76, size.height * 0.45)
      ..lineTo(size.width * 0.82, size.height * 0.42);
    canvas.drawPath(chair, stroke);

    final ground = Path()
      ..moveTo(size.width * 0.2, size.height * 0.9)
      ..lineTo(size.width * 0.28, size.height * 0.9)
      ..moveTo(size.width * 0.42, size.height * 0.86)
      ..lineTo(size.width * 0.48, size.height * 0.86)
      ..moveTo(size.width * 0.69, size.height * 0.88)
      ..lineTo(size.width * 0.84, size.height * 0.85)
      ..moveTo(size.width * 0.04, size.height * 0.73)
      ..quadraticBezierTo(
        size.width * 0.02,
        size.height * 0.71,
        size.width * 0.04,
        size.height * 0.69,
      );
    canvas.drawPath(ground, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
