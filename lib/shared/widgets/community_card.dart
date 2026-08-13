import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../design/components.dart';
import '../design/motifs.dart';
import '../../core/responsive/responsive.dart';

/// Community card — pop-brutalist. Cover with halftone, type badge, big name,
/// member avatars + "next meetup" line if a next event is attached.
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

    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.graphite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        clipBehavior: Clip.antiAlias,
        child: AdaptiveCardBody(
          aspectRatio: 16 / 10,
          // Cover with halftone + emoji medallion + type badge
          cover: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  community.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: accent),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(color: AppColors.surfaceRaised);
                  },
                ),
                // Halftone tint
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.18,
                    child: HalftoneBackground(
                      dotColor: AppColors.onNeon,
                      spacing: 8.r,
                      dotSize: 1.5,
                    ),
                  ),
                ),
                // Bottom accent bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(height: 3, color: accent),
                ),
                // Type badge (top-left)
                Positioned(
                  top: 10.r,
                  left: 10.r,
                  child: CategoryTag(
                    label: community.type.label,
                    color: accent,
                  ),
                ),
                // Emoji medallion (top-right)
                Positioned(
                  top: 8.r,
                  right: 8.r,
                  child: Container(
                    width: 34.r,
                    height: 34.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.ground.withValues(alpha: 0.7),
                      border: Border.all(color: AppColors.onNeon.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(Corners.sm),
                    ),
                    child: Text(community.emoji, style: TextStyle(fontSize: 18.sp)),
                  ),
                ),
              ],
            ),
          body: Padding(
              padding: EdgeInsets.fromLTRB(12.r, 12.r, 12.r, 12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    community.name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      height: 1.02,
                      letterSpacing: -0.2.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  if (community.location != null) ...[
                    SizedBox(height: 4.r),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/Location.svg',
                          width: 11.r,
                          height: 11.r,
                          colorFilter: const ColorFilter.mode(AppColors.muted, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            community.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 10.r),
                  _buildMembersRow(accent),
                  if (nextEventLabel != null) ...[
                    SizedBox(height: 8.r),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 5.r),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(Corners.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_rounded, size: 11.r, color: accent),
                          SizedBox(width: 4.r),
                          Flexible(
                            child: Text(
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ),
      ),
    );

    if (isGrid) return card;
    return Padding(
      padding: EdgeInsets.only(right: Insets.sm),
      child: SizedBox(width: 220.r, child: card),
    );
  }

  Widget _buildMembersRow(Color accent) {
    final avatars = community.memberAvatars.take(4).toList();
    final memberLabel = _formatCount(community.memberCount);

    return Row(
      children: [
        if (avatars.isNotEmpty) ...[
          SizedBox(
            // Tight fit: last avatar starts at 15*(n-1), extends 18px, plus a
            // 2px cushion so the ring doesn't touch the text.
            width: 15.0.r * (avatars.length - 1) + 20,
            height: 22.r,
            child: Stack(
              children: [
                for (int i = 0; i < avatars.length; i++)
                  Positioned(
                    left: (i * 15).toDouble(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.graphite, width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 9.r,
                        backgroundColor: AppColors.surfaceRaised,
                        backgroundImage: NetworkImage(avatars[i].avatarUrl),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 6.r),
        ],
        Flexible(
          child: Text(
            '$memberLabel members',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w700,
              fontSize: 11.sp,
              color: AppColors.paper,
            ),
          ),
        ),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
