import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../design/components.dart';
import '../../core/responsive/responsive.dart';

/// Compact event card — image-forward with color-block header stripe.
/// Used in dense rails, grids and "This Week" lists.
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

    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.graphite,
          borderRadius: BorderRadius.circular(Corners.md),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: AdaptiveCardBody(
          aspectRatio: isGrid ? 4 / 3 : 16 / 9,
          // Cover with a color-block header stripe
          cover: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  event.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: accent),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(height: 4.r, color: accent),
                ),
                Positioned(
                  top: 10.r,
                  left: 10.r,
                  child: CategoryTag(label: event.category.label, color: accent),
                ),
              ],
            ),
          body: Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reserve height for exactly 2 lines so cards stay consistent
                  // whether the title wraps or fits on one line.
                  SizedBox(
                    height: 16.sp * 1.02 * 2,
                    child: Text(
                      event.title.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        height: 1.02,
                        letterSpacing: -0.2.sp,
                        color: AppColors.paper,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Text(
                    '${DateFormat('EEE, MMM d').format(event.date).toUpperCase()} · ${event.time}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                      letterSpacing: 0.8.sp,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
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
        ),
      ),
    );

    if (isGrid) return card;
    return Padding(
      padding: EdgeInsets.only(right: Insets.sm),
      child: SizedBox(width: 200.r, child: card),
    );
  }
}
