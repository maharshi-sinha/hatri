import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/injection_container.dart';
import '../../core/models/models.dart';
import '../../core/repositories/creator_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import '../creators/creator_profile_screen.dart';
import '../plans/start_plan_screen.dart';
import 'ticket_reveal_screen.dart';
import '../../core/responsive/responsive.dart';

/// Event details — rebuilt in the new brutalist visual language.
/// Adds: who's-going faces, lineup display, share sheet.
class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isSaved = false;
  bool _isRsvpd = false;

  List<CreatorProfile> _lineup = [];
  bool _loadingLineup = false;
  CreatorProfile? _organizer;

  Event get event => widget.event;

  @override
  void initState() {
    super.initState();
    _loadLineup();
    _loadOrganizer();
  }

  Future<void> _loadOrganizer() async {
    if (event.organizerId == null) return;
    final repo = sl<CreatorRepository>();
    final o = await repo.getById(event.organizerId!);
    if (!mounted) return;
    setState(() => _organizer = o);
  }

  Future<void> _loadLineup() async {
    if (event.lineup.isEmpty) return;
    setState(() => _loadingLineup = true);
    final repo = sl<CreatorRepository>();
    final all = await Future.wait(event.lineup.map(repo.getById));
    if (!mounted) return;
    setState(() {
      _lineup = all.whereType<CreatorProfile>().toList();
      _loadingLineup = false;
    });
  }

  void _openStartPlan() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StartPlanScreen(event: event)),
    );
  }

  void _toggleSaved() {
    HapticFeedback.selectionClick();
    setState(() => _isSaved = !_isSaved);
  }

  Future<void> _handleRsvp() async {
    HapticFeedback.mediumImpact();
    if (_isRsvpd) {
      setState(() => _isRsvpd = false);
      return;
    }
    setState(() => _isRsvpd = true);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketRevealScreen(event: event),
      ),
    );
  }

  Future<void> _openOrganizerProfile() async {
    if (event.organizerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.graphite,
          content: Text(
            'This organizer doesn\'t have a profile yet.',
            style: TextStyle(color: AppColors.paper),
          ),
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    final profile = await sl<CreatorRepository>().getById(event.organizerId!);
    if (!mounted || profile == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreatorProfileScreen(creator: profile)),
    );
  }

  void _openCreatorProfile(CreatorProfile c) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreatorProfileScreen(creator: c)),
    );
  }

  void _openShare() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ShareSheet(event: event, isRsvpd: _isRsvpd),
    );
  }

  Future<void> _openMaps() async {
    final url = event.mapsUrl ??
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${event.venue} Raipur')}';
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final eventColor = AppColors.fromHex(event.colorHex);
    final onEvent = eventColor.computeLuminance() > 0.55 ? AppColors.onNeon : AppColors.paper;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHero(eventColor, onEvent),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, 120.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTrustStrip(),
                      _buildInfoPills(),
                      SizedBox(height: 12.r),
                      _buildVenueRow(eventColor),
                      SizedBox(height: 20.r),
                      const _HatriDivider(),
                      SizedBox(height: 20.r),
                      _buildOrganizerRow(eventColor),
                      SizedBox(height: 20.r),
                      _buildDescription(),
                      if (_lineup.isNotEmpty || _loadingLineup) ...[
                        SizedBox(height: 24.r),
                        _buildLineup(eventColor),
                      ],
                      SizedBox(height: 24.r),
                      _buildWhosGoing(eventColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomCta(eventColor, onEvent),
        ],
      ),
    );
  }

  // ---------------- HERO ----------------

  SliverAppBar _buildHero(Color eventColor, Color onEvent) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: false,
      backgroundColor: AppColors.ground,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover
            Image.network(
              event.coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: eventColor),
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
                  spacing: 10.r,
                  dotSize: 2,
                ),
              ),
            ),
            // Bottom gradient for legibility
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [
                      Colors.transparent,
                      AppColors.ground.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),
            ),
            // Top-left/right icon buttons + top stickers
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: Insets.lg,
              right: Insets.lg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _iconChip(Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                  Row(
                    children: [
                      _svgChip('assets/icons/Upload.svg', onTap: _openShare),
                      SizedBox(width: 8.r),
                      _svgChip(
                        'assets/icons/Bookmark.svg',
                        onTap: _toggleSaved,
                        activeColor: _isSaved ? AppColors.lime : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Corner sticker overlays
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: Insets.lg,
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
            // Bottom title block
            Positioned(
              left: Insets.lg,
              right: Insets.lg,
              bottom: 20.r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryTag(label: event.category.label, color: eventColor),
                      SizedBox(width: 6.r),
                      if (event.isSafeVenue) const SafeVenueChip(),
                    ],
                  ),
                  SizedBox(height: 10.r),
                  Text(
                    event.title.toUpperCase(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 34.sp,
                      height: 0.96,
                      letterSpacing: -0.8.sp,
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
          color: AppColors.ground.withValues(alpha: 0.65),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: child,
      ),
    );
  }

  // ---------------- INFO PILLS ----------------

  // ---------------- TRUST STRIP ----------------

  Widget _buildTrustStrip() {
    final chips = <Widget>[];
    if (_organizer?.isVerified == true) {
      chips.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
          decoration: BoxDecoration(
            color: AppColors.fuchsia.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.fuchsia.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(Corners.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VerifiedBadge(size: 12.r),
              SizedBox(width: 4.r),
              Text(
                'VERIFIED ORGANIZER',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 9.sp,
                  letterSpacing: 1.2.sp,
                  color: AppColors.fuchsia,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if ((_organizer?.rating ?? 0) > 0) {
      chips.add(StarRating(rating: _organizer!.rating, size: 12.r));
    }
    if (event.isSafeVenue) {
      chips.add(const SafeVenueChip());
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.r),
      child: Wrap(spacing: 6.r, runSpacing: 6.r, children: chips),
    );
  }

  Widget _buildInfoPills() {
    return Row(
      children: [
        Expanded(
          child: _infoPill(
            svgIcon: 'assets/icons/events.svg',
            label: DateFormat('EEE, MMM d').format(event.date),
          ),
        ),
        SizedBox(width: 8.r),
        Expanded(
          child: _infoPill(
            svgIcon: 'assets/icons/TimeCircle.svg',
            label: event.time,
          ),
        ),
        SizedBox(width: 8.r),
        Expanded(
          child: _infoPill(
            svgIcon: event.isFree
                ? 'assets/icons/TickSquare.svg'
                : 'assets/icons/indian-rupee.svg',
            label: event.isFree ? 'FREE' : 'PAID',
            highlight: event.isFree ? AppColors.lime : AppColors.fuchsia,
          ),
        ),
      ],
    );
  }

  Widget _infoPill({required String svgIcon, required String label, Color? highlight}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgIcon,
            width: 14.r,
            height: 14.r,
            colorFilter:
                ColorFilter.mode(highlight ?? AppColors.muted, BlendMode.srcIn),
          ),
          SizedBox(width: 6.r),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                letterSpacing: 0.3.sp,
                color: highlight ?? AppColors.paper,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueRow(Color eventColor) {
    return GestureDetector(
      onTap: _openMaps,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 14.r),
        decoration: BoxDecoration(
          color: eventColor.withValues(alpha: 0.10),
          border: Border.all(color: eventColor.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/Location.svg',
              width: 18.r,
              height: 18.r,
              colorFilter: ColorFilter.mode(eventColor, BlendMode.srcIn),
            ),
            SizedBox(width: 10.r),
            Expanded(
              child: Text(
                event.venue,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: AppColors.paper,
                ),
              ),
            ),
            SizedBox(width: 8.r),
            Text(
              event.mapsUrl != null ? 'OPEN IN MAPS' : 'FIND ON MAPS',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 1.0.sp,
                color: eventColor,
              ),
            ),
            SizedBox(width: 4.r),
            Icon(Icons.arrow_outward_rounded, size: 12.r, color: eventColor),
          ],
        ),
      ),
    );
  }

  // ---------------- ORGANIZER ----------------

  Widget _buildOrganizerRow(Color eventColor) {
    final hasProfile = event.organizerId != null;
    return GestureDetector(
      onTap: hasProfile ? _openOrganizerProfile : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: eventColor.withValues(alpha: 0.18),
              border: Border.all(color: eventColor.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(Corners.md),
            ),
            alignment: Alignment.center,
            child: Text(event.category == EventCategory.market ? '🛒' : '🎪',
                style: TextStyle(fontSize: 20.sp)),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORGANIZED BY',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 10.sp,
                    letterSpacing: 1.4.sp,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        event.organizer,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: AppColors.paper,
                        ),
                      ),
                    ),
                    if (hasProfile) ...[
                      SizedBox(width: 4.r),
                      Icon(Icons.chevron_right_rounded,
                          size: 18.r, color: AppColors.muted),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (hasProfile)
            GestureDetector(
              onTap: _openOrganizerProfile,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 7.r),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(Corners.pill),
                ),
                child: Text(
                  'VIEW',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                    letterSpacing: 1.0.sp,
                    color: AppColors.paper,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- DESCRIPTION ----------------

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.description,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            height: 1.5,
            color: AppColors.paper,
          ),
        ),
      ],
    );
  }

  // ---------------- LINEUP ----------------

  Widget _buildLineup(Color eventColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StickerLabel(
              text: '🎤 LINEUP',
              background: eventColor,
              foreground: eventColor.computeLuminance() > 0.55
                  ? AppColors.onNeon
                  : AppColors.paper,
            ),
            SizedBox(width: 8.r),
            Text(
              '${_lineup.length} PERFORMING',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w700,
                fontSize: 10.sp,
                letterSpacing: 1.2.sp,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.r),
        SizedBox(
          height: 88.r,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _lineup.length,
            separatorBuilder: (_, i) => SizedBox(width: 10.r),
            itemBuilder: (context, i) {
              final c = _lineup[i];
              return GestureDetector(
                onTap: () => _openCreatorProfile(c),
                behavior: HitTestBehavior.opaque,
                child: _PerformerChip(creator: c),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- WHO'S GOING ----------------

  Widget _buildWhosGoing(Color eventColor) {
    final attendees = event.attendees;
    final count = event.rsvpCount + (_isRsvpd ? 1 : 0);
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (attendees.isNotEmpty)
                SizedBox(
                  width: 22.0.r * (attendees.length.clamp(0, 5)).toDouble() + 20,
                  height: 36.r,
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
                              radius: 15.r,
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
                    Row(
                      children: [
                        _pulseDot(eventColor),
                        SizedBox(width: 6.r),
                        Text(
                          '$count going',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 15.sp,
                            color: AppColors.paper,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      attendees.isNotEmpty
                          ? '${attendees.first.name}${attendees.length > 1 ? ' + ${attendees.length - 1} friends' : ''}'
                          : 'Be the first to RSVP',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.r),
          GestureDetector(
            onTap: _openStartPlan,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 11.r),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: AppColors.lime, width: 1.4),
                borderRadius: BorderRadius.circular(Corners.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add_rounded, size: 16.r, color: AppColors.lime),
                  SizedBox(width: 8.r),
                  Text(
                    'BRING FRIENDS · START A PLAN',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 12.sp,
                      letterSpacing: 1.0.sp,
                      color: AppColors.lime,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  // ---------------- BOTTOM CTA ----------------

  Widget _buildBottomCta(Color eventColor, Color onEvent) {
    final label = _isRsvpd
        ? '✓ TICKET SECURED'
        : (event.isFree ? '📌 Claim free ticket' : '📌 Get ticket');
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
        child: ElevatedButton(
          onPressed: _handleRsvp,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRsvpd ? Colors.transparent : eventColor,
            foregroundColor: _isRsvpd ? eventColor : onEvent,
            padding: EdgeInsets.symmetric(vertical: 16.r),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Corners.md),
            ),
            side: BorderSide(color: eventColor, width: 2),
            elevation: 0,
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 14.sp,
              letterSpacing: 0.6.sp,
              color: _isRsvpd ? eventColor : onEvent,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Divider ----------------

class _HatriDivider extends StatelessWidget {
  const _HatriDivider();
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        color: AppColors.border,
      );
}

// ---------------- Performer chip (used in lineup) ----------------

class _PerformerChip extends StatelessWidget {
  final CreatorProfile creator;
  const _PerformerChip({required this.creator});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.r,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: AppColors.surfaceRaised,
                backgroundImage: NetworkImage(creator.avatarUrl),
              ),
              if (creator.isVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: VerifiedBadge(size: 14.r),
                ),
            ],
          ),
          SizedBox(height: 6.r),
          Text(
            creator.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w700,
              fontSize: 11.sp,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Share sheet ----------------

class _ShareSheet extends StatelessWidget {
  final Event event;
  final bool isRsvpd;
  const _ShareSheet({required this.event, required this.isRsvpd});

  String get _shareText {
    final date = DateFormat('EEE, MMM d').format(event.date);
    final prefix = isRsvpd ? "I'm going to " : "Check this out: ";
    return "$prefix${event.title} 🎟️\n$date · ${event.time} · ${event.venue}\n\nvia Hatri — Raipur's digital haat";
  }

  Future<void> _share(BuildContext context) async {
    await Share.share(_shareText, subject: event.title);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromHex(event.colorHex);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.graphite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Corners.xl)),
        border: Border(
          top: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + Insets.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.r),
          Container(
            width: 42.r,
            height: 4.r,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 14.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Row(
              children: [
                const StickerLabel(
                  text: 'SHARE',
                  background: AppColors.lime,
                  foreground: AppColors.onNeon,
                ),
                SizedBox(width: 8.r),
                Text(
                  isRsvpd ? "I'm going · flex it" : 'Send to your people',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                    color: AppColors.paper,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.r),
          // Flex card preview
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: _FlexPreview(event: event, accent: accent, isRsvpd: isRsvpd),
          ),
          SizedBox(height: 16.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: PrimaryButton(
              label: 'Share',
              svgIcon: 'assets/icons/Upload.svg',
              expand: true,
              onPressed: () => _share(context),
            ),
          ),
          SizedBox(height: 8.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Text(
              'Pro tip: screenshot this preview for the story flex 📸',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlexPreview extends StatelessWidget {
  final Event event;
  final Color accent;
  final bool isRsvpd;
  const _FlexPreview({required this.event, required this.accent, required this.isRsvpd});

  @override
  Widget build(BuildContext context) {
    final onAccent = accent.computeLuminance() > 0.55 ? AppColors.onNeon : AppColors.paper;
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Corners.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              event.coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: accent),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.22,
                child: HalftoneBackground(
                  dotColor: AppColors.onNeon,
                  spacing: 10.r,
                  dotSize: 2,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 1.0],
                    colors: [
                      Colors.transparent,
                      AppColors.onNeon.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            // Top badge
            Positioned(
              top: 12.r,
              left: 12.r,
              child: StickerLabel(
                text: isRsvpd ? "I'M GOING 🎟️" : 'HAPPENING IN RAIPUR',
                background: accent,
                foreground: onAccent,
              ),
            ),
            // Bottom title + meta
            Positioned(
              left: 14.r,
              right: 14.r,
              bottom: 12.r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title.toUpperCase(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 26.sp,
                      height: 0.96,
                      letterSpacing: -0.6.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Text(
                    '${DateFormat('EEE, MMM d').format(event.date).toUpperCase()} · ${event.time}',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 12.sp,
                      letterSpacing: 0.6.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  Text(
                    event.venue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 10.r),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HATRI',
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                          letterSpacing: -0.4.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      Text(
                        'RAIPUR',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                          letterSpacing: 1.4.sp,
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
    );
  }
}
