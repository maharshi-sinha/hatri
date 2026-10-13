import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// How long we wait before a shimmer is actually painted. Keeps fast loads
/// (<300 ms) from flashing a skeleton for a single frame — the viewer sees
/// content appear directly instead. Slow loads see the skeleton smoothly
/// fade in once the timer fires.
const _shimmerDelay = Duration(milliseconds: 300);

/// Wraps a widget behind a 300ms timer. If the parent widget rebuilds with
/// real content before the timer fires, nothing is shown. Prevents the
/// "flash of skeleton" that happens when loads are nearly instant.
///
/// Pattern used by every public skeleton in this file.
class _DelayedShimmer extends StatefulWidget {
  final Widget child;
  const _DelayedShimmer({required this.child});

  @override
  State<_DelayedShimmer> createState() => _DelayedShimmerState();
}

class _DelayedShimmerState extends State<_DelayedShimmer> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_shimmerDelay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 180),
      child: widget.child,
    );
  }
}

/// Low-level shimmer primitive — a rounded rectangle that pulses.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceRaised,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Shaped like a small event card: cover block on top, two text lines below.
class ShimmerEventCard extends StatelessWidget {
  const ShimmerEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(height: 140.r, radius: Corners.md.toDouble()),
        SizedBox(height: 10.r),
        ShimmerBox(height: 14.r, radius: 6, width: double.infinity),
        SizedBox(height: 8.r),
        ShimmerBox(height: 11.r, radius: 6, width: 140.r),
      ],
    );
  }
}

/// Horizontal event card — cover on the left, text on the right.
/// Used in home screen horizontal strips.
class ShimmerEventRow extends StatelessWidget {
  const ShimmerEventRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox(width: 110.r, height: 110.r, radius: Corners.md.toDouble()),
        SizedBox(width: 14.r),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 14.r, radius: 6, width: double.infinity),
              SizedBox(height: 8.r),
              ShimmerBox(height: 12.r, radius: 6, width: 180.r),
              SizedBox(height: 6.r),
              ShimmerBox(height: 11.r, radius: 6, width: 120.r),
            ],
          ),
        ),
      ],
    );
  }
}

/// Community / scene tile skeleton.
class ShimmerCommunityTile extends StatelessWidget {
  const ShimmerCommunityTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 48.r, height: 48.r, radius: 12),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14.r, radius: 6, width: 150.r),
                SizedBox(height: 8.r),
                ShimmerBox(height: 11.r, radius: 6, width: 200.r),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero block for a creator / organizer profile — avatar circle, name,
/// bio line, follow button block.
class ShimmerCreatorHero extends StatelessWidget {
  const ShimmerCreatorHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.r),
        Shimmer.fromColors(
          baseColor: AppColors.surface,
          highlightColor: AppColors.surfaceRaised,
          period: const Duration(milliseconds: 1200),
          child: Container(
            width: 96.r,
            height: 96.r,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(height: 16.r),
        ShimmerBox(height: 22.r, radius: 6, width: 180.r),
        SizedBox(height: 10.r),
        ShimmerBox(height: 12.r, radius: 6, width: 240.r),
        SizedBox(height: 24.r),
        ShimmerBox(height: 44.r, radius: Corners.md.toDouble(), width: double.infinity),
      ],
    );
  }
}

/// Vertical list of event cards.
class ShimmerEventGrid extends StatelessWidget {
  final int count;
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;
  const ShimmerEventGrid({
    super.key,
    this.count = 6,
    this.padding = EdgeInsets.zero,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return _DelayedShimmer(
      child: GridView.builder(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16.r,
          crossAxisSpacing: 14.r,
          childAspectRatio: 0.72,
        ),
        itemCount: count,
        itemBuilder: (_, _) => const ShimmerEventCard(),
      ),
    );
  }
}

/// Vertical stack of horizontal rows — for home-style lists.
class ShimmerEventStack extends StatelessWidget {
  final int count;
  final EdgeInsetsGeometry padding;
  const ShimmerEventStack({
    super.key,
    this.count = 4,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return _DelayedShimmer(
      child: Padding(
        padding: padding,
        child: Column(
          children: List.generate(
            count,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 16.r),
              child: const ShimmerEventRow(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical stack of community tiles.
class ShimmerCommunityStack extends StatelessWidget {
  final int count;
  final EdgeInsetsGeometry padding;
  const ShimmerCommunityStack({
    super.key,
    this.count = 5,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return _DelayedShimmer(
      child: Padding(
        padding: padding,
        child: Column(
          children: List.generate(
            count,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 12.r),
              child: const ShimmerCommunityTile(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full creator-profile skeleton: hero + 3 event cards below.
class ShimmerCreatorProfile extends StatelessWidget {
  const ShimmerCreatorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return _DelayedShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShimmerCreatorHero(),
            SizedBox(height: 32.r),
            ShimmerBox(height: 14.r, radius: 6, width: 120.r),
            SizedBox(height: 14.r),
            const ShimmerEventRow(),
            SizedBox(height: 16.r),
            const ShimmerEventRow(),
            SizedBox(height: 16.r),
            const ShimmerEventRow(),
          ],
        ),
      ),
    );
  }
}
