import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Chunky N-pointed burst star — the Hatri brand mark for editorial accents,
/// marquee separators, and decorative punctuation. Vector-drawn so it stays
/// crisp at any size and tints on demand.
class BurstStar extends StatelessWidget {
  final double size;
  final Color color;
  final int points;
  final double innerRatio;
  final double rotationDeg;

  const BurstStar({
    super.key,
    this.size = 24,
    this.color = AppColors.fuchsia,
    this.points = 8,
    this.innerRatio = 0.42,
    this.rotationDeg = 11.25,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BurstStarPainter(
          color: color,
          points: points,
          innerRatio: innerRatio,
          rotationDeg: rotationDeg,
        ),
      ),
    );
  }
}

class _BurstStarPainter extends CustomPainter {
  final Color color;
  final int points;
  final double innerRatio;
  final double rotationDeg;

  _BurstStarPainter({
    required this.color,
    required this.points,
    required this.innerRatio,
    required this.rotationDeg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = math.min(cx, cy);
    final innerR = outerR * innerRatio;
    final total = points * 2;
    final base = rotationDeg * math.pi / 180 - math.pi / 2; // start pointing up
    final path = Path();
    for (var i = 0; i < total; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = base + i * (2 * math.pi / total);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _BurstStarPainter old) =>
      old.color != color ||
      old.points != points ||
      old.innerRatio != innerRatio ||
      old.rotationDeg != rotationDeg;
}
