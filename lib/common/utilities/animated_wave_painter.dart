import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class AnimatedWavePainter extends CustomPainter {
  final Color color;
  final double percentage;
  final double waveShift;

  AnimatedWavePainter({
    required this.color,
    required this.percentage,
    required this.waveShift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.35),
          color.withOpacity(0.15),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    final baseHeight = size.height * 0.75;
    final lift = 35 * percentage;
    final waveTop = baseHeight - lift;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = waveTop +
          6 *
              math.sin(
                (x / size.width * 2 * math.pi) +
                    (waveShift * 2 * math.pi),
              );

      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}