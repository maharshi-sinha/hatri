import 'dart:async';

import 'package:flutter/material.dart';
import '../../shared/widgets/hatri_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import '../../shared/widgets/burst_star.dart';
import '../../shared/widgets/community_card.dart';
import '../../shared/widgets/kinetic_marquee.dart';
import '../../shared/widgets/shimmer_skeletons.dart';
import '../../shared/widgets/search_screen.dart';
import 'bloc/communities_bloc.dart';
import 'bloc/communities_state.dart';
import 'community_details_screen.dart';
import 'capture_vibe_screen.dart';
import 'photo_viewer_screen.dart';
import '../../core/responsive/responsive.dart';

/// Communities — meetup-first. Groups are crews that gather:
/// neighborhoods, colleges, interests, and creator hubs.
class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final String currentCity = 'Raipur'; // TODO: fetch from prefs
  CommunityType? _activeType; // null = "All"
  final PageController _featuredCtrl = PageController(viewportFraction: 0.9);
  int _featuredIndex = 0;

  final List<String> _dummyVibePhotos = [
    'https://images.unsplash.com/photo-1528605248644-14dd04022da1?w=500&q=80',
    'https://images.unsplash.com/photo-1511871893393-82e9c16b81e3?w=500&q=80',
    'https://images.unsplash.com/photo-1495360010541-f48722b34f7d?w=500&q=80',
    'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=500&q=80',
  ];

  @override
  void dispose() {
    _featuredCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CommunitiesBloc, CommunitiesState>(
          builder: (context, state) {
            if (state is CommunitiesLoading || state is CommunitiesInitial) {
              return Padding(
                padding: EdgeInsets.fromLTRB(Insets.lg, 24.r, Insets.lg, 40.r),
                child: const ShimmerCommunityStack(count: 6),
              );
            }
            if (state is! CommunitiesLoaded) return const SizedBox.shrink();

            final all = state.communities;
            final activeFiltered = _activeType == null
                ? all
                : all.where((c) => c.type == _activeType).toList();
            final joined = all.where((c) => AppCommunities.joinedIds.contains(c.id)).toList();
            final featuredList = _pickFeaturedList(all);

            final rollPhotos = _collectRecentPhotos(all);
            final collagePhotos = rollPhotos.take(4).map((e) => e.photo).toList();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildMastheadHeader()),
                SliverToBoxAdapter(child: _buildManifestoBoard(collagePhotos)),
                SliverToBoxAdapter(child: _buildEditorsNote(null)),
                if (rollPhotos.isNotEmpty)
                  SliverToBoxAdapter(child: _buildThisWeeksRoll(rollPhotos, all)),
                SliverToBoxAdapter(
                  child: KineticMarquee(
                    word: 'SCENES',
                    separatorWidget: BurstStar(size: 28.r, color: AppColors.fuchsia),
                  ),
                ),
                SliverToBoxAdapter(child: _buildTypeTabs()),
                SliverToBoxAdapter(child: _buildStampsHeader()),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(Insets.lg, 8.r, Insets.lg, 8.r),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        // Two stamps per row, alternating tilt for a hand-placed feel.
                        if (i * 2 >= activeFiltered.length) return null;
                        final left = activeFiltered[i * 2];
                        final right = (i * 2 + 1 < activeFiltered.length)
                            ? activeFiltered[i * 2 + 1]
                            : null;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 22.r),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _StampCard(
                                  community: left,
                                  joined: AppCommunities.joinedIds.contains(left.id),
                                  tiltDeg: _tiltForIndex(i * 2),
                                  onTap: () => _openDetails(left),
                                ),
                              ),
                              SizedBox(width: 14.r),
                              Expanded(
                                child: right == null
                                    ? const SizedBox.shrink()
                                    : _StampCard(
                                        community: right,
                                        joined: AppCommunities.joinedIds.contains(right.id),
                                        tiltDeg: _tiltForIndex(i * 2 + 1),
                                        onTap: () => _openDetails(right),
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (activeFiltered.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState()),
                SliverToBoxAdapter(child: _buildBeTheFirstCard()),
                SliverToBoxAdapter(child: SizedBox(height: 140.r)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IN ${currentCity.toUpperCase()} RIGHT NOW',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    letterSpacing: 1.6.sp,
                    color: AppColors.lime,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SCENES',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 42.sp,
                    height: 0.95,
                    letterSpacing: -1.4.sp,
                    color: AppColors.paper,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  "what's your vibe?",
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
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
                  'assets/icons/Search.svg',
                  width: 20.r,
                  height: 20.r,
                  colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- MASTHEAD ----------------

  Widget _buildMastheadHeader() {
    final now = DateTime.now();
    const monthNames = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    const dayNames = ['MON','TUE','WED','THU','FRI','SAT','SUN'];
    final dateStamp = '${dayNames[(now.weekday - 1).clamp(0, 6)]} · ${now.day} ${monthNames[now.month - 1]}';
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, 8.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BurstStar(size: 12.r, color: AppColors.fuchsia),
              SizedBox(width: 8.r),
              Text(
                '$dateStamp · ${currentCity.toUpperCase()}',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 10.sp,
                  letterSpacing: 1.6.sp,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(Corners.md),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/Search.svg',
                      width: 18.r,
                      height: 18.r,
                      colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.r),
          Text(
            'SCENES.',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 56.sp,
              height: 0.92,
              letterSpacing: -2.0.sp,
              color: AppColors.paper,
            ),
          ),
          SizedBox(height: 4.r),
          Text(
            "what's playing in your city.",
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- MANIFESTO BOARD (lime hero — "what's a scene?") ----------------

  Widget _buildManifestoBoard(List<WallPhoto> photos) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 18.r, Insets.lg, 12.r),
      child: StickerShadow(
        color: AppColors.onNeon,
        offset: Offset(6.r, 6.r),
        radius: Corners.lg,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.r, 18.r, 20.r, 20.r),
          decoration: BoxDecoration(
            color: AppColors.lime,
            border: Border.all(color: AppColors.onNeon, width: 1.8),
            borderRadius: BorderRadius.circular(Corners.lg),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                    decoration: BoxDecoration(
                      color: AppColors.onNeon,
                      borderRadius: BorderRadius.circular(Corners.pill),
                    ),
                    child: Text(
                      "★ WHAT'S A SCENE?",
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5.sp,
                        letterSpacing: 1.4.sp,
                        color: AppColors.lime,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.r),
                  Text('ROOMS.', style: _manifestoStyle()),
                  Text('REGULARS.', style: _manifestoStyle()),
                  Text('REAL LIFE.', style: _manifestoStyle()),
                  SizedBox(height: 14.r),
                  Text(
                    'small rooms in your city where\nshowing up = belonging.',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      height: 1.4,
                      color: AppColors.onNeon.withValues(alpha: 0.78),
                    ),
                  ),
                  SizedBox(height: 6.r),
                ],
              ),
              if (photos.isNotEmpty) ..._buildCollagePolaroids(photos),
              Positioned(top: 20.r, right: 6.r, child: _sparkle('✦', 14.sp)),
              Positioned(top: 100.r, right: 80.r, child: _sparkle('★', 10.sp)),
              Positioned(bottom: 20.r, right: 44.r, child: _sparkle('✦', 12.sp)),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _manifestoStyle() => TextStyle(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.w800,
        fontSize: 38.sp,
        height: 0.95,
        letterSpacing: -1.6.sp,
        color: AppColors.onNeon,
      );

  Widget _sparkle(String glyph, double size) => Text(
        glyph,
        style: TextStyle(
          fontFamily: 'ClashDisplay',
          fontWeight: FontWeight.w800,
          fontSize: size,
          color: AppColors.onNeon,
        ),
      );

  static const _kStickers = <String>[
    'assets/images/stickers/disco_ball.png',
    'assets/images/stickers/vinyl.png',
    'assets/images/stickers/camera.png',
    'assets/images/stickers/flame_heart.png',
  ];

  List<Widget> _buildCollagePolaroids(List<WallPhoto> photos) {
    // Static Y2K sticker set — no white polaroid frame, no photo swap by
    // community. Same positions + tilts as the earlier polaroid layout so the
    // composition stays balanced.
    const layouts = [
      _CollageSpec(top: 0, right: 4, size: 82, tiltDeg: 8),
      _CollageSpec(top: 44, right: 54, size: 70, tiltDeg: -6),
      _CollageSpec(top: 104, right: 8, size: 88, tiltDeg: 5),
      _CollageSpec(top: 144, right: 74, size: 66, tiltDeg: -9),
    ];
    final widgets = <Widget>[];
    for (int i = 0; i < _kStickers.length && i < layouts.length; i++) {
      final spec = layouts[i];
      widgets.add(
        Positioned(
          top: spec.top?.r,
          right: spec.right?.r,
          child: Transform.rotate(
            angle: spec.tiltDeg * 3.14159 / 180,
            child: Image.asset(
              _kStickers[i],
              width: spec.size.r,
              height: spec.size.r,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  // ---------------- EDITOR'S NOTE ----------------

  Widget _buildEditorsNote(Community? crew) {
    final note = _pickEditorsNote(crew);
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 14.r, Insets.lg, 4.r),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.r, 12.r, 14.r, 12.r),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.fuchsia, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"$note"',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                fontSize: 15.sp,
                height: 1.4,
                letterSpacing: -0.2.sp,
                color: AppColors.paper.withValues(alpha: 0.92),
              ),
            ),
            SizedBox(height: 8.r),
            Row(
              children: [
                Text(
                  '— HATRI EDITORIAL',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 9.sp,
                    letterSpacing: 1.6.sp,
                    color: AppColors.muted,
                  ),
                ),
                SizedBox(width: 6.r),
                Text(
                  '✦',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.fuchsia,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _pickEditorsNote(Community? crew) {
    // Rotate deterministically by week so the note refreshes weekly.
    final week = DateTime.now().difference(DateTime(2026, 1, 1)).inDays ~/ 7;
    const notes = [
      // philosophy / voice
      "touch grass. yeah, we built a whole app for it.",
      "the algo lied. real life is unfathomably more fun.",
      "no fyp. no push notifs. just show up. that's the whole bit.",
      "we curated 4 scenes worth your saturday. rest is noise.",
      "chronically online, chronically outside. this is the move.",
      "small city, main character energy. pick a scene, be there.",
      "spotted this week: sunrise runs, chai crawls, wednesday jams. immaculate.",
      "the group chat is dead. long live showing up in person.",
      "not everything needs to be a plan. some things just need you there.",

      // what's a scene
      "a scene is just people who kept showing up. that's it. that's the tweet.",
      "scenes are the group chats that touched grass and survived.",
      "third space activated. no seating chart. just show up.",
      "one scene. six regulars. that's the recipe. don't overthink it.",
      "a scene is where 'i'll come next time' becomes 'see you thursday.'",
      "rooms beat algorithms. every single time.",

      // gen z humour / good vibes
      "everyone here is also nervous. book it anyway.",
      "npc arc: canceled. showing up era: activated.",
      "not to be dramatic but going outside kind of slaps.",
      "friendships from a wednesday chai run > any dating app match.",
      "your future self is begging you to book something.",
      "no rizz required. show up, drink chai, become a regular.",
      "bookmarking events is not a personality. showing up is.",
      "consumer of content to contributor of vibes. we love that arc.",
      "delulu: 'i'll do it next week.' solulu: book it now.",
      "'i don't know anyone' is a lie. these rooms fix that fast.",
      "you were built for wednesday jams. stop fighting it.",
    ];
    return notes[week % notes.length];
  }

  // ---------------- THIS WEEK'S ROLL ----------------

  /// Aggregates the most recent wall photos across every scene, tagged with
  /// the scene they came from so tapping opens the right viewer.
  List<_RollEntry> _collectRecentPhotos(List<Community> all) {
    final entries = <_RollEntry>[];
    for (final c in all) {
      for (final p in c.wallPhotos) {
        entries.add(_RollEntry(photo: p, community: c));
      }
    }
    entries.sort((a, b) => b.photo.attendedAt.compareTo(a.photo.attendedAt));
    return entries.take(20).toList();
  }

  Widget _buildThisWeeksRoll(List<_RollEntry> entries, List<Community> all) {
    return Padding(
      padding: EdgeInsets.only(top: 20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Row(
              children: [
                Container(
                  width: 8.r, height: 8.r,
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.lime.withValues(alpha: 0.5), blurRadius: 6.r),
                    ],
                  ),
                ),
                SizedBox(width: 8.r),
                Text(
                  "THIS WEEK'S ROLL · ${entries.length} NEW",
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                    letterSpacing: 1.8.sp,
                    color: AppColors.lime,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.r),
          SizedBox(
            height: 210.r,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              itemCount: entries.length,
              separatorBuilder: (_, _) => SizedBox(width: 12.r),
              itemBuilder: (context, i) {
                return _PhotoRollItem(entry: entries[i]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PASSPORT COUNTER + SHOUTS TICKER (unused) ----------------

  Widget _buildPassportShoutsRow(int collected, int total) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 14.r, Insets.lg, 12.r),
      child: Row(
        children: [
          // Passport chip — collected/total
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 8.r),
            decoration: BoxDecoration(
              color: AppColors.fuchsia.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.fuchsia.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(Corners.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_rounded, size: 12.r, color: AppColors.fuchsia),
                SizedBox(width: 6.r),
                Text(
                  'JOINED $collected/$total',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 10.sp,
                    letterSpacing: 1.2.sp,
                    color: AppColors.fuchsia,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.r),
          // Shouts ticker
          Expanded(
            child: Container(
              height: 32.r,
              decoration: BoxDecoration(
                color: AppColors.graphite,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(Corners.pill),
              ),
              clipBehavior: Clip.antiAlias,
              child: const _ShoutsTicker(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- STAMPS SECTION HEADER ----------------

  Widget _buildStampsHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 22.r, Insets.lg, 4.r),
      child: Row(
        children: [
          Container(width: 14.r, height: 3, color: AppColors.lime),
          SizedBox(width: 8.r),
          Text(
            'THE COLLECTION',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 11.sp,
              letterSpacing: 1.8.sp,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }

  // Kept the API but returns 0 — straight cards read cleaner than tilts.
  double _tiltForIndex(int i) => 0.0;

  // ---------------- LIVE INDICATOR STRIP ----------------

  Widget _buildLiveStrip(List<Community> all) {
    // Any scene with a recurring meetup or an upcoming event counts as "live"
    // for this week — since the whole point of a Scene is its weekly rhythm.
    final liveCount = all
        .where((c) => c.hostedWeekly != null || c.upcomingEventIds.isNotEmpty)
        .length;
    if (liveCount == 0) return const SizedBox.shrink();
    final noun = liveCount == 1 ? 'SCENE HAS' : 'SCENES HAVE';
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, 8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
        decoration: BoxDecoration(
          color: AppColors.lime.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.lime.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(Corners.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingDot(color: AppColors.lime),
            SizedBox(width: 8.r),
            Text(
              '$liveCount $noun EVENTS THIS WEEK',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 1.4.sp,
                color: AppColors.lime,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TYPE TABS ----------------

  Widget _buildTypeTabs() {
    return SizedBox(
      height: 36.r,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8.r),
            child: FilterChipX(
              label: 'All',
              selected: _activeType == null,
              onTap: () => setState(() => _activeType = null),
              activeColor: AppColors.fuchsia,
            ),
          ),
          for (final t in CommunityType.values)
            Padding(
              padding: EdgeInsets.only(right: 8.r),
              child: FilterChipX(
                label: t.label,
                selected: _activeType == t,
                onTap: () => setState(() => _activeType = _activeType == t ? null : t),
                activeColor: AppColors.fromHex(t.colorHex),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- YOUR COMMUNITIES ----------------

  Widget _buildYourCommunities(List<Community> joined) {
    return Padding(
      padding: EdgeInsets.only(top: 14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, 8.r),
            child: Row(
              children: [
                const StickerLabel(
                  text: 'YOURS',
                  background: AppColors.lime,
                  foreground: AppColors.onNeon,
                ),
                SizedBox(width: 8.r),
                Text(
                  '${joined.length} joined',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    letterSpacing: 0.6.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60.r,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              itemCount: joined.length,
              itemBuilder: (context, i) {
                final c = joined[i];
                final accent = AppColors.fromHex(c.type.colorHex);
                return Padding(
                  padding: EdgeInsets.only(right: 10.r),
                  child: GestureDetector(
                    onTap: () => _openDetails(c),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 44.r,
                          height: 44.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.2),
                            border: Border.all(color: accent, width: 1.4),
                            borderRadius: BorderRadius.circular(Corners.md),
                          ),
                          child: Text(c.emoji, style: TextStyle(fontSize: 20.sp)),
                        ),
                        SizedBox(width: 8.r),
                        SizedBox(
                          width: 90.r,
                          child: Text(
                            c.name.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 10.sp,
                              letterSpacing: 0.6.sp,
                              color: AppColors.paper,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FEATURED ----------------

  Widget _buildFeaturedSectionHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 22.r, Insets.lg, 10.r),
      child: Row(
        children: [
          StickerLabel(
            text: '⭐ FEATURED',
            background: AppColors.fuchsia,
            foreground: AppColors.paper,
          ),
          SizedBox(width: 8.r),
          Text(
            'Crew of the week',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              letterSpacing: -0.2.sp,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }

  List<Community> _pickFeaturedList(List<Community> all) {
    if (all.isEmpty) return const [];
    final sorted = [...all]..sort((a, b) => b.memberCount.compareTo(a.memberCount));
    return sorted.take(5).toList();
  }

  Widget _buildFeaturedCarousel(List<Community> list) {
    return Column(
      children: [
        SizedBox(
          height: 360.r,
          child: PageView.builder(
            controller: _featuredCtrl,
            itemCount: list.length,
            onPageChanged: (i) => setState(() => _featuredIndex = i),
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 4.r),
              child: _buildFeaturedCard(list[i]),
            ),
          ),
        ),
        SizedBox(height: 8.r),
        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < list.length; i++)
              AnimatedContainer(
                duration: Motion.fast,
                margin: EdgeInsets.symmetric(horizontal: 3.r),
                width: i == _featuredIndex ? 18 : 6,
                height: 6.r,
                decoration: BoxDecoration(
                  color: i == _featuredIndex ? AppColors.lime : AppColors.border,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Contrast backdrop so the sticker shadow reads against the card color.
  Color _backdropFor(CommunityType t) {
    switch (t) {
      case CommunityType.interest:      return AppColors.lime;     // fuchsia card
      case CommunityType.neighborhood:  return AppColors.fuchsia;  // indigo card
      case CommunityType.college:       return AppColors.indigo;   // orange card
      case CommunityType.creator:       return AppColors.fuchsia;  // lime card
    }
  }

  Widget _buildFeaturedCard(Community c) {
    final accent = AppColors.fromHex(c.type.colorHex);
    final onAccent = accent.computeLuminance() > 0.55 ? AppColors.onNeon : AppColors.paper;

    return StickerShadow(
        color: _backdropFor(c.type),
        offset: Offset(5.r, 5.r),
        radius: Corners.lg,
        child: GestureDetector(
          onTap: () => _openDetails(c),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Corners.lg),
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                border: Border.all(color: AppColors.onNeon, width: 1.4),
                borderRadius: BorderRadius.circular(Corners.lg),
              ),
              child: AdaptiveCardBody(
                aspectRatio: 16 / 9,
                cover: Stack(
                  fit: StackFit.expand,
                  children: [
                    HatriImage(url: c.coverUrl, fit: BoxFit.cover, errorWidget: Container(color: accent),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: HalftoneBackground(
                          dotColor: AppColors.onNeon,
                          spacing: 8.r,
                          dotSize: 1.6,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10.r,
                      left: 10.r,
                      child: CategoryTag(
                        label: c.type.label,
                        color: AppColors.onNeon,
                      ),
                    ),
                  ],
                ),
                body: Padding(
                    padding: EdgeInsets.fromLTRB(14.r, 12.r, 14.r, 14.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(c.emoji, style: TextStyle(fontSize: 22.sp)),
                            SizedBox(width: 8.r),
                            Expanded(
                              child: Text(
                                c.name.toUpperCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'ClashDisplay',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.sp,
                                  height: 0.98,
                                  letterSpacing: -0.4.sp,
                                  color: onAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.r),
                        Text(
                          c.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            color: onAccent.withValues(alpha: 0.85),
                          ),
                        ),
                        SizedBox(height: 12.r),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatCount(c.memberCount)} MEMBERS',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 11.sp,
                                letterSpacing: 1.2.sp,
                                color: onAccent,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
                              decoration: BoxDecoration(
                                color: AppColors.onNeon,
                                borderRadius: BorderRadius.circular(Corners.pill),
                              ),
                              child: Text(
                                'JOIN',
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.8.sp,
                                  color: AppColors.paper,
                                ),
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
    );
  }

  // ---------------- GRID header + empty ----------------

  Widget _buildGridSectionHeader(int count) {
    final title = _activeType == null
        ? 'ALL CREWS'
        : '${_activeType!.label.toUpperCase()} CREWS';
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 22.r, Insets.lg, 6.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              letterSpacing: -0.2.sp,
              color: AppColors.paper,
            ),
          ),
          SizedBox(width: 8.r),
          Text(
            '· $count',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final typeLabel = _activeType?.label.toLowerCase() ?? 'community';
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 20.r, Insets.lg, 60.r),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.graphite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Column(
          children: [
            Text('🌱', style: TextStyle(fontSize: 32.sp)),
            SizedBox(height: 8.r),
            Text(
              'No $typeLabel crews yet',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              'Wanna start one? (Coming after backend)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BE THE FIRST invitation ----------------

  Widget _buildBeTheFirstCard() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 24.r, Insets.lg, 0),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.fuchsia, width: 1.5),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 14.r, height: 3, color: AppColors.fuchsia),
                SizedBox(width: 8.r),
                Text(
                  'BE THE FIRST',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                    letterSpacing: 1.8.sp,
                    color: AppColors.fuchsia,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Text(
              "NOTHING FOR\nYOUR VIBE?",
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 26.sp,
                height: 0.95,
                letterSpacing: -0.6.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 10.r),
            Text(
              "start your own scene. host a weekly, gather your people, we'll help you set it up.",
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                height: 1.4,
                color: AppColors.muted,
              ),
            ),
            SizedBox(height: 16.r),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 12.r),
                decoration: BoxDecoration(
                  color: AppColors.fuchsia,
                  borderRadius: BorderRadius.circular(Corners.md),
                ),
                child: Text(
                  'APPLY TO HOST',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 13.sp,
                    letterSpacing: 1.2.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- VIBE CHECK (Photo Wall) ----------------

  Widget _buildVibeCheck(List<Community> communities) {
    // Take up to 4 communities for the vibe check carousel
    final vibeCommunities = communities.take(4).toList();
    if (vibeCommunities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(Insets.lg, 24.r, Insets.lg, 12.r),
          child: Row(
            children: [
              Text(
                '📸 VIBE CHECK',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 12.sp,
                  letterSpacing: 1.2.sp,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const CaptureVibeScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                  decoration: BoxDecoration(
                    color: AppColors.fuchsia,
                    borderRadius: BorderRadius.circular(Corners.pill),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_a_photo_rounded, color: AppColors.paper, size: 12.r),
                      SizedBox(width: 4.r),
                      Text(
                        'Add Yours',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                          color: AppColors.paper,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180.r,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            itemCount: vibeCommunities.length,
            itemBuilder: (context, i) {
              final c = vibeCommunities[i];
              return Padding(
                padding: EdgeInsets.only(right: 12.r),
                child: GestureDetector(
                  onTap: () => _openDetails(c),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Corners.md),
                    child: SizedBox(
                      width: 130.r,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          HatriImage(
                            url: c.coverUrl,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, AppColors.ground.withValues(alpha: 0.8)],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12.r,
                            left: 12.r,
                            right: 12.r,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'GeneralSans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.sp,
                                    color: AppColors.paper,
                                  ),
                                ),
                                SizedBox(height: 2.r),
                                Row(
                                  children: [
                                    Icon(Icons.arrow_forward_rounded, color: AppColors.lime, size: 12.r),
                                    SizedBox(width: 4.r),
                                    Text(
                                      'Check it out',
                                      style: TextStyle(
                                        fontFamily: 'GeneralSans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                        color: AppColors.lime,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- STARTER PACK ----------------

  Widget _buildStarterPack() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 32.r, Insets.lg, 12.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.fuchsia,
          borderRadius: BorderRadius.circular(Corners.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEW IN TOWN?',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 11.sp,
                letterSpacing: 1.4.sp,
                color: AppColors.onNeon,
              ),
            ),
            SizedBox(height: 6.r),
            Text(
              'Grab the Starter Pack',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 24.sp,
                letterSpacing: -0.5.sp,
                color: AppColors.paper,
                height: 1.1,
              ),
            ),
            SizedBox(height: 12.r),
            Text(
              'Jump into these beginner-friendly crews to meet your first few friends.',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: AppColors.paper.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.r),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
              decoration: BoxDecoration(
                color: AppColors.onNeon,
                borderRadius: BorderRadius.circular(Corners.pill),
              ),
              child: Text(
                'SAY HI 👋',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 12.sp,
                  letterSpacing: 1.sp,
                  color: AppColors.paper,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CURATED CORNERS ----------------

  Widget _buildCuratedCorners() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(Insets.lg, 32.r, Insets.lg, 12.r),
          child: Text(
            '☕ THE CAFE CORNER',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 12.sp,
              letterSpacing: 1.2.sp,
              color: AppColors.muted,
            ),
          ),
        ),
        SizedBox(
          height: 160.r,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            itemCount: 4,
            itemBuilder: (context, i) {
              return SizedBox(
                width: 140.r,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(Corners.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('☕', style: TextStyle(fontSize: 24.sp)),
                        SizedBox(height: 12.r),
                        Text(
                          'Coffee Lovers ${i+1}',
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: 'ClashDisplay',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: AppColors.paper,
                            height: 1.1,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '120 members',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 11.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- SECRET SPACES ----------------

  Widget _buildSecretSpaces() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 32.r, Insets.lg, 12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🔒 SECRET SPACES',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 12.sp,
                  letterSpacing: 1.2.sp,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              Text(
                'invite only',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 11.sp,
                  color: AppColors.muted.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.ground,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(Corners.lg),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Icon(Icons.lock_rounded, color: AppColors.muted, size: 20.r)),
                ),
                SizedBox(width: 16.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Midnight Runners',
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        'Requires referral link to join.',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 12.sp,
                          color: AppColors.muted,
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
    );
  }

  // ---------------- Helpers ----------------

  void _openDetails(Community c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommunityDetailsScreen(community: c)),
    ).then((_) => setState(() {})); // refresh joined strip on return
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

/// A single entry on the "This Week's Roll" strip — pairs a wall photo
/// with the scene it belongs to.
/// Layout spec for a single tilted polaroid in the moodboard collage.
class _CollageSpec {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final double tiltDeg;
  const _CollageSpec({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.tiltDeg,
  });
}

class _RollEntry {
  final WallPhoto photo;
  final Community community;
  const _RollEntry({required this.photo, required this.community});
}

/// A vertical film-frame card in the roll — cover on top, tiny footer with
/// scene name + time-ago. Sticker shadow for the physical-photo feel.
class _PhotoRollItem extends StatelessWidget {
  final _RollEntry entry;
  const _PhotoRollItem({required this.entry});

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays > 0) return '${d.inDays}D AGO';
    if (d.inHours > 0) return '${d.inHours}H AGO';
    return 'JUST NOW';
  }

  @override
  Widget build(BuildContext context) {
    final photos = entry.community.wallPhotos;
    final indexInWall = photos.indexWhere((p) => p.id == entry.photo.id);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => PhotoViewerScreen(
              photos: photos,
              initialIndex: indexInWall < 0 ? 0 : indexInWall,
              communityName: entry.community.name,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 140.r,
        // 35mm filmstrip: dark base with sprocket holes both sides.
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.graphite,
            border: Border.all(color: AppColors.paper.withValues(alpha: 0.12), width: 1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top sprocket row
              _SprocketRow(),
              // Photo frame — sprockets flank the photo left + right
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.r),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      HatriImage(url: entry.photo.photoUrl, fit: BoxFit.cover, errorWidget: Container(color: AppColors.surfaceRaised),
                      ),
                      if (entry.photo.youAreIn)
                        Positioned(
                          top: 6.r,
                          right: 6.r,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                            decoration: BoxDecoration(
                              color: AppColors.lime,
                              borderRadius: BorderRadius.circular(Corners.pill),
                            ),
                            child: Text(
                              'YOU',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 7.sp,
                                letterSpacing: 0.8.sp,
                                color: AppColors.onNeon,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Bottom sprocket row
              _SprocketRow(),
              // Frame-caption strip — scene name + time-ago, mono like a film neg
              Padding(
                padding: EdgeInsets.fromLTRB(10.r, 6.r, 10.r, 8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.community.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 10.sp,
                        letterSpacing: 0.8.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      '▸ ${_ago(entry.photo.attendedAt)}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        fontSize: 8.sp,
                        letterSpacing: 0.8.sp,
                        color: AppColors.fuchsia,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row of 5 evenly spaced pale rectangles — the sprocket holes on a 35mm strip.
class _SprocketRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14.r,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 4.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (_) => Container(
              width: 12.r,
              decoration: BoxDecoration(
                color: AppColors.paper.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kinetic marquee — giant italic "SCENES · SCENES ·" scrolling text.
/// Pure vibe. Zero cognitive load. Y2K/poster energy.
/// Scrolling shouts ticker — one-liner community chatter.
class _ShoutsTicker extends StatefulWidget {
  const _ShoutsTicker();

  @override
  State<_ShoutsTicker> createState() => _ShoutsTickerState();
}

class _ShoutsTickerState extends State<_ShoutsTicker> {
  static const _shouts = <String>[
    '💬 ravi: photo walk today 📸',
    '💬 aditi just joined chai pe charcha',
    '💬 circuit techno night selling fast',
    '💬 sana: rain check for sunday run?',
    '💬 3 new members in photo club',
    '💬 kabir: bringing my 35mm on saturday',
  ];

  final _controller = ScrollController();
  Timer? _timer;
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    // Auto-scroll the ticker every 3.5 seconds.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!mounted || !_controller.hasClients) return;
      _idx = (_idx + 1) % _shouts.length;
      final target = _idx * 240.0;
      _controller.animateTo(
        target > _controller.position.maxScrollExtent
            ? 0
            : target,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.r),
      itemCount: _shouts.length * 3, // triplicate for seamless loop feel
      itemBuilder: (context, i) {
        final s = _shouts[i % _shouts.length];
        return Center(
          child: Padding(
            padding: EdgeInsets.only(right: 20.r),
            child: Text(
              s,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
                color: AppColors.paper.withValues(alpha: 0.85),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Stamp card — a scene rendered as a tilted, sticker-shadowed passport stamp.
/// Includes a small WAVE micro-interaction.
class _StampCard extends StatefulWidget {
  final Community community;
  final bool joined;
  final double tiltDeg;
  final VoidCallback onTap;
  const _StampCard({
    required this.community,
    required this.joined,
    required this.tiltDeg,
    required this.onTap,
  });

  @override
  State<_StampCard> createState() => _StampCardState();
}

class _StampCardState extends State<_StampCard> with SingleTickerProviderStateMixin {
  bool _pressing = false;
  int _waveCount = 0;

  void _wave() {
    HapticFeedback.lightImpact();
    setState(() => _waveCount++);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.community;
    final accent = AppColors.fromHex(c.colorHex);
    final tiltRad = widget.tiltDeg * 3.14159 / 180;

    return Transform.rotate(
      angle: tiltRad,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        onTapDown: (_) => setState(() => _pressing = true),
        onTapCancel: () => setState(() => _pressing = false),
        onTapUp: (_) => setState(() => _pressing = false),
        child: AnimatedScale(
          scale: _pressing ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── POSTER: cover + fading MEMBERS strip, neutral border ──
              AspectRatio(
                aspectRatio: 0.86,
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
                        HatriImage(url: c.coverUrl, fit: BoxFit.cover, errorWidget: Container(color: accent.withValues(alpha: 0.3)),
                        ),
                        // Type chip (top-left)
                        Positioned(
                          top: 8.r, left: 8.r,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
                            decoration: BoxDecoration(
                              color: AppColors.ground.withValues(alpha: 0.7),
                              border: Border.all(color: AppColors.paper.withValues(alpha: 0.2)),
                              borderRadius: BorderRadius.circular(Corners.pill),
                            ),
                            child: Text(
                              c.type.label.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 8.sp,
                                letterSpacing: 1.0.sp,
                                color: AppColors.paper,
                              ),
                            ),
                          ),
                        ),
                        // "STAMPED" ink overlay if joined
                        if (widget.joined)
                          Center(
                            child: Transform.rotate(
                              angle: -0.35,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 4.r),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.lime, width: 2.5),
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: AppColors.lime.withValues(alpha: 0.16),
                                ),
                                child: Text(
                                  'STAMPED',
                                  style: TextStyle(
                                    fontFamily: 'ClashDisplay',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15.sp,
                                    letterSpacing: 2.0.sp,
                                    color: AppColors.lime,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // MEMBERS strip — accent left, fading right
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [accent, accent, accent.withValues(alpha: 0.0)],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                            child: Text(
                              '${_formatCount(c.memberCount)} MEMBERS',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 11.sp,
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
              // ── META: title only, floating under the poster ──
              SizedBox(
                height: 13.sp * 1.05 * 2,
                child: Text(
                  c.name.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 13.sp,
                    height: 1.05,
                    letterSpacing: -0.3.sp,
                    color: AppColors.paper,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    return '$n';
  }
}

/// Small looping dot with a soft glow — signals "live" state.
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = 0.4 + (_c.value * 0.6);
        return Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: t),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: widget.color.withValues(alpha: t * 0.6), blurRadius: 6.r),
            ],
          ),
        );
      },
    );
  }
}
