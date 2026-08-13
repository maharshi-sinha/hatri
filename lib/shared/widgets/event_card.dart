import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../design/components.dart';
import '../design/motifs.dart';
import '../../core/responsive/responsive.dart';

/// Hero event card — poster-brutalist. Full color-block, oversized title,
/// sticker overlays, hard-offset shadow. Used in horizontal rails.
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final bool isHorizontal;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    final blockColor = AppColors.fromHex(event.colorHex);
    final onBlock = blockColor.computeLuminance() > 0.55
        ? AppColors.onNeon
        : AppColors.paper;
    final softOnBlock =
        blockColor.computeLuminance() > 0.55 ? AppColors.onNeon : AppColors.paper.withValues(alpha: 0.72);

    return Padding(
      padding: EdgeInsets.only(
        right: isHorizontal ? Insets.md : 0,
        bottom: isHorizontal ? 8 : 0, // room for the offset shadow
        top: 4.r,
      ),
      child: SizedBox(
        width: isHorizontal ? 240 : double.infinity,
        child: StickerShadow(
          color: AppColors.onNeon,
          offset: Offset(5.r, 5.r),
          radius: Corners.lg,
          child: GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Corners.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: blockColor,
                  border: Border.all(color: AppColors.onNeon, width: 1.4),
                  borderRadius: BorderRadius.circular(Corners.lg),
                ),
                child: AdaptiveCardBody(
                  aspectRatio: 16 / 10,
                  // Cover with sticker overlays + halftone
                  cover: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          event.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: blockColor),
                        ),
                        // Halftone overlay tint
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.18,
                            child: HalftoneBackground(
                              dotColor: AppColors.onNeon,
                              spacing: 8.r,
                              dotSize: 1.6,
                            ),
                          ),
                        ),
                        // Corner sticker labels
                        Positioned(
                          top: 10.r,
                          left: 10.r,
                          child: Row(
                            children: [
                              if (event.isHot)
                                const StickerLabel(
                                  text: 'HOT 🔥',
                                  background: AppColors.lime,
                                  foreground: AppColors.onNeon,
                                ),
                              if (event.isHot && event.isTrending) SizedBox(width: 6.r),
                              if (event.isTrending)
                                const StickerLabel(
                                  text: 'TRENDING',
                                  background: AppColors.fuchsia,
                                  foreground: AppColors.paper,
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10.r,
                          right: 10.r,
                          child: StickerLabel(
                            text: event.isFree ? 'FREE' : 'PAID',
                            background: event.isFree ? AppColors.lime : AppColors.fuchsia,
                            foreground: event.isFree ? AppColors.onNeon : AppColors.paper,
                          ),
                        ),
                      ],
                    ),
                  // Content block
                  body: Padding(
                      padding: EdgeInsets.fromLTRB(14.r, 14.r, 14.r, 14.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CategoryTag(
                                label: event.category.label,
                                color: AppColors.onNeon,
                              ),
                              const Spacer(),
                              if (event.isSafeVenue)
                                SvgPicture.asset(
                                  'assets/icons/Shield.svg',
                                  width: 14.r,
                                  height: 14.r,
                                  colorFilter: ColorFilter.mode(softOnBlock, BlendMode.srcIn),
                                ),
                            ],
                          ),
                          SizedBox(height: 10.r),
                          // Reserve height for exactly 2 lines of title so
                          // cards stay consistent whether the title wraps or not.
                          SizedBox(
                            height: 22.sp * 0.98 * 2,
                            child: Text(
                              event.title.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'ClashDisplay',
                                fontWeight: FontWeight.w700,
                                fontSize: 22.sp,
                                height: 0.98,
                                letterSpacing: -0.4.sp,
                                color: onBlock,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.r),
                          Text(
                            '${DateFormat('EEE, MMM d').format(event.date).toUpperCase()} · ${event.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 11.sp,
                              letterSpacing: 0.8.sp,
                              color: softOnBlock,
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
                              fontSize: 12.sp,
                              color: softOnBlock,
                            ),
                          ),
                          SizedBox(height: 10.r),
                          Row(
                            children: [
                              _pulseDot(onBlock),
                              SizedBox(width: 6.r),
                              Text(
                                '${event.rsvpCount} going',
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.sp,
                                  color: onBlock,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pulseDot(Color color) => Container(
        width: 8.r,
        height: 8.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6.r)],
        ),
      );
}
