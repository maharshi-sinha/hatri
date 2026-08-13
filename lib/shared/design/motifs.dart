import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';

/// A hard-offset "sticker" shadow (solid, no blur) — brutalist pop motif.
/// Wrap any card to get a crisp offset color block behind it. The shadow is
/// contained inside the widget's bounds (via margin) so it never overflows or
/// clips at parent edges.
class StickerShadow extends StatelessWidget {
  final Widget child;
  final Color color;

  /// Defaults to a screen-scaled 5x5 offset. Scaled tokens are not compile-time
  /// constants, so the default is resolved in [build] rather than the signature.
  final Offset? offset;
  final double? radius;

  const StickerShadow({
    super.key,
    required this.child,
    this.color = AppColors.indigo,
    this.offset,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedOffset = offset ?? Offset(5.r, 5.r);
    final resolvedRadius = radius ?? Corners.lg;
    // Reserve room for the shadow via margin, then paint the shadow behind the
    // child with a zero-blur BoxShadow — Flutter's built-in hard shadow.
    return Container(
      margin: EdgeInsets.only(
        right: resolvedOffset.dx,
        bottom: resolvedOffset.dy,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(resolvedRadius),
        boxShadow: [
          BoxShadow(
            color: color,
            offset: resolvedOffset,
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// N-pointed starburst / sparkle sticker.
class Starburst extends StatelessWidget {
  final double size;
  final Color color;
  final int points;

  const Starburst({
    super.key,
    this.size = 40,
    this.color = AppColors.lime,
    this.points = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StarburstPainter(color: color, points: points)),
    );
  }
}

class _StarburstPainter extends CustomPainter {
  final Color color;
  final int points;
  _StarburstPainter({required this.color, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final innerR = outerR * 0.4;
    final path = Path();
    final step = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = i * step - math.pi / 2;
      final p = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarburstPainter old) =>
      old.color != color || old.points != points;
}

/// Halftone dot texture background — Y2K printed-poster feel.
class HalftoneBackground extends StatelessWidget {
  final Color dotColor;
  final double spacing;
  final double dotSize;

  const HalftoneBackground({
    super.key,
    this.dotColor = AppColors.fuchsia,
    this.spacing = 12,
    this.dotSize = 2.4,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _HalftonePainter(
          dotColor: dotColor,
          spacing: spacing,
          dotSize: dotSize,
        ),
      ),
    );
  }
}

class _HalftonePainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double dotSize;
  _HalftonePainter({required this.dotColor, required this.spacing, required this.dotSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter old) =>
      old.dotColor != dotColor || old.spacing != spacing || old.dotSize != dotSize;
}

/// Uppercase eyebrow / sticker label with a hard outline — annotation-style.
class StickerLabel extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final Color? outline;

  const StickerLabel({
    super.key,
    required this.text,
    this.background = AppColors.fuchsia,
    this.foreground = AppColors.onNeon,
    this.outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Corners.xs),
        border: Border.all(color: outline ?? foreground, width: 1.4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
          letterSpacing: 1.3.sp,
          color: foreground,
        ),
      ),
    );
  }
}
