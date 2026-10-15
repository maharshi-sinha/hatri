import 'package:flutter/material.dart';
import '../../../../shared/widgets/hatri_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/models/models.dart';
import '../../../../core/repositories/event_repository.dart';
import '../../../../core/repositories/creator_repository.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/design/motifs.dart';
import '../../../events/presentation/pages/event_details_screen.dart';
import '../../../creators/creator_profile_screen.dart';
import 'photo_wall_screen.dart';
import 'photo_viewer_screen.dart';

/// Community Details v3 — the "Scene" model (launch-lean).
///
/// Reads: hero → hosted weekly anchor → who's going this week → hosts → join.
/// Wall / drop / chatter deferred until real usage signals they're needed.
class CommunityDetailsScreen extends StatefulWidget {
  final Community community;
  const CommunityDetailsScreen({super.key, required this.community});

  @override
  State<CommunityDetailsScreen> createState() => _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen> {
  late bool _isJoined;
  Event? _nextInstanceEvent;
  CreatorProfile? _host;
  List<CreatorProfile> _coHosts = const [];

  @override
  void initState() {
    super.initState();
    _isJoined = AppCommunities.joinedIds.contains(widget.community.id);
    _loadRelated();
  }

  Future<void> _loadRelated() async {
    final page = await sl<EventRepository>().getEvents();
    final nextId = widget.community.hostedWeekly?.nextInstanceEventId;
    final next = nextId == null
        ? null
        : page.events.where((e) => e.id == nextId).firstOrNull;

    CreatorProfile? host;
    if (widget.community.hostId != null) {
      host = await sl<CreatorRepository>().getById(widget.community.hostId!);
    }
    final coHosts = <CreatorProfile>[];
    for (final id in widget.community.coHostIds) {
      final c = await sl<CreatorRepository>().getById(id);
      if (c != null) coHosts.add(c);
    }
    if (!mounted) return;
    setState(() {
      _nextInstanceEvent = next;
      _host = host;
      _coHosts = coHosts;
    });
  }

  void _toggleJoin() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_isJoined) {
        AppCommunities.joinedIds.remove(widget.community.id);
        _isJoined = false;
      } else {
        AppCommunities.joinedIds.add(widget.community.id);
        _isJoined = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.community;
    final accent = AppColors.fromHex(c.colorHex);
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: CustomScrollView(
        slivers: [
          _buildHero(c, accent),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(Insets.lg, 20.r, Insets.lg, 140.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.hostedWeekly != null) _HostedWeeklyCard(hostedWeekly: c.hostedWeekly!, accent: accent, onRsvp: _openNextInstance),
                  if (c.eventsThisMonth > 0 || c.rating != null) ...[
                    SizedBox(height: 20.r),
                    _SceneStatsStrip(community: c, accent: accent),
                  ],
                  if (c.vibeTags.isNotEmpty) ...[
                    SizedBox(height: 28.r),
                    _SectionHeader(eyebrow: 'THE VIBE', title: "YOU'D FIT IN IF"),
                    SizedBox(height: 12.r),
                    _VibeCheck(tags: c.vibeTags, accent: accent),
                  ],
                  if (c.firstTimerGuide != null) ...[
                    SizedBox(height: 28.r),
                    _SectionHeader(eyebrow: 'NEW HERE?', title: 'FIRST TIME GUIDE'),
                    SizedBox(height: 12.r),
                    _FirstTimerCard(guide: c.firstTimerGuide!, accent: accent),
                  ],
                  if (_nextInstanceEvent != null) ...[
                    SizedBox(height: 28.r),
                    _SectionHeader(eyebrow: 'THIS WEEK', title: "WHO'S GOING"),
                    SizedBox(height: 12.r),
                    _WhosGoing(event: _nextInstanceEvent!),
                  ],
                  if (c.memberVibes.isNotEmpty) ...[
                    SizedBox(height: 32.r),
                    _SectionHeader(eyebrow: 'THE VIBES', title: 'MEMBERS SAID'),
                    SizedBox(height: 12.r),
                    _MemberVibesList(vibes: c.memberVibes, accent: accent),
                  ],
                  if (c.wallPhotos.isNotEmpty) ...[
                    SizedBox(height: 32.r),
                    _WallHeader(community: c),
                    SizedBox(height: 12.r),
                    _MemoryWallPreview(community: c),
                  ],
                  if (_host != null || _coHosts.isNotEmpty) ...[
                    SizedBox(height: 32.r),
                    _SectionHeader(eyebrow: 'THE HUMANS', title: 'HOSTED BY'),
                    SizedBox(height: 12.r),
                    _HostsRow(host: _host, coHosts: _coHosts),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openNextInstance() {
    final event = _nextInstanceEvent;
    if (event == null) return;
    HapticFeedback.lightImpact();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
    );
  }

  // ─── Hero ────────────────────────────────────────────────────────────

  Widget _buildHero(Community c, Color accent) {
    return SliverAppBar(
      expandedHeight: 260.r,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.ground,
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.pop(context);
        },
        child: Container(
          margin: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.ground.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(Corners.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/arrow-left.svg',
                          width: 20.r,
                          height: 20.r,
                          colorFilter: ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                        ),
                      ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            HatriImage(url: c.coverUrl, fit: BoxFit.cover, errorWidget: Container(color: accent.withValues(alpha: 0.3)),
            ),
            const _HalftoneOverlay(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.ground],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: Insets.lg,
              right: Insets.lg,
              bottom: 16.r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 4.r),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(Corners.pill),
                    ),
                    child: Text(
                      c.type.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 10.sp,
                        letterSpacing: 1.4.sp,
                        color: AppColors.onNeon,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.r),
                  Text(
                    c.name.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 32.sp,
                      height: 0.95,
                      letterSpacing: -1.0.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Row(
                    children: [
                      Text(c.emoji, style: TextStyle(fontSize: 16.sp)),
                      SizedBox(width: 6.r),
                      Text(
                        '${_formatCount(c.memberCount)} MEMBERS',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          letterSpacing: 1.2.sp,
                          color: AppColors.paper.withValues(alpha: 0.85),
                        ),
                      ),
                      if (c.location != null) ...[
                        SizedBox(width: 10.r),
                        Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.muted, shape: BoxShape.circle)),
                        SizedBox(width: 10.r),
                        Flexible(
                          child: Text(
                            c.location!.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                              letterSpacing: 1.2.sp,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 12.r, top: 8.r, bottom: 8.r),
          child: _JoinPill(joined: _isJoined, accent: accent, onTap: _toggleJoin),
        ),
      ],
    );
  }

  static String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    return '$n';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  const _SectionHeader({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 14.r, height: 3, color: AppColors.lime),
            SizedBox(width: 8.r),
            Text(
              eyebrow,
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
        SizedBox(height: 4.r),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontWeight: FontWeight.w800,
            fontSize: 22.sp,
            height: 1.0,
            letterSpacing: -0.6.sp,
            color: AppColors.paper,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// JOIN PILL
// ═══════════════════════════════════════════════════════════════════════════

class _JoinPill extends StatelessWidget {
  final bool joined;
  final Color accent;
  final VoidCallback onTap;
  const _JoinPill({required this.joined, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
        decoration: BoxDecoration(
          color: joined ? Colors.transparent : accent,
          border: Border.all(color: joined ? AppColors.paper : accent, width: 1.5),
          borderRadius: BorderRadius.circular(Corners.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              joined ? Icons.check_rounded : Icons.add_rounded,
              size: 14.r,
              color: joined ? AppColors.paper : AppColors.onNeon,
            ),
            SizedBox(width: 4.r),
            Text(
              joined ? 'JOINED' : 'JOIN',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 11.sp,
                letterSpacing: 1.2.sp,
                color: joined ? AppColors.paper : AppColors.onNeon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOSTED WEEKLY (the anchor)
// ═══════════════════════════════════════════════════════════════════════════

class _HostedWeeklyCard extends StatelessWidget {
  final HostedWeekly hostedWeekly;
  final Color accent;
  final VoidCallback onRsvp;
  const _HostedWeeklyCard({required this.hostedWeekly, required this.accent, required this.onRsvp});

  @override
  Widget build(BuildContext context) {
    return StickerShadow(
      color: AppColors.onNeon,
      offset: Offset(5.r, 5.r),
      radius: Corners.lg,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.lime,
          border: Border.all(color: AppColors.onNeon, width: 1.5),
          borderRadius: BorderRadius.circular(Corners.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                  decoration: BoxDecoration(
                    color: AppColors.onNeon,
                    borderRadius: BorderRadius.circular(Corners.pill),
                  ),
                  child: Text(
                    'THE USUAL',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 9.sp,
                      letterSpacing: 1.6.sp,
                      color: AppColors.lime,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.r),
            Text(
              hostedWeekly.dayLabel,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 38.sp,
                height: 0.95,
                letterSpacing: -1.4.sp,
                color: AppColors.onNeon,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              hostedWeekly.timeLabel,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 28.sp,
                height: 1.0,
                letterSpacing: -0.6.sp,
                color: AppColors.onNeon,
              ),
            ),
            SizedBox(height: 10.r),
            Text(
              hostedWeekly.venueLabel,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
                letterSpacing: 1.4.sp,
                color: AppColors.onNeon,
              ),
            ),
            if (hostedWeekly.description.isNotEmpty) ...[
              SizedBox(height: 6.r),
              Text(
                hostedWeekly.description,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  color: AppColors.onNeon.withValues(alpha: 0.75),
                ),
              ),
            ],
            SizedBox(height: 16.r),
            if (hostedWeekly.nextInstanceEventId != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRsvp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onNeon,
                    foregroundColor: AppColors.lime,
                    padding: EdgeInsets.symmetric(vertical: 14.r),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Corners.md)),
                    elevation: 0,
                  ),
                  child: Text(
                    "I'M IN THIS WEEK",
                    style: TextStyle(
                      color: AppColors.lime,
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
}
// HALFTONE OVERLAY (tiny dots wash — matches the app aesthetic)
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// WHO'S GOING (this week's instance attendees)
// ═══════════════════════════════════════════════════════════════════════════

class _WhosGoing extends StatelessWidget {
  final Event event;
  const _WhosGoing({required this.event});

  @override
  Widget build(BuildContext context) {
    final attendees = event.attendees;
    final count = event.rsvpCount;
    final accent = AppColors.fromHex(event.colorHex);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (attendees.isNotEmpty)
                SizedBox(
                  width: 22.0.r * (attendees.length.clamp(0, 5)).toDouble() + 22,
                  height: 34.r,
                  child: Stack(
                    children: [
                      for (int i = 0; i < attendees.take(5).length; i++)
                        Positioned(
                          left: (i * 22).toDouble(),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.graphite, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 14.r,
                              backgroundColor: AppColors.surfaceRaised,
                              backgroundImage: NetworkImage(attendees[i].avatarUrl),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              SizedBox(width: 10.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count GOING',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                        letterSpacing: 1.0.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    if (attendees.isNotEmpty) ...[
                      SizedBox(height: 2.r),
                      Text(
                        '${attendees.first.name}${attendees.length > 1 ? ' + ${attendees.length - 1} friends' : ''}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.r),
          Container(height: 1, color: AppColors.border),
          SizedBox(height: 12.r),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14.r, color: accent),
              SizedBox(width: 8.r),
              Text(
                '${DateFormat('EEE, MMM d').format(event.date).toUpperCase()} · ${event.time}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  letterSpacing: 0.6.sp,
                  color: AppColors.paper,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOSTS ROW
// ═══════════════════════════════════════════════════════════════════════════

class _HostsRow extends StatelessWidget {
  final CreatorProfile? host;
  final List<CreatorProfile> coHosts;
  const _HostsRow({required this.host, required this.coHosts});

  @override
  Widget build(BuildContext context) {
    final list = <CreatorProfile>[
      if (host != null) host!,
      ...coHosts,
    ];
    return SizedBox(
      height: 90.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.r),
        itemBuilder: (context, i) {
          final creator = list[i];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreatorProfileScreen(creator: creator)),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.graphite,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(Corners.md),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppColors.surfaceRaised,
                    backgroundImage: NetworkImage(creator.avatarUrl),
                  ),
                  SizedBox(width: 10.r),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creator.name.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          letterSpacing: -0.2.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SizedBox(height: 2.r),
                      Text(
                        i == 0 ? 'HOST' : 'CO-HOST',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                          letterSpacing: 1.2.sp,
                          color: AppColors.lime,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10.r),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SCENE STATS — small chip strip showing aliveness (events, rating, growth)
// ═══════════════════════════════════════════════════════════════════════════

class _SceneStatsStrip extends StatelessWidget {
  final Community community;
  final Color accent;
  const _SceneStatsStrip({required this.community, required this.accent});

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String, IconData)>[
      if (community.eventsThisMonth > 0)
        ('${community.eventsThisMonth}', 'EVENTS / MONTH', Icons.event_available_rounded),
      if (community.rating != null)
        ('${community.rating!.toStringAsFixed(1)}', '${community.reviewCount} REVIEWS', Icons.star_rounded),
      if (community.newMembersThisWeek > 0)
        ('+${community.newMembersThisWeek}', 'THIS WEEK', Icons.trending_up_rounded),
    ];
    if (stats.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.r, horizontal: 4.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(stats[i].$3, color: accent, size: 16.r),
                    SizedBox(height: 6.r),
                    Text(
                      stats[i].$1,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                        height: 1.0,
                        letterSpacing: -0.4.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      stats[i].$2,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 8.5.sp,
                        letterSpacing: 0.8.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i != stats.length - 1) Container(width: 1, height: 32.r, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FIRST TIMER GUIDE — what to expect, dress vibe, what to bring, solo-friendly
// ═══════════════════════════════════════════════════════════════════════════

class _FirstTimerCard extends StatelessWidget {
  final FirstTimerGuide guide;
  final Color accent;
  const _FirstTimerCard({required this.guide, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solo-friendly badge
          if (guide.soloFriendly)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.16),
                border: Border.all(color: AppColors.lime.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(Corners.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.waving_hand_rounded, size: 12.r, color: AppColors.lime),
                  SizedBox(width: 6.r),
                  Text(
                    guide.soloLastTime > 0
                        ? 'SOLO-FRIENDLY · ${guide.soloLastTime} CAME SOLO LAST TIME'
                        : 'SOLO-FRIENDLY',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 9.5.sp,
                      letterSpacing: 1.2.sp,
                      color: AppColors.lime,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 14.r),
          // What to expect
          Text(
            'WHAT TO EXPECT',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 10.sp,
              letterSpacing: 1.4.sp,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: 8.r),
          for (final line in guide.whatToExpect)
            Padding(
              padding: EdgeInsets.only(bottom: 6.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6.r, right: 8.r),
                    child: Container(
                      width: 5.r, height: 5.r,
                      decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                        height: 1.4,
                        color: AppColors.paper.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 12.r),
          Container(height: 1, color: AppColors.border),
          SizedBox(height: 12.r),
          // Dress + Bring in a row
          Row(
            children: [
              Icon(Icons.checkroom_rounded, size: 14.r, color: AppColors.muted),
              SizedBox(width: 6.r),
              Text(
                'DRESS',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 9.sp,
                  letterSpacing: 1.4.sp,
                  color: AppColors.muted,
                ),
              ),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  guide.dressVibe,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: AppColors.paper,
                  ),
                ),
              ),
            ],
          ),
          if (guide.whatToBring.isNotEmpty) ...[
            SizedBox(height: 10.r),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.r),
                  child: Icon(Icons.shopping_bag_outlined, size: 14.r, color: AppColors.muted),
                ),
                SizedBox(width: 6.r),
                Padding(
                  padding: EdgeInsets.only(top: 2.r),
                  child: Text(
                    'BRING',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 9.sp,
                      letterSpacing: 1.4.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                SizedBox(width: 8.r),
                Expanded(
                  child: Text(
                    guide.whatToBring.join(' · '),
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      height: 1.4,
                      color: AppColors.paper,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BUDDY MATCH — auto-pair first-timers with a regular
// ═══════════════════════════════════════════════════════════════════════════

class _BuddyMatchCard extends StatefulWidget {
  final String hostName;
  final Color accent;
  const _BuddyMatchCard({required this.hostName, required this.accent});

  @override
  State<_BuddyMatchCard> createState() => _BuddyMatchCardState();
}

class _BuddyMatchCardState extends State<_BuddyMatchCard> {
  static const _buddyPool = ['Aditi', 'Ravi', 'Meera', 'Kabir', 'Sana', 'Priya'];
  static const _buddyAvatars = [
    'https://i.pravatar.cc/100?img=32',
    'https://i.pravatar.cc/100?img=12',
    'https://i.pravatar.cc/100?img=41',
    'https://i.pravatar.cc/100?img=15',
    'https://i.pravatar.cc/100?img=45',
    'https://i.pravatar.cc/100?img=47',
  ];

  String? _matchedName;
  String? _matchedAvatar;

  void _match() {
    HapticFeedback.mediumImpact();
    // Deterministic pick based on host name so it feels tailored, not random.
    final idx = widget.hostName.hashCode.abs() % _buddyPool.length;
    setState(() {
      _matchedName = _buddyPool[idx];
      _matchedAvatar = _buddyAvatars[idx];
    });
  }

  @override
  Widget build(BuildContext context) {
    final matched = _matchedName != null;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: matched ? AppColors.lime.withValues(alpha: 0.12) : AppColors.graphite,
        border: Border.all(
          color: matched ? AppColors.lime.withValues(alpha: 0.5) : AppColors.border,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: matched ? _buildMatchedState() : _buildInviteState(),
    );
  }

  Widget _buildInviteState() {
    return Row(
      children: [
        // Stacked avatars illustration
        SizedBox(
          width: 60.r,
          height: 42.r,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.graphite, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded, color: widget.accent, size: 18.r),
                ),
              ),
              Positioned(
                left: 22.r,
                child: Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.25),
                    border: Border.all(color: AppColors.graphite, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded, color: AppColors.lime, size: 18.r),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.r),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BUDDY MATCH',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 10.sp,
                  letterSpacing: 1.4.sp,
                  color: widget.accent,
                ),
              ),
              SizedBox(height: 4.r),
              Text(
                "we'll pair you with a regular who'll meet you at the door.",
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  height: 1.35,
                  color: AppColors.paper.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.r),
        GestureDetector(
          onTap: _match,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
            decoration: BoxDecoration(
              color: widget.accent,
              borderRadius: BorderRadius.circular(Corners.pill),
            ),
            child: Text(
              'MATCH ME',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 1.2.sp,
                color: widget.accent.computeLuminance() > 0.55 ? AppColors.onNeon : AppColors.paper,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchedState() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: AppColors.surfaceRaised,
          backgroundImage: NetworkImage(_matchedAvatar!),
        ),
        SizedBox(width: 12.r),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.lime, size: 14.r),
                  SizedBox(width: 6.r),
                  Text(
                    'MATCHED WITH ${_matchedName!.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 11.sp,
                      letterSpacing: 1.2.sp,
                      color: AppColors.lime,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.r),
              Text(
                "we'll DM you on whatsapp 30 mins before. don't stress.",
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  height: 1.35,
                  color: AppColors.paper.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MEMBER VIBES — one-liner testimonials, horizontal scroll
// ═══════════════════════════════════════════════════════════════════════════

class _MemberVibesList extends StatelessWidget {
  final List<MemberVibe> vibes;
  final Color accent;
  const _MemberVibesList({required this.vibes, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vibes.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.r),
        itemBuilder: (context, i) {
          final v = vibes[i];
          return Container(
            width: 240.r,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.graphite,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(Corners.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${v.quote}"',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    height: 1.25,
                    letterSpacing: -0.2.sp,
                    color: AppColors.paper,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    if (v.byAvatarUrl != null) ...[
                      CircleAvatar(
                        radius: 12.r,
                        backgroundColor: AppColors.surfaceRaised,
                        backgroundImage: NetworkImage(v.byAvatarUrl!),
                      ),
                      SizedBox(width: 8.r),
                    ],
                    Text(
                      '— ${v.byName}',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                        letterSpacing: 0.6.sp,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VIBE CHECK — 3 quick tags describing the community's personality
// ═══════════════════════════════════════════════════════════════════════════

class _VibeCheck extends StatelessWidget {
  final List<String> tags;
  final Color accent;
  const _VibeCheck({required this.tags, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.r,
      runSpacing: 8.r,
      children: [
        for (final tag in tags)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              border: Border.all(color: accent.withValues(alpha: 0.45)),
              borderRadius: BorderRadius.circular(Corners.pill),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                letterSpacing: 0.2.sp,
                color: AppColors.paper,
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WALL HEADER — tappable "MEMORY · THE WALL · N MOMENTS ·  SEE ALL →"
// ═══════════════════════════════════════════════════════════════════════════

class _WallHeader extends StatelessWidget {
  final Community community;
  const _WallHeader({required this.community});

  void _openWall(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PhotoWallScreen(community: community)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = community.wallPhotos.length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openWall(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 14.r, height: 3, color: AppColors.lime),
                    SizedBox(width: 8.r),
                    Text(
                      'MEMORY · $count MOMENTS',
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
                SizedBox(height: 4.r),
                Text(
                  'THE WALL',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 22.sp,
                    height: 1.0,
                    letterSpacing: -0.6.sp,
                    color: AppColors.paper,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(Corners.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SEE ALL',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 10.sp,
                    letterSpacing: 1.2.sp,
                    color: AppColors.paper,
                  ),
                ),
                SizedBox(width: 6.r),
                Icon(Icons.arrow_forward_rounded, size: 12.r, color: AppColors.paper),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MEMORY WALL PREVIEW — 6-photo tease that opens the full gallery on tap
// ═══════════════════════════════════════════════════════════════════════════

class _MemoryWallPreview extends StatelessWidget {
  final Community community;
  const _MemoryWallPreview({required this.community});

  @override
  Widget build(BuildContext context) {
    final all = community.wallPhotos;
    final preview = all.take(6).toList();
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PhotoWallScreen(community: community)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.r,
              mainAxisSpacing: 4.r,
              childAspectRatio: 1.0,
            ),
            itemCount: preview.length,
            itemBuilder: (context, i) {
              final p = preview[i];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => PhotoViewerScreen(
                        photos: all,
                        initialIndex: i,
                        communityName: community.name,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.sm),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      HatriImage(url: p.photoUrl, fit: BoxFit.cover, errorWidget: Container(color: AppColors.surfaceRaised),
                      ),
                      if (i == preview.length - 1 && all.length > preview.length)
                        Container(
                          color: Colors.black.withValues(alpha: 0.55),
                          alignment: Alignment.center,
                          child: Text(
                            '+${all.length - preview.length}',
                            style: TextStyle(
                              fontFamily: 'ClashDisplay',
                              fontWeight: FontWeight.w800,
                              fontSize: 22.sp,
                              color: AppColors.paper,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MEMORY WALL (legacy — kept for backwards compat if anything else references it)
// ═══════════════════════════════════════════════════════════════════════════

class _MemoryWall extends StatelessWidget {
  final List<WallPhoto> photos;
  const _MemoryWall({required this.photos});

  @override
  Widget build(BuildContext context) {
    // Group by event so each past event gets a mini-header + horizontal strip.
    final byEvent = <String, List<WallPhoto>>{};
    for (final p in photos) {
      byEvent.putIfAbsent(p.eventTitle, () => []).add(p);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in byEvent.entries) ...[
          Row(
            children: [
              Text(
                entry.key.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 11.sp,
                  letterSpacing: 1.2.sp,
                  color: AppColors.paper,
                ),
              ),
              SizedBox(width: 8.r),
              Text(
                '· ${entry.value.length} PHOTOS',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 1.2.sp,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.r),
          SizedBox(
            height: 110.r,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: entry.value.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.r),
              itemBuilder: (context, i) {
                final p = entry.value[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.sm),
                  child: SizedBox(
                    width: 110.r,
                    height: 110.r,
                    child: HatriImage(url: p.photoUrl, fit: BoxFit.cover, errorWidget: Container(color: AppColors.surfaceRaised),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 18.r),
        ],
      ],
    );
  }
}

class _HalftoneOverlay extends StatelessWidget {
  const _HalftoneOverlay();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.1,
      child: HalftoneBackground(
        dotColor: AppColors.paper,
        spacing: 14,
        dotSize: 1.8,
      ),
    );
  }
}

/// Small polyfill so `firstOrNull` works without importing `package:collection`.
extension _IterableExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
