import 'package:flutter/material.dart';
import '../../shared/widgets/hatri_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/models/models.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import 'photo_viewer_screen.dart';

/// Instagram-style photo wall for a community's memory. Full-screen grid,
/// filter chips (everyone / just you / by event), tap-to-open swipe viewer.
class PhotoWallScreen extends StatefulWidget {
  final Community community;
  const PhotoWallScreen({super.key, required this.community});

  @override
  State<PhotoWallScreen> createState() => _PhotoWallScreenState();
}

class _PhotoWallScreenState extends State<PhotoWallScreen> {
  static const _kAll = '__ALL__';
  static const _kYou = '__YOU__';
  String _filter = _kAll;

  List<WallPhoto> get _allPhotos {
    final list = [...widget.community.wallPhotos];
    list.sort((a, b) => b.attendedAt.compareTo(a.attendedAt));
    return list;
  }

  List<String> get _eventKeys {
    final s = <String>{};
    for (final p in _allPhotos) {
      s.add(p.eventTitle);
    }
    return s.toList();
  }

  List<WallPhoto> get _filtered {
    switch (_filter) {
      case _kAll:
        return _allPhotos;
      case _kYou:
        return _allPhotos.where((p) => p.youAreIn).toList();
      default:
        return _allPhotos.where((p) => p.eventTitle == _filter).toList();
    }
  }

  void _openViewer(int index) {
    HapticFeedback.selectionClick();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          photos: _filtered,
          initialIndex: index,
          communityName: widget.community.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = _filtered;
    final total = _allPhotos.length;
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(total),
          SliverToBoxAdapter(child: _buildFilters()),
          if (photos.isEmpty)
            SliverToBoxAdapter(child: _buildEmpty()),
          if (photos.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(8.r, 10.r, 8.r, 40.r),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8.r,
                crossAxisSpacing: 8.r,
                childCount: photos.length,
                itemBuilder: (context, i) {
                  final p = photos[i];
                  final size = _bentoSize(i);
                  return _BentoCell(
                    photo: p,
                    span: size,
                    onTap: () => _openViewer(i),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(int total) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.ground,
      surfaceTintColor: AppColors.ground,
      automaticallyImplyLeading: false,
      toolbarHeight: 64.r,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
              },
              child: Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(Corners.md),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/arrow-left.svg',
                    width: 20.r,
                    height: 20.r,
                    colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 6.r),
                      Text(
                        'WALL · $total MOMENTS',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                          letterSpacing: 1.6.sp,
                          color: AppColors.lime,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    widget.community.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      height: 1.0,
                      letterSpacing: -0.4.sp,
                      color: AppColors.paper,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final events = _eventKeys;
    return SizedBox(
      height: 42.r,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(Insets.lg, 8.r, Insets.lg, 4.r),
        children: [
          _filterChip('EVERYONE', _filter == _kAll, () => setState(() => _filter = _kAll)),
          SizedBox(width: 8.r),
          _filterChip('JUST YOU', _filter == _kYou, () => setState(() => _filter = _kYou), accent: AppColors.lime),
          SizedBox(width: 8.r),
          for (final e in events) ...[
            _filterChip(e.toUpperCase(), _filter == e, () => setState(() => _filter = e)),
            SizedBox(width: 8.r),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap, {Color? accent}) {
    final active = accent ?? AppColors.fuchsia;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? active : AppColors.surfaceRaised,
          border: Border.all(color: selected ? active : AppColors.border),
          borderRadius: BorderRadius.circular(Corners.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w800,
            fontSize: 10.sp,
            letterSpacing: 1.2.sp,
            color: selected ? AppColors.onNeon : AppColors.paper,
          ),
        ),
      ),
    );
  }

  /// Rotates through bento cell sizes so the grid feels alive.
  /// Pattern (per 5 photos): big square → tall → short → wide → medium.
  _BentoSpan _bentoSize(int i) {
    const pattern = [
      _BentoSpan(cross: 2, aspect: 1.0),   // big square (2x2)
      _BentoSpan(cross: 2, aspect: 0.72),  // tall (2 wide, taller)
      _BentoSpan(cross: 2, aspect: 1.6),   // wide (2 wide, short)
      _BentoSpan(cross: 2, aspect: 1.0),   // big square
      _BentoSpan(cross: 2, aspect: 0.85),  // slightly tall
      _BentoSpan(cross: 2, aspect: 1.3),   // wide-ish
      _BentoSpan(cross: 2, aspect: 1.0),   // square
    ];
    return pattern[i % pattern.length];
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 60.r, Insets.lg, 20.r),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌱', style: TextStyle(fontSize: 32.sp)),
            SizedBox(height: 12.r),
            Text(
              'NOTHING HERE YET',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 16.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              _filter == _kYou
                  ? "you're not tagged in any photos yet. show up + get tagged."
                  : 'no photos for this event yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}

/// A bento cell size — controls how the photo fills its slot.
class _BentoSpan {
  final int cross;   // columns to span in the 4-col grid
  final double aspect; // width / height of the cell
  const _BentoSpan({required this.cross, required this.aspect});
}

/// A single bento tile — photo with optional YOU badge, sized by [_BentoSpan].
class _BentoCell extends StatelessWidget {
  final WallPhoto photo;
  final _BentoSpan span;
  final VoidCallback onTap;
  const _BentoCell({required this.photo, required this.span, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: span.aspect,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Corners.sm),
          child: Stack(
            fit: StackFit.expand,
            children: [
              HatriImage(url: photo.photoUrl, fit: BoxFit.cover, errorWidget: Container(color: AppColors.surfaceRaised),
              ),
              if (photo.youAreIn)
                Positioned(
                  top: 6.r,
                  right: 6.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(Corners.pill),
                    ),
                    child: Text(
                      'YOU',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 8.sp,
                        letterSpacing: 1.0.sp,
                        color: AppColors.onNeon,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
