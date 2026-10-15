import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../shared/widgets/hatri_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../backend/api/api_exception.dart';
import '../../../../backend/models/ticket_models.dart';
import '../../../../backend/services/events_service.dart';
import '../../../../backend/services/tickets_service.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/models/models.dart';
import '../../../../core/repositories/creator_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/auth_prompt/login_prompt_sheet.dart';
import '../../../../shared/auth_prompt/require_auth.dart';
import '../../../../shared/design/hatri_snack.dart';
import '../../../../shared/design/components.dart';
import '../../../../shared/design/motifs.dart';
import '../../../creators/presentation/pages/creator_profile_screen.dart';
import '../../../plans/start_plan_screen.dart';
import '../../../../core/saved/saved_events_store.dart';
import 'ticket_reveal_screen.dart';
import '../widgets/ticket_tier_sheet.dart';
import '../../../../core/responsive/responsive.dart';

/// Event details — rebuilt in the new brutalist visual language.
/// Adds: who's-going faces, lineup display, share sheet.
class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  /// Backend ticket for this user + event, or null if none.
  ApiTicket? _ticket;
  bool _isClaiming = false;
  bool get _isRsvpd => _ticket?.status == TicketStatus.confirmed;
  bool get _isSaved => SavedEventsStore.instance.isSaved(event.id);

  bool _loadingOrganizer = true;
  CreatorProfile? _organizer;

  final ScrollController _scrollController = ScrollController();
  double _collapsedTitleOpacity = 0;

  /// Enriched copy of [widget.event] once the /events/:id detail endpoint
  /// returns. Falls back to the card data passed from the list until then.
  Event? _rich;

  Event get event => _rich ?? widget.event;

  @override
  void initState() {
    super.initState();
    _loadOrganizer();
    _loadRichDetail();
    _loadMyTicket();
    _scrollController.addListener(_onScroll);
    unawaited(sl<AnalyticsService>().eventOpened(eventId: event.id));
  }

  /// Fetches my ticket for this event so the CTA renders in the right state
  /// (GET TICKET / VIEW TICKET). Silent failure → assume no ticket.
  Future<void> _loadMyTicket() async {
    try {
      final t = await sl<TicketsService>().myTicketFor(widget.event.id);
      if (!mounted) return;
      setState(() => _ticket = t);
    } catch (_) {
      // Treat as no-ticket-yet.
    }
  }

  /// Fire-and-forget: fetch full detail (description, real counts, maker)
  /// and swap in when it lands. Silent failure so the screen still renders
  /// off card data.
  Future<void> _loadRichDetail() async {
    try {
      final rich = await sl<EventsService>().getById(widget.event.id);
      if (!mounted) return;
      setState(() => _rich = rich);
    } catch (_) {
      // Card data continues to render.
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Title fades in fully by the time the cover is 70% scrolled out.
    const start = 180.0;
    const end = 260.0;
    final o = ((_scrollController.offset - start) / (end - start)).clamp(0.0, 1.0);
    if ((o - _collapsedTitleOpacity).abs() > 0.02) {
      setState(() => _collapsedTitleOpacity = o);
    }
  }

  Future<void> _loadOrganizer() async {
    if (event.organizerId == null) return;
    final repo = sl<CreatorRepository>();
    final o = await repo.getById(event.organizerId!);
    if (!mounted) return;
    setState(() => _organizer = o);
  }

  Future<void> _openStartPlan() async {
    await requireAuth(
      context,
      reason: LoginReason.generic,
      customLine: 'plans go better with your crew. sign in to start one. 🧃',
      onAuthed: () async {
        HapticFeedback.selectionClick();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StartPlanScreen(event: event)),
        );
      },
    );
  }

  Future<void> _toggleSaved() async {
    await requireAuth(
      context,
      reason: LoginReason.save,
      onAuthed: () async {
        HapticFeedback.selectionClick();
        // Optimistic local flip — snappy UI.
        final wasSaved = _isSaved;
        SavedEventsStore.instance.toggle(event.id);
        setState(() {});
        unawaited(sl<AnalyticsService>()
            .eventSaved(eventId: event.id, saved: !wasSaved));
        // Best-effort backend sync. On failure, revert local so the two agree.
        try {
          if (wasSaved) {
            await sl<EventsService>().unsave(event.id);
          } else {
            await sl<EventsService>().save(event.id);
          }
        } catch (_) {
          SavedEventsStore.instance.toggle(event.id);
          if (mounted) setState(() {});
        }
      },
    );
  }

  /// Single dispatcher for the CTA button. Behavior:
  ///  * Have a confirmed ticket    → open reveal screen (no claim).
  ///  * Paid event, no ticket      → coming-soon snackbar (Razorpay is v2).
  ///  * Free event, no ticket      → confirmation sheet → POST rsvp → reveal.
  Future<void> _handleRsvp() async {
    HapticFeedback.mediumImpact();

    // Already have a ticket → skip confirmation, jump straight to the
    // finished-ticket state (no printer chug on re-views).
    if (_isRsvpd) {
      await _openReveal(skipAnimation: true);
      return;
    }

    if (!event.isFree) {
      HatriSnack.show(
        context,
        'paid events launch in v2 — free ones work today',
        vibe: SnackVibe.info,
        emoji: '⏳',
      );
      return;
    }

    // Gate the claim flow behind sign-in. Returning users with a ticket
    // skip this entirely via the _isRsvpd branch above (they're signed in
    // by definition — the ticket fetch is JWT-authenticated).
    final signedIn = await requireAuth(
      context,
      reason: LoginReason.rsvp,
      onAuthed: () async {},
    );
    if (!signedIn || !mounted) return;

    final confirmed = await _showConfirmSheet();
    if (confirmed != true || !mounted) return;

    setState(() => _isClaiming = true);
    try {
      final ticket = await sl<TicketsService>().rsvp(event.id);
      unawaited(sl<AnalyticsService>().eventRsvpd(eventId: event.id));
      if (!mounted) return;
      setState(() {
        _ticket = ticket;
        _isClaiming = false;
      });
      await _openReveal();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isClaiming = false);
      HatriSnack.show(
        context,
        _friendlyRsvpError(e),
        vibe: SnackVibe.info,
        emoji: '⚠️',
      );
    }
  }

  Future<void> _openReveal({bool skipAnimation = false}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => TicketRevealScreen(
          event: event,
          ticket: _ticket,
          skipAnimation: skipAnimation,
        ),
      ),
    );
    // On return, refetch ticket — the user may have cancelled from reveal.
    if (mounted) _loadMyTicket();
  }

  Future<bool?> _showConfirmSheet() {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.ground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(Corners.lg.toDouble())),
      ),
      builder: (ctx) => _RsvpConfirmSheet(event: event),
    );
  }

  String _friendlyRsvpError(ApiException e) {
    if (e is NetworkException) return 'no network. try again.';
    if (e is UnauthorizedException) return 'sign in to claim tickets.';
    if (e is NotFoundException) return "event isn't live yet.";
    if (e is ClientException) {
      if (e.statusCode == 409) return 'sold out.';
      return e.message;
    }
    return 'could not claim ticket. try again.';
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
    unawaited(sl<AnalyticsService>().shareOpened(eventId: event.id));
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
            controller: _scrollController,
            slivers: [
              _buildHero(eventColor, onEvent),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, 160.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoPills(),
                      SizedBox(height: 12.r),
                      _buildVenueRow(eventColor),
                      SizedBox(height: 16.r),
                      _buildTrustStrip(),
                      const _HatriDivider(),
                      SizedBox(height: 20.r),
                      _buildOrganizerRow(eventColor),
                      SizedBox(height: 20.r),
                      _buildDescription(),
                      SizedBox(height: 24.r),
                      _buildWhosGoing(eventColor),
                      SizedBox(height: 24.r),
                      _buildQuickFacts(eventColor),
                      SizedBox(height: 20.r),
                      _buildQueriesCard(eventColor),
                      SizedBox(height: 20.r),
                      _buildTerms(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Collapsed-header title strip — fades in as cover scrolls out.
          // Sits BEHIND the icon chip row so those stay tappable, and gets a
          // solid ground bg so text-on-content doesn't muddy up.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: _collapsedTitleOpacity,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20.r,
                    bottom: 24.r,
                    left: 76.r,
                    right: 124.r,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ground,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.border.withValues(alpha: _collapsedTitleOpacity),
                      ),
                    ),
                  ),
                  child: Text(
                    event.title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                      height: 1.2,
                      letterSpacing: -0.2.sp,
                      color: AppColors.paper,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Header — back/share/bookmark chips sit on top of everything.
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.r,
            left: Insets.lg,
            right: Insets.lg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _svgChip('assets/icons/arrow-left.svg', onTap: () => Navigator.pop(context)),
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
          _buildBottomCta(eventColor, onEvent),
        ],
      ),
    );
  }

  // ---------------- HERO ----------------

  SliverAppBar _buildHero(Color eventColor, Color onEvent) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,                     // toolbar stays after collapse
      stretch: true,
      backgroundColor: AppColors.ground,
      surfaceTintColor: AppColors.ground,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover
            HatriImage(
              url: event.coverUrl,
              fit: BoxFit.cover,
              errorWidget: Container(color: eventColor),
              placeholder: Container(color: AppColors.surfaceRaised),
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
            // Corner sticker overlays — sit well below the pinned header row
            // so they never collide with back/share/bookmark on any scroll offset.
            Positioned(
              top: MediaQuery.of(context).padding.top + 100.r,
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
        width: 42.r,
        height: 42.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.ground.withValues(alpha: 0.85),
          border: Border.all(color: AppColors.paper.withValues(alpha: 0.08)),
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
      chips.add(_TrustChip(
        icon: Icons.verified_rounded,
        color: AppColors.fuchsia,
        label: 'VERIFIED',
      ));
    }
    if ((_organizer?.rating ?? 0) > 0) {
      chips.add(_TrustChip(
        icon: Icons.star_rounded,
        color: AppColors.lime,
        label: '${_organizer!.rating.toStringAsFixed(1)} · ${_organizer!.followerCount} FOLLOW',
      ));
    }
    if (event.isSafeVenue) {
      chips.add(_TrustChip(
        svgPath: 'assets/icons/Shield.svg',
        color: AppColors.indigo,
        label: 'SAFE VENUE',
      ));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 20.r),
      child: Wrap(
        spacing: 8.r,
        runSpacing: 8.r,
        children: chips,
      ),
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
            width: 18.r,
            height: 18.r,
            colorFilter:
                ColorFilter.mode(highlight ?? AppColors.muted, BlendMode.srcIn),
          ),
          SizedBox(width: 8.r),
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
                      SvgPicture.asset(
                        'assets/icons/arrow-right.svg',
                        width: 18.r,
                        height: 18.r,
                        colorFilter: const ColorFilter.mode(AppColors.muted, BlendMode.srcIn),
                      ),
                    ],
                  ],
                ),
              ],
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



  // ---------------- WHO'S GOING ----------------

  Widget _buildWhosGoing(Color eventColor) {
    final attendees = event.attendees;
    final count = event.rsvpCount + (_isRsvpd ? 1 : 0);
    return Container(
      padding: EdgeInsets.fromLTRB(14.r, 14.r, 14.r, 18.r),
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

  // ---------------- QUICK FACTS (2-col info cards) ----------------

  Widget _buildQuickFacts(Color eventColor) {
    // Derive sensible defaults from category if the event doesn't have data.
    final language = 'HINDI · ENGLISH';
    final duration = _durationFromCategory(event.category);
    final age = _ageFromCategory(event.category);
    final layout = event.isSafeVenue ? 'INDOOR · SAFE VENUE' : 'INDOOR';
    final type = event.category.label.toUpperCase();

    final tiles = [
      _FactTile(icon: Icons.access_time_rounded, label: 'DURATION', value: duration, accent: eventColor),
      _FactTile(icon: Icons.language_rounded, label: 'LANGUAGE', value: language, accent: eventColor),
      _FactTile(icon: Icons.person_outline_rounded, label: 'AGE', value: age, accent: eventColor),
      _FactTile(icon: Icons.location_city_rounded, label: 'LAYOUT', value: layout, accent: eventColor),
      _FactTile(icon: Icons.local_activity_rounded, label: 'TYPE', value: type, accent: eventColor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 14.r, height: 3, color: AppColors.lime),
            SizedBox(width: 8.r),
            Text(
              'GOOD TO KNOW',
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
        SizedBox(height: 12.r),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = (constraints.maxWidth - 10.r) / 2;
            return Wrap(
              spacing: 10.r,
              runSpacing: 10.r,
              children: [
                for (final t in tiles) SizedBox(width: w, child: t),
              ],
            );
          },
        ),
      ],
    );
  }

  String _durationFromCategory(EventCategory c) {
    switch (c) {
      case EventCategory.fest: return '3 DAYS';
      case EventCategory.clubNight: return '5 HOURS';
      case EventCategory.openMic: return '2 HOURS';
      case EventCategory.market: return '4 HOURS';
      case EventCategory.workshop: return '3 HOURS';
      case EventCategory.meetup: return '2 HOURS';
      case EventCategory.other: return '2 HOURS';
    }
  }

  String _ageFromCategory(EventCategory c) {
    switch (c) {
      case EventCategory.clubNight: return '21+';
      case EventCategory.market: return 'ALL AGES';
      case EventCategory.workshop: return 'ALL AGES';
      default: return '18+';
    }
  }

  // ---------------- QUERIES CARD ----------------

  Widget _buildQueriesCard(Color eventColor) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openFaqScreen,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.fromHex('#FF7A00').withValues(alpha: 0.14),
          border: Border.all(color: AppColors.fromHex('#FF7A00').withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Row(
          children: [
            Container(
              width: 42.r, height: 42.r,
              decoration: BoxDecoration(
                color: AppColors.fromHex('#FF7A00'),
                borderRadius: BorderRadius.circular(Corners.sm),
              ),
              child: Icon(Icons.headphones_rounded, color: AppColors.paper, size: 22.r),
            ),
            SizedBox(width: 14.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'HAVE QUERIES?',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 13.sp,
                      letterSpacing: 1.2.sp,
                      color: AppColors.fromHex('#FF7A00'),
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    'hit us up · we usually reply in an hour',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: AppColors.paper.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
                        'assets/icons/arrow-right.svg',
                        width: 22.r,
                        height: 22.r,
                        colorFilter: ColorFilter.mode(AppColors.fromHex('#FF7A00'), BlendMode.srcIn),
                      ),
          ],
        ),
      ),
    );
  }

  // ---------------- EVENT TERMS & CONDITIONS ----------------

  Widget _buildTerms() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openTermsScreen,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 18.r),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.paper.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Corners.sm),
              ),
              child: SvgPicture.asset(
                'assets/icons/paper.svg',
                width: 18.r,
                height: 18.r,
                colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: 14.r),
            Expanded(
              child: Text(
                'EVENT TERMS & CONDITIONS',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  letterSpacing: 1.2.sp,
                  color: AppColors.paper,
                ),
              ),
            ),
            SvgPicture.asset(
                        'assets/icons/arrow-right.svg',
                        width: 22.r,
                        height: 22.r,
                        colorFilter: ColorFilter.mode(AppColors.muted, BlendMode.srcIn),
                      ),
          ],
        ),
      ),
    );
  }

  void _openTermsScreen() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _TermsScreen()),
    );
  }

  void _openFaqScreen() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FaqScreen(event: event)),
    );
  }

  // ---------------- BOTTOM CTA ----------------

  Widget _buildBottomCta(Color eventColor, Color onEvent) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.ground,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: EdgeInsets.fromLTRB(
              Insets.lg,
              12.r,
              Insets.lg,
              MediaQuery.of(context).padding.bottom + 12.r,
            ),
            child: Row(
              children: [
                // Price column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.isFree ? 'ENTRY' : 'FROM',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                        letterSpacing: 1.6.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      event.startingPriceLabel,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 26.sp,
                        height: 1.0,
                        letterSpacing: -0.4.sp,
                        color: event.isFree ? AppColors.lime : AppColors.paper,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.r),
                // CTA button
                Expanded(
                  child: StickerShadow(
                    color: AppColors.onNeon,
                    offset: Offset(4.r, 4.r),
                    radius: Corners.md,
                    child: GestureDetector(
                      onTap: (_isClaiming || (!event.isFree && !_isRsvpd) || event.isSoldOut)
                          ? null
                          : _handleRsvp,
                      child: Container(
                        height: 56.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isRsvpd
                              ? Colors.transparent
                              : (event.isSoldOut || (!event.isFree)
                                  ? AppColors.surfaceRaised
                                  : eventColor),
                          border: Border.all(color: eventColor, width: 1.8),
                          borderRadius: BorderRadius.circular(Corners.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isClaiming)
                              SizedBox(
                                height: 18.r,
                                width: 18.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(onEvent),
                                ),
                              )
                            else if (_isRsvpd)
                              Icon(Icons.check_rounded, color: eventColor, size: 20.r)
                            else if (event.isSoldOut)
                              Icon(Icons.block_rounded, color: AppColors.muted, size: 18.r)
                            else if (!event.isFree)
                              Icon(Icons.schedule_rounded, color: AppColors.muted, size: 18.r)
                            else
                              Icon(Icons.confirmation_number_rounded, color: onEvent, size: 18.r),
                            SizedBox(width: 8.r),
                            Text(
                              _isClaiming
                                  ? 'CLAIMING…'
                                  : _isRsvpd
                                      ? 'VIEW TICKET'
                                      : event.isSoldOut
                                          ? 'SOLD OUT'
                                          : (!event.isFree)
                                              ? 'COMING SOON'
                                              : 'GET TICKET',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 15.sp,
                                letterSpacing: 1.2.sp,
                                color: _isRsvpd
                                    ? eventColor
                                    : (event.isSoldOut || (!event.isFree))
                                        ? AppColors.muted
                                        : onEvent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsScreen extends StatelessWidget {
  const _TermsScreen();

  static const _terms = <String>[
    'Tickets are non-transferable, non-modifiable, and non-refundable, except if the event is cancelled by the organiser.',
    'The organiser may adjust the event schedule at their discretion.',
    'Confirmed tickets and updates will be shared via WhatsApp or email.',
    'Entry may be denied for intoxication, disorderly conduct, or dress code violations.',
    'Photography and videography may take place at the venue. By attending you consent to being featured.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64.r,
        leading: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 16.r),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42.r,
                height: 42.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ground.withValues(alpha: 0.85),
                  border: Border.all(color: AppColors.paper.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(Corners.md),
                ),
                child: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  width: 20.r,
                  height: 20.r,
                  colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(Insets.lg, 10.r, Insets.lg, 32.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 24.r, height: 4.r, color: AppColors.fromHex('#FF7A00')),
                      SizedBox(width: 12.r),
                      Text(
                        'THE FINE PRINT',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          letterSpacing: 2.0.sp,
                          color: AppColors.fromHex('#FF7A00'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.r),
                  Text(
                    'TERMS &\nCONDITIONS',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 42.sp,
                      height: 0.95,
                      letterSpacing: -1.0.sp,
                      color: AppColors.paper,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, MediaQuery.of(context).padding.bottom + 40.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 24.r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(Corners.pill),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.paper,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.r),
                        Expanded(
                          child: Text(
                            _terms[i],
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w500,
                              fontSize: 15.sp,
                              height: 1.5,
                              color: AppColors.paper.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: _terms.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

/// Full-page FAQ — same visual language as the T&C screen, with an
/// expandable accordion of event-aware Q&A. Opened from the "HAVE QUERIES?"
/// card on event details.
class _FaqScreen extends StatefulWidget {
  final Event event;
  const _FaqScreen({required this.event});

  @override
  State<_FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<_FaqScreen> {
  int? _openIndex;

  List<_FaqItem> get _items {
    final e = widget.event;
    final baseline = <_FaqItem>[
      _FaqItem(
        'When should I arrive?',
        'Doors usually open 30 minutes before ${e.time}. Come early if it\'s your first ${e.category.label.toLowerCase()} — you\'ll want time to soak it in.',
      ),
      _FaqItem(
        'Is the venue safe + friendly?',
        e.isSafeVenue
            ? 'Yes. This one\'s a Hatri-verified safe venue — trained staff, clear code of conduct, and someone on hand if things go sideways.'
            : 'Standard venue. Message the organiser above if you have accessibility or comfort needs.',
      ),
      _FaqItem(
        'Can I bring a friend?',
        'Absolutely. Each ticket is per person, so book one for them too. Group of 4+? Ping the organiser for group rates.',
      ),
      _FaqItem(
        'What about photos and video?',
        'Photography may happen for the Hatri wall + organiser socials. You\'ll be tagged only if you opt in on the wall.',
      ),
    ];
    if (!e.isFree) {
      baseline.addAll([
        _FaqItem(
          'What\'s the refund policy?',
          'Full refund (minus fees) up to 24 hours before the event. After that, tickets are non-refundable but transferable.',
        ),
        _FaqItem(
          'Can I upgrade my tier later?',
          'If a higher tier is still available, yes — ping the organiser. You\'ll only pay the difference.',
        ),
      ]);
    }
    return baseline;
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromHex('#FF7A00'); // matches the queries card orange
    final items = _items;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64.r,
        leading: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 16.r),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42.r,
                height: 42.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ground.withValues(alpha: 0.85),
                  border: Border.all(color: AppColors.paper.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(Corners.md),
                ),
                child: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  width: 20.r,
                  height: 20.r,
                  colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(Insets.lg, 10.r, Insets.lg, 24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 24.r, height: 4.r, color: accent),
                      SizedBox(width: 12.r),
                      Text(
                        'STILL WONDERING?',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          letterSpacing: 2.0.sp,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.r),
                  Text(
                    'FREQUENTLY\nASKED',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 42.sp,
                      height: 0.95,
                      letterSpacing: -1.0.sp,
                      color: AppColors.paper,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, MediaQuery.of(context).padding.bottom + 40.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = items[i];
                  final open = _openIndex == i;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.r),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _openIndex = open ? null : i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          border: Border.all(
                            color: open ? accent.withValues(alpha: 0.6) : AppColors.border,
                            width: open ? 1.4 : 1,
                          ),
                          borderRadius: BorderRadius.circular(Corners.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(Corners.pill),
                                  ),
                                  child: Text(
                                    'Q${(i + 1).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontFamily: 'GeneralSans',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10.sp,
                                      letterSpacing: 1.2.sp,
                                      color: accent,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.r),
                                Expanded(
                                  child: Text(
                                    item.question,
                                    style: TextStyle(
                                      fontFamily: 'ClashDisplay',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                      height: 1.2,
                                      letterSpacing: -0.2.sp,
                                      color: AppColors.paper,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.r),
                                AnimatedRotation(
                                  turns: open ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 180),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: open ? accent : AppColors.muted,
                                    size: 22.r,
                                  ),
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 180),
                              crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                              firstChild: const SizedBox(width: double.infinity),
                              secondChild: Padding(
                                padding: EdgeInsets.fromLTRB(0, 12.r, 0, 4.r),
                                child: Text(
                                  item.answer,
                                  style: TextStyle(
                                    fontFamily: 'GeneralSans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                    height: 1.5,
                                    color: AppColors.paper.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small tile for the "Good to know" quick-facts grid.
class _FactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r, height: 36.r,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Corners.sm),
            ),
            child: Icon(icon, color: accent, size: 18.r),
          ),
          SizedBox(width: 10.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 2.r),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
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
}

/// Compact trust chip — single icon + label pill. Multiple chips render as
/// a Wrap so lonely singles don't stretch full-width.
class _TrustChip extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final Color color;
  final String label;
  const _TrustChip({
    this.icon,
    this.svgPath,
    required this.color,
    required this.label,
  }) : assert(icon != null || svgPath != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 7.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svgPath != null)
            SvgPicture.asset(
              svgPath!,
              width: 13.r,
              height: 13.r,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            )
          else
            Icon(icon, color: color, size: 13.r),
          SizedBox(width: 6.r),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 10.sp,
              letterSpacing: 1.2.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-line trust bar cell — icon + label + sub, used inside the badge row.
class _TrustCell extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final Color color;
  final String label;
  final String sub;
  const _TrustCell({
    this.icon,
    this.svgPath,
    required this.color,
    required this.label,
    required this.sub,
  }) : assert(icon != null || svgPath != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.r, horizontal: 10.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (svgPath != null)
            SvgPicture.asset(
              svgPath!,
              width: 18.r,
              height: 18.r,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            )
          else
            Icon(icon, color: color, size: 18.r),
           SizedBox(width: 8.r),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                    height: 1.0,
                    letterSpacing: -0.2.sp,
                    color: AppColors.paper,
                  ),
                ),
                SizedBox(height: 2.r),
                Text(
                  sub.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 8.sp,
                    letterSpacing: 1.0.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
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


// ---------------- Share sheet ----------------

class _ShareSheet extends StatelessWidget {
  final Event event;
  final bool isRsvpd;
  const _ShareSheet({required this.event, required this.isRsvpd});

  String get _shareText {
    final date = DateFormat('EEE, MMM d').format(event.date);
    final prefix = isRsvpd ? "I'm going to " : "Check this out: ";
    // Build a universal URL. Opens the event preview on hatri.online, bounces
    // into the Hatri app on devices with the app installed (handled by F3b/c).
    final url = event.slug.isNotEmpty
        ? 'https://hatri.online/e/${event.slug}'
        : 'https://hatri.online';
    return "$prefix${event.title} 🎟️\n$date · ${event.time} · ${event.venue}\n\n$url";
  }

  Future<void> _share(BuildContext context) async {
    await Share.share(_shareText, subject: event.title);
    // Fire-and-forget backend tracking so popularity reflects reality.
    unawaited(sl<EventsService>().share(event.id).catchError((_) => 0));
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
            HatriImage(url: event.coverUrl, fit: BoxFit.cover, errorWidget: Container(color: accent),
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

// ---------------- RSVP confirmation sheet ----------------

/// Two-tap confirmation gate. Prevents accidental claims + gives the user a
/// place to bail out. Returns true when the user confirms.
class _RsvpConfirmSheet extends StatelessWidget {
  final Event event;
  const _RsvpConfirmSheet({required this.event});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.r, 20.r, 24.r, 20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40.r,
              height: 4.r,
              margin: EdgeInsets.only(bottom: 20.r),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'CLAIM YOUR SPOT',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
                letterSpacing: 1.6.sp,
                color: AppColors.fuchsia,
              ),
            ),
            SizedBox(height: 8.r),
            Text(
              event.title,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 28.sp,
                height: 1.05,
                letterSpacing: -0.6.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              '${DateFormat('EEE, MMM d').format(event.date)} · ${event.time}',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: AppColors.muted,
              ),
            ),
            if (event.venue.isNotEmpty) ...[
              SizedBox(height: 2.r),
              Text(
                event.venue,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  color: AppColors.muted,
                ),
              ),
            ],
            SizedBox(height: 20.r),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(Corners.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18.r, color: AppColors.muted),
                  SizedBox(width: 10.r),
                  Expanded(
                    child: Text(
                      'One free ticket. Cancel any time before the event.',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                        height: 1.4,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.r),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 52.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(Corners.md),
                      ),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          letterSpacing: 1.2.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      height: 52.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.fuchsia,
                        borderRadius: BorderRadius.circular(Corners.md),
                      ),
                      child: Text(
                        'CONFIRM & CLAIM',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          letterSpacing: 1.2.sp,
                          color: AppColors.paper,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
