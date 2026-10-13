import 'package:flutter/material.dart';
import 'hatri_image.dart';
import 'package:flutter/services.dart';

import '../../core/models/makers.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../design/motifs.dart';

/// The city page's editorial hook. Rotates weekly. Bounded, curated, punchy.
/// Same visual DNA as the home hero deck — sticker shadow + halftone + Clash
/// title. Compact: fits above the filter chip row without pushing the grid
/// too far down.
class WeeklyIssueCard extends StatelessWidget {
  final WeeklyIssue issue;
  final void Function(WeeklyIssue issue) onTap;

  const WeeklyIssueCard({super.key, required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = issue.accent;
    final onAccent = (accent == AppColors.lime || accent == AppColors.accentYellow)
        ? AppColors.onNeon
        : AppColors.paper;
    final makers = issue.makerIds
        .map((id) => AppMakers.all.firstWhere((m) => m.id == id))
        .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.sm),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(issue);
        },
        child: StickerShadow(
          color: issue.shadowAccent,
          offset: Offset(5.r, 5.r),
          radius: Corners.lg,
          child: Container(
            padding: EdgeInsets.fromLTRB(18.r, 16.r, 18.r, 16.r),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(Corners.lg),
              border: Border.all(color: AppColors.onNeon, width: 1.5),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.10,
                    child: HalftoneBackground(
                      dotColor: onAccent,
                      spacing: 10.r,
                      dotSize: 2,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _IssueBadge(week: issue.weekNumber, onAccent: onAccent),
                        SizedBox(width: 8.r),
                        Text(
                          'THIS WEEK IN RAIPUR',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 10.sp,
                            letterSpacing: 1.6.sp,
                            color: onAccent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.r),
                    Text(
                      issue.title,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 30.sp,
                        height: 0.92,
                        letterSpacing: -1.2.sp,
                        color: onAccent,
                      ),
                    ),
                    SizedBox(height: 10.r),
                    Text(
                      issue.blurb,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        height: 1.35,
                        color: onAccent.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 14.r),
                    Row(
                      children: [
                        _PortraitStack(portraits: makers.take(5).map((m) => m.portrait).toList(), accent: accent),
                        SizedBox(width: 10.r),
                        Text(
                          '${makers.length} makers',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 11.sp,
                            letterSpacing: 1.sp,
                            color: onAccent,
                          ),
                        ),
                        const Spacer(),
                        _CtaChip(label: 'SEE THE ISSUE', accent: accent, onAccent: onAccent),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IssueBadge extends StatelessWidget {
  final int week;
  final Color onAccent;
  const _IssueBadge({required this.week, required this.onAccent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: onAccent,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        'WK $week',
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w800,
          fontSize: 9.sp,
          letterSpacing: 1.4.sp,
          color: onAccent == AppColors.onNeon ? AppColors.lime : AppColors.onNeon,
        ),
      ),
    );
  }
}

class _PortraitStack extends StatelessWidget {
  final List<String> portraits;
  final Color accent;
  const _PortraitStack({required this.portraits, required this.accent});

  @override
  Widget build(BuildContext context) {
    const overlap = 12.0;
    final size = 30.r;
    return SizedBox(
      width: size + (portraits.length - 1) * (size - overlap),
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < portraits.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 2),
                ),
                child: ClipOval(
                  child: HatriImage(url: portraits[i], fit: BoxFit.cover, errorWidget: Container(color: AppColors.surface),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CtaChip extends StatelessWidget {
  final String label;
  final Color accent;
  final Color onAccent;
  const _CtaChip({required this.label, required this.accent, required this.onAccent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: onAccent,
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 10.sp,
              letterSpacing: 1.2.sp,
              color: accent,
            ),
          ),
          SizedBox(width: 4.r),
          Icon(Icons.arrow_forward, size: 12.r, color: accent),
        ],
      ),
    );
  }
}
