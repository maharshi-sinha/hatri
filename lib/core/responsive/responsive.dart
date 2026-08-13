import 'dart:ui' show FlutterView;

import 'package:flutter/widgets.dart';

/// Screen-adaptive sizing for Hatri.
///
/// Call sites use the same ergonomics as flutter_screenutil (`16.r`, `14.sp`),
/// but the scale is *clamped* rather than linear. A linear design-width ratio
/// inflates the UI on large phones and roughly doubles it on tablets; here the
/// design tokens are treated as the maximum size and small screens scale down
/// toward a readable floor.
///
///   shortestSide  raw    layout  text
///   320 (SE)      0.744  0.80    0.85
///   375 (13 mini) 0.872  0.87    0.87
///   393 (15)      0.914  0.91    0.91
///   411 (A36)     0.956  0.96    0.96
///   430 (16 Pro Max) 1.0 1.00    1.00
///   768+ (tablet) >1.0   1.00    1.00
class AppScale {
  AppScale._();

  /// Widest common phone. Tokens are authored against this width.
  static const double designWidth = 430;

  /// Layout never grows past the design size, and never shrinks below 80%.
  static const double _layoutMin = 0.80;

  /// Text has a higher floor than layout — 8pt labels are unreadable.
  static const double _textMin = 0.85;

  static double _layout = 1.0;
  static double _text = 1.0;

  /// Uniform multiplier for spacing, radii, icon and box dimensions.
  static double get layout => _layout;

  /// Multiplier for font sizes. Composes with the system text scaler, which
  /// [MediaQuery.withClampedTextScaling] bounds separately in `main.dart`.
  static double get text => _text;

  /// Recomputes both factors. Safe to call on every root build — it is cheap
  /// and keeps the values correct across rotation, split-screen and unfolding.
  static void update(Size size) {
    final shortestSide = size.shortestSide;
    if (shortestSide <= 0) return;
    final raw = shortestSide / designWidth;
    _layout = raw.clamp(_layoutMin, 1.0);
    _text = raw.clamp(_textMin, 1.0);
  }

  /// Seeds the factors before the first frame, so any sizing read during
  /// `main()` (ahead of the first [MediaQuery]) is already correct.
  static void updateFromView(FlutterView view) {
    update(view.physicalSize / view.devicePixelRatio);
  }
}

/// Phone-first layouts stretch badly on tablets and unfolded foldables.
/// Content is centered and capped instead of spanning the full width.
const double kMaxContentWidth = 560;

extension ResponsiveNum on num {
  /// Scaled logical pixels — spacing, radii, icon sizes, box dimensions.
  double get r => this * AppScale.layout;

  /// Alias of [r]. Kept so width-intent reads clearly at the call site.
  /// Unlike screenutil, this does *not* use a separate horizontal ratio —
  /// scaling width and height independently distorts aspect ratios on tall
  /// or short screens.
  double get w => this * AppScale.layout;

  /// Alias of [r], for height-intent call sites.
  double get h => this * AppScale.layout;

  /// Scaled font size.
  double get sp => this * AppScale.text;
}

/// Breakpoint helpers for the few places that need a genuinely different
/// layout rather than a smaller one.
extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// iPhone SE / older compact Androids.
  bool get isCompactPhone => MediaQuery.sizeOf(this).shortestSide < 360;

  /// Tablets and unfolded foldables.
  bool get isTablet => MediaQuery.sizeOf(this).shortestSide >= 600;

  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;
}
