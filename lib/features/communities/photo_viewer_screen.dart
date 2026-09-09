import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/models/models.dart';
import '../../core/reports/reports_store.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/report_sheet.dart';

/// Full-screen swipeable photo viewer for the Memory Wall.
/// Horizontal swipe changes photo. Progress bar at top, editorial caption
/// bottom-heavy with attribution and like action.
class PhotoViewerScreen extends StatefulWidget {
  final List<WallPhoto> photos;
  final int initialIndex;
  final String communityName;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.communityName,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _index = i);
    HapticFeedback.selectionClick();
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays > 30) return '${(d.inDays / 30).floor()} MO AGO';
    if (d.inDays > 0) return '${d.inDays} DAY${d.inDays == 1 ? '' : 'S'} AGO';
    if (d.inHours > 0) return '${d.inHours}H AGO';
    return 'JUST NOW';
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_index];
    final total = widget.photos.length;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── PHOTO PAGER ────────────────────────────────────────────
          // Photo bottom-aligns just above the overlay content so the caption
          // sits ~10r under the image instead of floating in a big black gap.
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60.r,
              bottom: MediaQuery.of(context).padding.bottom + 260.r,
            ),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: total,
              itemBuilder: (context, i) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Image.network(
                      widget.photos[i].photoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Container(color: AppColors.surfaceRaised),
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── TOP: progress bar + back + counter ──────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.r,
            left: Insets.lg,
            right: Insets.lg,
            child: Column(
              children: [
                // Story-style progress segments
                _ProgressSegments(total: total, currentIndex: _index),
                SizedBox(height: 14.r),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _chip(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(
                        'assets/icons/arrow-left.svg',
                        width: 20.r,
                        height: 20.r,
                        colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            border: Border.all(color: AppColors.paper.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(Corners.pill),
                          ),
                          child: Text(
                            '${(_index + 1).toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                              letterSpacing: 0.8.sp,
                              color: AppColors.paper,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.r),
                        _chip(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ReportSheet.show(
                              context,
                              target: ReportTarget.wallPost,
                              targetId: photo.id,
                              subjectLabel: 'this post',
                            );
                          },
                          child: Icon(
                            Icons.flag_outlined,
                            size: 18.r,
                            color: AppColors.paper,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── BOTTOM: editorial caption + attribution row ────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                Insets.lg,
                18.r,
                Insets.lg,
                MediaQuery.of(context).padding.bottom + 100.r,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Editorial caption — big display type, sets the mood
                  if (photo.caption != null) ...[
                    Text(
                      photo.caption!,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w600,
                        fontSize: 22.sp,
                        height: 1.15,
                        letterSpacing: -0.4.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    SizedBox(height: 18.r),
                  ],
                  // Editorial rule — 2pt accent hairline separator
                  Container(
                    width: 32.r,
                    height: 2.r,
                    color: AppColors.fuchsia,
                  ),
                  SizedBox(height: 14.r),
                  // Attribution + inline meta + like button, one clean row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar with a fuchsia ring
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.fuchsia, width: 1.6),
                        ),
                        child: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: AppColors.surfaceRaised,
                          backgroundImage: photo.byUserAvatarUrl != null
                              ? NetworkImage(photo.byUserAvatarUrl!)
                              : null,
                        ),
                      ),
                      SizedBox(width: 12.r),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Editorial eyebrow "SHOT BY"
                            Text(
                              'SHOT BY',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 9.sp,
                                letterSpacing: 1.6.sp,
                                color: AppColors.fuchsia,
                              ),
                            ),
                            SizedBox(height: 2.r),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    photo.byUserName.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'ClashDisplay',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17.sp,
                                      height: 1.0,
                                      letterSpacing: -0.4.sp,
                                      color: AppColors.paper,
                                    ),
                                  ),
                                ),
                                if (photo.youAreIn) ...[
                                  SizedBox(width: 8.r),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 2.r),
                                    decoration: BoxDecoration(
                                      color: AppColors.lime,
                                      borderRadius: BorderRadius.circular(Corners.pill),
                                    ),
                                    child: Text(
                                      'YOU',
                                      style: TextStyle(
                                        fontFamily: 'GeneralSans',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 9.sp,
                                        letterSpacing: 1.0.sp,
                                        color: AppColors.onNeon,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 6.r),
                            // Meta: event · time-ago
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    photo.eventTitle.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _metaStyle(),
                                  ),
                                ),
                                SizedBox(width: 6.r),
                                _dot(),
                                SizedBox(width: 6.r),
                                Text(_ago(photo.attendedAt), style: _metaStyle()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _metaStyle() => TextStyle(
        fontFamily: 'GeneralSans',
        fontWeight: FontWeight.w700,
        fontSize: 10.sp,
        letterSpacing: 0.8.sp,
        color: AppColors.paper.withValues(alpha: 0.65),
      );

  Widget _dot() => Container(
        width: 3.r,
        height: 3.r,
        decoration: BoxDecoration(
          color: AppColors.paper.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
      );

  Widget _chip({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.r,
        height: 42.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          border: Border.all(color: AppColors.paper.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: child,
      ),
    );
  }
}

/// Story-style progress bar: one segment per photo, current one lit, past ones
/// filled, future ones dim. Caps at 30 segments so it doesn't feel micro.
class _ProgressSegments extends StatelessWidget {
  final int total;
  final int currentIndex;
  const _ProgressSegments({required this.total, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final segments = total > 30 ? 30 : total;
    final currentSeg = (currentIndex * segments / total).floor();
    return SizedBox(
      height: 3.r,
      child: Row(
        children: List.generate(segments, (i) {
          final filled = i < currentSeg;
          final active = i == currentSeg;
          Color color;
          if (active) {
            color = AppColors.paper;
          } else if (filled) {
            color = AppColors.paper.withValues(alpha: 0.55);
          } else {
            color = AppColors.paper.withValues(alpha: 0.18);
          }
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.r),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }
}
