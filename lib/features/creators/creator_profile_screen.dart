import 'package:flutter/material.dart';
import '../../shared/widgets/hatri_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/di/injection_container.dart';
import '../../core/models/models.dart';
import '../../core/repositories/event_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import '../../shared/widgets/shimmer_skeletons.dart';
import '../../shared/widgets/small_event_card.dart';
import '../events/event_details_screen.dart';
import '../../core/responsive/responsive.dart';

/// Public creator / organizer profile — the marketplace seed.
/// Shows bio + stats + upcoming/past events. Follow toggles in-memory (real
/// persistence + hiring lands post-backend).
class CreatorProfileScreen extends StatefulWidget {
  final CreatorProfile creator;
  const CreatorProfileScreen({super.key, required this.creator});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _following = false;
  bool _bookmarked = false;

  List<Event> _upcoming = [];
  List<Event> _past = [];
  bool _loading = true;

  CreatorProfile get creator => widget.creator;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final page = await sl<EventRepository>().getEvents();
    final mine = page.events.where(
      (e) => e.organizerId == creator.id || e.lineup.contains(creator.id),
    );
    final now = DateTime.now();
    if (!mounted) return;
    setState(() {
      _upcoming = mine.where((e) => !e.date.isBefore(now)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      _past = mine.where((e) => e.date.isBefore(now)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      _loading = false;
    });
  }

  Color get _accent {
    // Category-derived accent so each profile has a distinct feel.
    switch (creator.category.toLowerCase()) {
      case 'photographer':
        return AppColors.accentOrange;
      case 'dj':
        return AppColors.indigo;
      case 'performer':
        return AppColors.fuchsia;
      case 'college':
      case 'organizer':
        return AppColors.lime;
      case 'community':
      case 'cafe':
        return AppColors.fuchsia;
      default:
        return AppColors.fuchsia;
    }
  }

  void _toggleFollow() {
    HapticFeedback.mediumImpact();
    setState(() => _following = !_following);
  }

  void _toggleBookmark() {
    HapticFeedback.selectionClick();
    setState(() => _bookmarked = !_bookmarked);
  }

  void _share() {
    HapticFeedback.selectionClick();
    Share.share(
      "Check out ${creator.name} ${creator.handle} on Hatri. The digital haat.",
      subject: creator.name,
    );
  }

  void _hire() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.graphite,
        content: Text(
          'Hiring lands after the backend 🚀',
          style: TextStyle(color: AppColors.paper),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final onAccent = accent.computeLuminance() > 0.55
        ? AppColors.onNeon
        : AppColors.paper;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildHero(accent, onAccent),
              SliverToBoxAdapter(
                child: _buildBioAndStats(accent),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  child: Container(
                    color: AppColors.ground,
                    padding: EdgeInsets.only(bottom: 6.r),
                    child: TabBar(
                      controller: _tabs,
                      indicatorColor: accent,
                      indicatorWeight: 3,
                      labelColor: AppColors.paper,
                      unselectedLabelColor: AppColors.muted,
                      labelStyle: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 12.sp,
                        letterSpacing: 1.4.sp,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        letterSpacing: 1.4.sp,
                      ),
                      tabs: [
                        Tab(text: 'UPCOMING · ${_upcoming.length}'),
                        Tab(text: 'PAST · ${_past.length}'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _buildEventList(_upcoming, emptyText: 'No upcoming events yet.'),
                _buildEventList(_past, emptyText: 'No past events on Hatri.'),
              ],
            ),
          ),
          _buildBottomActions(accent, onAccent),
        ],
      ),
    );
  }

  // ---------------- HERO ----------------

  SliverAppBar _buildHero(Color accent, Color onAccent) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: false,
      backgroundColor: AppColors.ground,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: accent),
            // Halftone motif
            Positioned.fill(
              child: Opacity(
                opacity: 0.22,
                child: HalftoneBackground(
                  dotColor: onAccent,
                  spacing: 10.r,
                  dotSize: 2,
                ),
              ),
            ),
            // Starburst decoration
            Positioned(
              right: 18.r,
              top: MediaQuery.of(context).padding.top + 70,
              child: Starburst(
                size: 56.r,
                color: onAccent.withValues(alpha: 0.85),
                points: 8,
              ),
            ),
            Positioned(
              right: 66.r,
              top: MediaQuery.of(context).padding.top + 140,
              child: Starburst(
                size: 32.r,
                color: onAccent.withValues(alpha: 0.55),
                points: 6,
              ),
            ),
            // Bottom fade to ground
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.55, 1.0],
                    colors: [
                      Colors.transparent,
                      AppColors.ground.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            // Top icon buttons
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: Insets.lg,
              right: Insets.lg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _svgChip('assets/icons/arrow-left.svg', onTap: () => Navigator.pop(context)),
                  Row(
                    children: [
                      _svgChip('assets/icons/Upload.svg', onTap: _share),
                      SizedBox(width: 8.r),
                      _svgChip(
                        'assets/icons/Bookmark.svg',
                        onTap: _toggleBookmark,
                        activeColor: _bookmarked ? AppColors.lime : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Avatar + name
            Positioned(
              left: Insets.lg,
              right: Insets.lg,
              bottom: 22.r,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: onAccent,
                      borderRadius: BorderRadius.circular(Corners.md),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Corners.sm),
                      child: HatriImage(
                        url: creator.avatarUrl,
                        width: 88.r,
                        height: 88.r,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 88.r,
                          height: 88.r,
                          color: AppColors.surfaceRaised,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/Profile.svg',
                            width: 24.r,
                            height: 24.r,
                            colorFilter: const ColorFilter.mode(
                                AppColors.muted, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.r),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CategoryTag(
                              label: creator.category,
                              color: onAccent,
                            ),
                            if (creator.isVerified) ...[
                              SizedBox(width: 6.r),
                              VerifiedBadge(size: 14.r),
                            ],
                          ],
                        ),
                        SizedBox(height: 8.r),
                        Text(
                          creator.name.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'ClashDisplay',
                            fontWeight: FontWeight.w700,
                            fontSize: 28.sp,
                            height: 0.95,
                            letterSpacing: -0.6.sp,
                            color: onAccent,
                          ),
                        ),
                        Text(
                          creator.handle,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            color: onAccent.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
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

  Widget _iconChip(IconData icon, {required VoidCallback onTap, Color? activeColor}) {
    return _chipShell(
      onTap: onTap,
      child: Icon(icon, color: activeColor ?? AppColors.paper, size: 20.r),
    );
  }

  /// Same chip, for the icons that ship as SVG artwork.
  Widget _svgChip(String asset, {required VoidCallback onTap, Color? activeColor}) {
    return _chipShell(
      onTap: onTap,
      child: SvgPicture.asset(
        asset,
        width: 20.r,
        height: 20.r,
        colorFilter: ColorFilter.mode(activeColor ?? AppColors.paper, BlendMode.srcIn),
      ),
    );
  }

  Widget _chipShell({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.ground.withValues(alpha: 0.55),
          border: Border.all(color: AppColors.onNeon.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: child,
      ),
    );
  }

  // ---------------- BIO + STATS ----------------

  Widget _buildBioAndStats(Color accent) {
    final totalEvents = _upcoming.length + _past.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          Text(
            creator.bio,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              height: 1.5,
              color: AppColors.paper,
            ),
          ),
          SizedBox(height: 8.r),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/Location.svg',
                width: 14.r,
                height: 14.r,
                colorFilter: const ColorFilter.mode(AppColors.muted, BlendMode.srcIn),
              ),
              SizedBox(width: 4.r),
              Text(
                'Based in Raipur, CG',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.r),
          // Stats
          Row(
            children: [
              Expanded(child: _statCell('FOLLOWERS', _formatCount(creator.followerCount))),
              SizedBox(width: 8.r),
              Expanded(child: _statCell('EVENTS', totalEvents.toString())),
              SizedBox(width: 8.r),
              Expanded(
                child: _statCell(
                  'RATING',
                  creator.rating > 0 ? creator.rating.toStringAsFixed(1) : 'new',
                  svgIcon: creator.rating > 0 ? 'assets/icons/Star.svg' : null,
                  iconColor: AppColors.lime,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.r),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value, {String? svgIcon, Color? iconColor}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.r, horizontal: 10.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w700,
              fontSize: 9.sp,
              letterSpacing: 1.4.sp,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: 4.r),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                if (svgIcon != null) ...[
                  SvgPicture.asset(
                    svgIcon,
                    width: 16.r,
                    height: 16.r,
                    colorFilter: ColorFilter.mode(
                        iconColor ?? AppColors.paper, BlendMode.srcIn),
                  ),
                  SizedBox(width: 4.r),
                ],
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                    color: AppColors.paper,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  // ---------------- EVENT LIST ----------------

  Widget _buildEventList(List<Event> events, {required String emptyText}) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(Insets.lg, 16.r, Insets.lg, 24.r),
        child: const ShimmerEventStack(count: 3),
      );
    }
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 14.sp),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(Insets.lg, 12.r, Insets.lg, 140.r),
      itemCount: events.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.r),
      itemBuilder: (context, i) {
        final e = events[i];
        return SmallEventCard(
          event: e,
          isGrid: true,
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => EventDetailsScreen(event: e)),
          ),
        );
      },
    );
  }

  // ---------------- STICKY ACTIONS ----------------

  Widget _buildBottomActions(Color accent, Color onAccent) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.ground,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: EdgeInsets.fromLTRB(
          Insets.lg,
          12,
          Insets.lg,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Row(
          children: [
            // Follow (primary — active neon)
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _toggleFollow,
                child: AnimatedContainer(
                  duration: Motion.fast,
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  decoration: BoxDecoration(
                    color: _following ? AppColors.lime : Colors.transparent,
                    border: Border.all(color: AppColors.lime, width: 1.8),
                    borderRadius: BorderRadius.circular(Corners.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _following ? 'FOLLOWING ✓' : 'FOLLOW',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                      letterSpacing: 0.6.sp,
                      color: _following ? AppColors.onNeon : AppColors.lime,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.r),
            // Hire (dormant — visible but muted)
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _hire,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(Corners.md),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 14.r, color: AppColors.muted),
                      SizedBox(width: 6.r),
                      Text(
                        'HIRE',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          letterSpacing: 0.6.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Sliver TabBar delegate ----------------

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabBarDelegate({required this.child});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => old.child != child;
}
