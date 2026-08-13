import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';

/// Primary CTA — solid fuchsia, high impact.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// SVG asset path, for the icons that ship as artwork rather than [IconData].
  /// Takes precedence over [icon] when both are supplied.
  final String? svgIcon;
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.svgIcon,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svgIcon != null) ...[
            SvgPicture.asset(
              svgIcon!,
              width: 18.r,
              height: 18.r,
              colorFilter: const ColorFilter.mode(AppColors.onNeon, BlendMode.srcIn),
            ),
            SizedBox(width: Insets.xs),
          ] else if (icon != null) ...[
            Icon(icon, size: 18.r, color: AppColors.onNeon),
            SizedBox(width: Insets.xs),
          ],
          Text(label.toUpperCase()),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Secondary CTA — lime outline on dark ground.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18.r, color: AppColors.lime),
            SizedBox(width: Insets.xs),
          ],
          Text(label.toUpperCase()),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Selectable filter chip — pill, with clear active/inactive states.
class FilterChipX extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;

  const FilterChipX({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.lime;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
        // These chips live in fixed-height horizontal ListViews, which hand the
        // container a tight height. Without an alignment that tight constraint
        // reaches the Text, which then paints at the top of its box instead of
        // the middle. Centering here shrink-wraps the width and centres the label.
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? active : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(Corners.pill),
          border: Border.all(
            color: selected ? active : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
            letterSpacing: 0.8.sp,
            color: selected ? AppColors.onNeon : AppColors.paper,
          ),
        ),
      ),
    );
  }
}

/// Category tag — small, pill, category-colored.
class CategoryTag extends StatelessWidget {
  final String label;
  final Color color;

  const CategoryTag({super.key, required this.label, this.color = AppColors.indigo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
          letterSpacing: 1.2.sp,
          color: color.computeLuminance() > 0.5 ? AppColors.onNeon : AppColors.paper,
        ),
      ),
    );
  }
}

/// LIVE pill — pulsing lime dot, "LIVE" label.
class LivePill extends StatefulWidget {
  final String label;
  const LivePill({super.key, this.label = 'LIVE'});

  @override
  State<LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<LivePill> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
      decoration: BoxDecoration(
        color: AppColors.onNeon,
        borderRadius: BorderRadius.circular(Corners.pill),
        border: Border.all(color: AppColors.lime, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _c,
            child: Container(
              width: 7.r,
              height: 7.r,
              decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
            ),
          ),
          SizedBox(width: 6.r),
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 10.sp,
              letterSpacing: 1.4.sp,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }
}

/// Verified badge — small check mark, fuchsia.
class VerifiedBadge extends StatelessWidget {
  final double size;
  const VerifiedBadge({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.fuchsia, shape: BoxShape.circle),
      child: Icon(Icons.check, size: size * 0.7, color: AppColors.onNeon),
    );
  }
}

/// Star rating display (read-only for now).
class StarRating extends StatelessWidget {
  final double rating; // 0..5
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 14,
    this.color = AppColors.lime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/icons/Star.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w700,
            fontSize: size * 0.85,
            color: AppColors.paper,
          ),
        ),
      ],
    );
  }
}

/// Safe-venue chip — indigo, shield icon.
class SafeVenueChip extends StatelessWidget {
  const SafeVenueChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: AppColors.indigo,
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/Shield.svg',
            width: 12.r,
            height: 12.r,
            colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
          ),
          SizedBox(width: 4.r),
          Text(
            'SAFE VENUE',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w700,
              fontSize: 9.sp,
              letterSpacing: 1.2.sp,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }
}

/// Editorial section header — big display type + eyebrow + optional action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color accent;

  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.actionLabel,
    this.onAction,
    this.accent = AppColors.fuchsia,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.r),
                    child: Text(
                      eyebrow!.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                        letterSpacing: 1.5.sp,
                        color: accent,
                      ),
                    ),
                  ),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 26.sp,
                    letterSpacing: -0.4.sp,
                    height: 1.0,
                    color: AppColors.paper,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!.toUpperCase()),
            ),
        ],
      ),
    );
  }
}

/// Card body layout for the `Column[cover image, text block]` shape.
///
/// These cards are used two different ways:
///
///  * height-bounded — a horizontal rail (`SizedBox(height: 380)`), a grid cell
///    with a fixed `childAspectRatio`, or a `PageView`. Here an [AspectRatio]
///    cover is a bug: its height grows with the card's *width*, so on a wider
///    screen it pushes the text block past the bottom edge and the Column
///    overflows.
///  * height-unbounded — inside a scrolling `Column`, where the card sizes to
///    its content. Here [Expanded] is a bug: it throws on unbounded constraints.
///
/// So the choice has to be made at layout time, not authoring time.
class AdaptiveCardBody extends StatelessWidget {
  const AdaptiveCardBody({
    super.key,
    required this.aspectRatio,
    required this.cover,
    required this.body,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Cover ratio used only when the card's height is unbounded.
  final double aspectRatio;
  final Widget cover;
  final Widget body;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.maxHeight.isFinite;
        return Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (bounded)
              Expanded(child: cover)
            else
              AspectRatio(aspectRatio: aspectRatio, child: cover),
            body,
          ],
        );
      },
    );
  }
}
