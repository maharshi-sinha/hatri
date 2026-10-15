import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/models/models.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/tickets/tickets_store.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../events/presentation/pages/ticket_reveal_screen.dart';
import '../../domain/usecases/get_my_tickets.dart';

/// The user's ticket wallet. Segmented UPCOMING / PAST, live-reactive to
/// [TicketsStore]. Tap a card to re-open the animated ticket (skipping the
/// printer chug).
class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

enum _Tab { upcoming, past }

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final _store = TicketsStore.instance;
  _Tab _tab = _Tab.upcoming;
  bool _hydrating = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
    _hydrateFromBackend();
  }

  @override
  void dispose() {
    _store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  /// Pulls the user's tickets from the backend and replaces the local
  /// store contents. Covers the fresh-launch case where the store is
  /// empty because this session hasn't issued an RSVP yet. Also runs
  /// on every return to the screen so a ticket booked on another
  /// device shows up.
  Future<void> _hydrateFromBackend() async {
    if (_hydrating) return;
    setState(() => _hydrating = true);
    final result = await sl<GetMyTickets>().call(const NoParams());
    result.fold(
      (_) {}, // Keep whatever is already in the store on failure.
      (tickets) => _store.hydrateFromApi(tickets),
    );
    if (mounted) setState(() => _hydrating = false);
  }

  List<SavedTicket> get _visible =>
      _tab == _Tab.upcoming ? _store.upcoming : _store.past;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _visible.isNotEmpty
                  ? _buildList(_visible)
                  : (_hydrating
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.lime,
                          ),
                        )
                      : _buildEmpty()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 8.r),
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
                color: AppColors.surface,
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
          Text(
            'MY TICKETS',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 26.sp,
              height: 1.0,
              letterSpacing: -0.6.sp,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 12.r),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.pill),
        ),
        child: Row(
          children: [
            _tabButton('UPCOMING', _Tab.upcoming, _store.upcoming.length),
            _tabButton('PAST', _Tab.past, _store.past.length),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, _Tab tab, int count) {
    final active = _tab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _tab = tab);
        },
        child: Container(
          height: 40.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.lime : Colors.transparent,
            borderRadius: BorderRadius.circular(Corners.pill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 11.sp,
                  letterSpacing: 1.4.sp,
                  color: active ? AppColors.onNeon : AppColors.muted,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: 6.r),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 1.r),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.onNeon.withValues(alpha: 0.15)
                        : AppColors.paper.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Corners.pill),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 10.sp,
                      color: active ? AppColors.onNeon : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.only(bottom: 60.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 240.r,
            height: 240.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 240.r,
                  height: 240.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.lime.withValues(alpha: 0.2),
                        AppColors.lime.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/utility/empty.png',
                  width: 240.r,
                  height: 240.r,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Text(
            _tab == _Tab.upcoming ? 'NO TICKETS.' : 'NO PAST TICKETS.',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 32.sp,
              letterSpacing: -0.6.sp,
              height: 1.0,
              color: AppColors.paper,
            ),
          ),
          SizedBox(height: 8.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.r),
            child: Text(
              _tab == _Tab.upcoming
                  ? "nothing on your calendar yet. peep what's happening tonight?"
                  : "no memories here yet. tickets land here after the show wraps.",
              textAlign: TextAlign.center,
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
    );
  }

  Widget _buildList(List<SavedTicket> tickets) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.r, 4.r, 16.r, 40.r),
      itemCount: tickets.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.r),
      itemBuilder: (context, i) => _TicketRow(
        ticket: tickets[i],
        onTap: () => _open(tickets[i]),
      ),
    );
  }

  void _open(SavedTicket t) {
    HapticFeedback.selectionClick();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => TicketRevealScreen(
          event: t.event,
          tier: t.tier,
          quantity: t.quantity,
          skipAnimation: true,
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final SavedTicket ticket;
  final VoidCallback onTap;
  const _TicketRow({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromHex(ticket.event.colorHex);
    final e = ticket.event;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent color stripe on the far left
              Container(width: 4.r, color: accent),
              // Date badge
              Padding(
                padding: EdgeInsets.fromLTRB(14.r, 14.r, 12.r, 14.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('d').format(e.date),
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 28.sp,
                        height: 1.0,
                        letterSpacing: -1.0.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      DateFormat('MMM').format(e.date).toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 10.sp,
                        letterSpacing: 1.4.sp,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              // Meta column
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(Corners.pill),
                            ),
                            child: Text(
                              e.category.label.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 8.sp,
                                letterSpacing: 1.0.sp,
                                color: accent,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.r),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                            decoration: BoxDecoration(
                              color: AppColors.paper.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(Corners.pill),
                            ),
                            child: Text(
                              ticket.tier != null
                                  ? '${ticket.tier!.name} × ${ticket.quantity}'
                                  : ticket.quantity == 1
                                      ? 'FREE'
                                      : 'FREE × ${ticket.quantity}',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 8.sp,
                                letterSpacing: 1.0.sp,
                                color: AppColors.paper,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.r),
                      Text(
                        e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          height: 1.1,
                          letterSpacing: -0.2.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SizedBox(height: 2.r),
                      Text(
                        '${e.time} · ${e.venue}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 6.r),
                      Text(
                        '#${ticket.ref}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          fontSize: 9.sp,
                          letterSpacing: 0.8.sp,
                          color: AppColors.paper.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Chevron
              Padding(
                padding: EdgeInsets.only(right: 10.r),
                child: Icon(Icons.chevron_right_rounded, size: 22.r, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
