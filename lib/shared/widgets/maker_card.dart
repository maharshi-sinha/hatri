import 'package:flutter/material.dart';
import 'hatri_image.dart';
import 'package:flutter/services.dart';

import '../../core/models/makers.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// Editorial maker card. Same DNA as SmallEventCard so home rails read uniform.
///   1) Portrait poster — image dominant, status strip at the bottom fading right.
///   2) Meta row below — price band pill + name + neighborhood.
class MakerCard extends StatelessWidget {
  final Maker maker;
  final VoidCallback onTap;
  final bool isGrid;
  final bool isHero;

  const MakerCard({
    super.key,
    required this.maker,
    required this.onTap,
    this.isGrid = false,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final stripBg = maker.statusColor;
    final stripFg = stripBg == AppColors.lime || stripBg == AppColors.accentYellow
        ? AppColors.onNeon
        : AppColors.paper;

    final content = GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: isHero ? 0.92 : 0.78,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: AppColors.paper.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(Corners.md),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Corners.md - 1.5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    HatriImage(url: maker.portrait, fit: BoxFit.cover, errorWidget: Container(color: stripBg),
                    ),
                    // Primary tag chip, top-left
                    Positioned(
                      top: 10.r,
                      left: 10.r,
                      child: _TagChip(label: maker.primaryTag),
                    ),
                    // Verified check, top-right
                    if (maker.verified)
                      Positioned(
                        top: 10.r,
                        right: 10.r,
                        child: Container(
                          width: 20.r,
                          height: 20.r,
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.check_rounded,
                              size: 14.r, color: AppColors.onNeon),
                        ),
                      ),
                    // Status strip — fades right
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.r, vertical: 6.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              stripBg,
                              stripBg,
                              stripBg.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                        child: Text(
                          maker.statusLabel,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 11.sp,
                            letterSpacing: 0.6.sp,
                            color: stripFg,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10.r),
          Text(
            maker.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: isHero ? 18.sp : 15.sp,
              height: 1.05,
              letterSpacing: -0.4.sp,
              color: AppColors.paper,
            ),
          ),
          SizedBox(height: 4.r),
          Row(
            children: [
              Flexible(
                child: Text(
                  maker.neighborhood,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 11.sp,
                    color: AppColors.muted,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.r),
                child: Text('·', style: TextStyle(fontSize: 11.sp, color: AppColors.muted)),
              ),
              if (maker.reviewCount > 0) ...[
                Icon(Icons.star_rounded, size: 13.r, color: AppColors.accentYellow),
                SizedBox(width: 2.r),
                Text(
                  maker.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                    color: AppColors.paper,
                  ),
                ),
              ] else
                Text(
                  maker.priceBand,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    color: AppColors.paper.withValues(alpha: 0.85),
                  ),
                ),
            ],
          ),
          if (isHero) ...[
            SizedBox(height: 6.r),
            Text(
              maker.tagline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                height: 1.35,
                color: AppColors.paper.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );

    if (isGrid) return content;
    return Padding(
      padding: EdgeInsets.only(right: Insets.sm),
      child: SizedBox(width: isHero ? 240.r : 170.r, child: content),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: AppColors.ground.withValues(alpha: 0.7),
        border: Border.all(color: AppColors.paper.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w800,
          fontSize: 9.sp,
          letterSpacing: 1.2.sp,
          color: AppColors.paper,
        ),
      ),
    );
  }
}

