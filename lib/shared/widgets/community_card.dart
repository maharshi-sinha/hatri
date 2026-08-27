import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../design/components.dart';
import '../../core/responsive/responsive.dart';

/// Editorial community card. Matches the small event card treatment:
/// poster-first image with neutral hairline border, a fading gradient strip
/// inside the card showing member count, and a meta row below the card
/// with title + location.
class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback onTap;
  final String? nextEventLabel; // e.g. "Sun · Photo walk"
  final bool isGrid;

  const CommunityCard({
    super.key,
    required this.community,
    required this.onTap,
    this.nextEventLabel,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromHex(community.type.colorHex);
    final memberLabel = _formatCount(community.memberCount);

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
          AspectRatio(
            aspectRatio: 0.82,
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
                    Image.network(
                      community.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: accent),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(color: AppColors.surfaceRaised);
                      },
                    ),
                    // Type chip, top-left
                    Positioned(
                      top: 10.r,
                      left: 10.r,
                      child: CategoryTag(label: community.type.label, color: accent),
                    ),
                    // Member-count strip — accent color left, fading right
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
                            colors: [accent, accent, accent.withValues(alpha: 0.0)],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Text(
                          '$memberLabel MEMBERS',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 12.sp,
                            letterSpacing: 0.6.sp,
                            color: AppColors.onNeon,
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
          // ─── META ROW (title + location) ─────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 14.sp * 1.1 * 2,
                  child: Text(
                    community.name,
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
                SizedBox(height: 4.r),
                if (community.location != null)
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Location.svg',
                        width: 11.r,
                        height: 11.r,
                        colorFilter: const ColorFilter.mode(AppColors.muted, BlendMode.srcIn),
                      ),
                      SizedBox(width: 3.r),
                      Flexible(
                        child: Text(
                          community.location!,
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
                    ],
                  )
                else if (nextEventLabel != null)
                  Text(
                    'NEXT · ${nextEventLabel!.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 10.sp,
                      letterSpacing: 0.8.sp,
                      color: accent,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isGrid) return content;
    return Padding(
      padding: EdgeInsets.only(right: Insets.sm),
      child: SizedBox(width: 220.r, child: content),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
