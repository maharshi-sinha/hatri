import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../design/components.dart';
import '../../core/responsive/responsive.dart';
import 'hatri_image.dart';

/// Editorial event card. Two visual blocks:
///   1) Poster card — image dominant, colored price strip at the bottom.
///   2) Meta row below the card — square date badge + title + venue.
class SmallEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final bool isGrid;

  const SmallEventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromHex(event.colorHex);
    final isFree = event.isFree;
    final stripBg = isFree ? AppColors.lime : AppColors.fuchsia;
    final stripFg = isFree ? AppColors.onNeon : AppColors.paper;
    final priceText = isFree ? 'FREE ENTRY' : 'STARTS AT ${event.priceLabel}';

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
          // ─── POSTER CARD ─────────────────────────────────────────────
          // Two-layer border: outer Container = colored frame, inner ClipRRect
          // holds the image. This keeps the corners crisp (no anti-alias bleed
          // between border and clipped content).
          AspectRatio(
            aspectRatio: 0.78,
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
                    HatriImage(
                      url: event.coverUrl,
                      fit: BoxFit.cover,
                      errorWidget: Container(color: accent),
                    ),
                    // Category chip, top-left
                    Positioned(
                      top: 10.r,
                      left: 10.r,
                      child: CategoryTag(label: event.category.label, color: accent),
                    ),
                    // Price strip — solid left fading to transparent on right
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 6.r),
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
                          priceText,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 12.sp,
                            letterSpacing: 0.6.sp,
                            color: stripFg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10.r),
          // ─── META ROW (date badge + title + venue) ───────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateBadge(date: event.date),
              SizedBox(width: 10.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 14.sp * 1.1 * 2,
                      child: Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          height: 1.1,
                          letterSpacing: -0.2.sp,
                          color: AppColors.paper,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      event.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isGrid) return content;
    return Padding(
      padding: EdgeInsets.only(right: Insets.sm),
      child: SizedBox(width: 200.r, child: content),
    );
  }
}

/// Square date badge — day number over short month label.
class _DateBadge extends StatelessWidget {
  final DateTime date;
  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('d').format(date);
    final month = DateFormat('MMM').format(date).toUpperCase();
    return Container(
      width: 46.r,
      height: 46.r,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
              height: 1.0,
              letterSpacing: -0.6.sp,
              color: AppColors.paper,
            ),
          ),
          SizedBox(height: 2.r),
          Text(
            month,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 9.sp,
              letterSpacing: 1.4.sp,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
