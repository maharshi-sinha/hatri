import 'package:flutter/material.dart';

import '../responsive/responsive.dart';

/// Hatri design tokens — Y2K acid-pop brutalism.
/// Single source of truth. Screens consume these tokens, never hex literals.
class AppColors {
  // Grounds & surfaces
  static const Color ground = Color(0xFF0E0E12); // app background
  static const Color graphite = Color(0xFF1C1C1C); // cards/surfaces
  static const Color surfaceRaised = Color(0xFF24242C); // raised chips/inputs
  static const Color border = Color(0xFF2E2E38);

  // Neon accents
  static const Color fuchsia = Color(0xFFFF2E9A); // primary / CTA
  static const Color lime = Color(0xFFCFFF04); // highlights / LIVE / numbers
  static const Color indigo = Color(0xFF5D00FF); // secondary / categories

  // Text
  static const Color paper = Color(0xFFF4F2FF); // primary text on dark
  static const Color muted = Color(0xFF89849C); // secondary text
  static const Color onNeon = Color(0xFF0E0E12); // text on lime/fuchsia blocks

  // --- Back-compat shims so existing screens keep compiling ---
  // Older screens reference these names; map them onto the new palette.
  static const Color background = ground;
  static const Color surface = graphite;
  static const Color card = graphite;
  static const Color primaryText = paper;
  static const Color secondaryText = muted;
  static const Color accentPink = fuchsia;
  static const Color accentGreen = lime;
  static const Color accentBlue = Color(0xFF2D7DFF);
  static const Color accentPurple = indigo;
  static const Color accentOrange = Color(0xFFFF7A00);
  static const Color accentYellow = Color(0xFFFFD400);

  /// Parse a hex string like "#FF2E9A" or "FF2E9A" into a Color.
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// Spacing scale — 4pt base. Prefer these over ad-hoc numbers.
///
/// These are screen-scaled getters rather than constants, so they cannot be
/// used inside compile-time constants. See `core/responsive/responsive.dart`.
class Insets {
  static double get xxs => 4.r;
  static double get xs => 8.r;
  static double get sm => 12.r;
  static double get md => 16.r;
  static double get lg => 20.r;
  static double get xl => 24.r;
  static double get xxl => 32.r;
  static double get xxxl => 48.r;
}

/// Corner-radius scale.
class Corners {
  static double get xs => 6.r;
  static double get sm => 10.r;
  static double get md => 14.r;
  static double get lg => 20.r;
  static double get xl => 28.r;

  /// Sentinel for fully-rounded shapes — deliberately unscaled.
  static const double pill = 999;
}

/// Editorial motion durations.
class Motion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 420);
}

class AppTheme {
  static ThemeData get darkTheme {
    const displayFamily = 'ClashDisplay';
    const bodyFamily = 'GeneralSans';

    final textTheme = TextTheme(
      // Display — brutalist, oversized, tight
      displayLarge: TextStyle(
        fontFamily: displayFamily,
        fontWeight: FontWeight.w700,
        fontSize: 56.sp,
        height: 0.95,
        letterSpacing: -1.6.sp,
        color: AppColors.paper,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFamily,
        fontWeight: FontWeight.w700,
        fontSize: 40.sp,
        height: 0.98,
        letterSpacing: -1.0.sp,
        color: AppColors.paper,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFamily,
        fontWeight: FontWeight.w600,
        fontSize: 28.sp,
        height: 1.02,
        letterSpacing: -0.4.sp,
        color: AppColors.paper,
      ),

      // Headline — section headers, event titles
      headlineLarge: TextStyle(
        fontFamily: displayFamily,
        fontWeight: FontWeight.w700,
        fontSize: 24.sp,
        letterSpacing: -0.2.sp,
        color: AppColors.paper,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
        color: AppColors.paper,
      ),

      // Title — card titles
      titleLarge: TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w700,
        fontSize: 20.sp,
        color: AppColors.paper,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        color: AppColors.paper,
      ),

      // Labels — buttons, uppercase eyebrows, chips
      labelLarge: TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w700,
        fontSize: 15.sp,
        letterSpacing: 0.3.sp,
        color: AppColors.paper,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w600,
        fontSize: 12.sp,
        letterSpacing: 1.2.sp,
        color: AppColors.muted,
      ),
      labelSmall: TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w600,
        fontSize: 10.sp,
        letterSpacing: 1.4.sp,
        color: AppColors.muted,
      ),

      // Body
      bodyLarge: TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        height: 1.4,
        color: AppColors.paper,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
        height: 1.4,
        color: AppColors.muted,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w500,
        fontSize: 12.sp,
        color: AppColors.muted,
      ),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ground,
      primaryColor: AppColors.fuchsia,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.fuchsia,
        onPrimary: AppColors.onNeon,
        secondary: AppColors.lime,
        onSecondary: AppColors.onNeon,
        tertiary: AppColors.indigo,
        onTertiary: AppColors.paper,
        surface: AppColors.graphite,
        onSurface: AppColors.paper,
        error: AppColors.fuchsia,
      ),
      fontFamily: bodyFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w700,
          fontSize: 22.sp,
          letterSpacing: -0.3.sp,
          color: AppColors.paper,
        ),
        iconTheme: IconThemeData(color: AppColors.paper),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.graphite,
        selectedItemColor: AppColors.fuchsia,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 12.r,
        selectedLabelStyle: TextStyle(
          fontFamily: bodyFamily,
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
          letterSpacing: 0.6.sp,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: bodyFamily,
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
          letterSpacing: 0.4.sp,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.graphite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.lg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.fuchsia,
          foregroundColor: AppColors.onNeon,
          disabledBackgroundColor: AppColors.surfaceRaised,
          disabledForegroundColor: AppColors.muted,
          textStyle: TextStyle(
            fontFamily: bodyFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            letterSpacing: 0.3.sp,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.md),
          ),
          padding: EdgeInsets.symmetric(
            vertical: Insets.md,
            horizontal: Insets.xl,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lime,
          side: const BorderSide(color: AppColors.lime, width: 1.5),
          textStyle: TextStyle(
            fontFamily: bodyFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            letterSpacing: 0.3.sp,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.md),
          ),
          padding: EdgeInsets.symmetric(
            vertical: Insets.md,
            horizontal: Insets.lg,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lime,
          textStyle: TextStyle(
            fontFamily: bodyFamily,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            letterSpacing: 0.3.sp,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceRaised,
        hintStyle: TextStyle(
          fontFamily: bodyFamily,
          fontWeight: FontWeight.w500,
          fontSize: 15.sp,
          color: AppColors.muted,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Corners.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Corners.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Corners.md),
          borderSide: const BorderSide(color: AppColors.fuchsia, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: AppColors.paper, size: 22.r),
      splashColor: AppColors.fuchsia.withValues(alpha: 0.08),
      highlightColor: AppColors.fuchsia.withValues(alpha: 0.06),
    );
  }
}
