import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../core/di/injection_container.dart';
import '../../core/models/models.dart';
import '../../core/repositories/creator_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import '../../shared/widgets/shimmer_skeletons.dart';
import '../../shared/widgets/small_event_card.dart';
import '../creators/creator_profile_screen.dart';
import '../events/bloc/events_bloc.dart';
import '../events/bloc/events_state.dart';
import '../events/event_details_screen.dart';
import '../events/host_event_screen.dart';
import '../../core/responsive/responsive.dart';

/// This Week in Hatri — the weekly haat drop, editorial digest style.
/// Trains a weekly habit that matches the app's cultural namesake.
class ThisWeekScreen extends StatefulWidget {
  const ThisWeekScreen({super.key});

  @override
  State<ThisWeekScreen> createState() => _ThisWeekScreenState();
}

class _ThisWeekScreenState extends State<ThisWeekScreen> {
  List<CreatorProfile> _notableCreators = [];

  DateTime get _monday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  DateTime get _sunday => _monday.add(const Duration(days: 6));

  bool _inThisWeek(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return !day.isBefore(_monday) &&
        !day.isAfter(_sunday.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)));
  }

  Future<void> _loadNotableCreators(List<Event> weekEvents) async {
    final ids = <String>{};
    for (final e in weekEvents) {
      if (e.organizerId != null) ids.add(e.organizerId!);
      ids.addAll(e.lineup);
    }
    if (ids.isEmpty) {
      if (mounted) setState(() => _notableCreators = []);
      return;
    }
    final repo = sl<CreatorRepository>();
    final loaded = await Future.wait(ids.map(repo.getById));
    if (!mounted) return;
    setState(() {
      _notableCreators = loaded.whereType<CreatorProfile>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<EventsBloc, EventsState>(
          builder: (context, state) {
            if (state is EventsLoading || state is EventsInitial) {
              return Padding(
                padding: EdgeInsets.fromLTRB(Insets.lg, 24.r, Insets.lg, 40.r),
                child: const ShimmerEventStack(count: 4),
              );
            }
            if (state is! EventsLoaded) {
              return const SizedBox.shrink();
            }
            final weekEvents = state.events.where((e) => _inThisWeek(e.date)).toList()
              ..sort((a, b) => a.date.compareTo(b.date));

            // Kick off async load once per state.
            if (_notableCreators.isEmpty && weekEvents.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadNotableCreators(weekEvents);
              });
            }

            if (weekEvents.isEmpty) return _buildEmptyWeek(context);
            return _buildDigest(context, weekEvents);
          },
        ),
      ),
    );
  }

  // ---------------- Empty week ----------------

  Widget _buildEmptyWeek(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.xxxl),
      children: [
        _buildMasthead(0),
        SizedBox(height: 48.r),
        Container(
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            color: AppColors.graphite,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(Corners.lg),
          ),
          child: Column(
            children: [
              Text('🌙', style: TextStyle(fontSize: 48.sp)),
              SizedBox(height: 16.r),
              Text(
                'QUIET WEEK IN RAIPUR',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                  letterSpacing: -0.3.sp,
                  color: AppColors.paper,
                ),
              ),
              SizedBox(height: 8.r),
              Text(
                "Nothing's dropped yet. Wanna change that?",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 13.sp),
              ),
              SizedBox(height: 20.r),
              PrimaryButton(
                label: 'Post an event',
                icon: Icons.add_rounded,
                expand: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HostEventScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- Full digest ----------------

  Widget _buildDigest(BuildContext context, List<Event> weekEvents) {
    final pick = _pickOfTheWeek(weekEvents);
    final venueCount = weekEvents.map((e) => e.venue).toSet().length;
    final creatorCount = <String>{
      for (final e in weekEvents) ...[
        if (e.organizerId != null) e.organizerId!,
        ...e.lineup,
      ]
    }.length;

    return ListView(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.xxxl),
      children: [
        _buildMasthead(weekEvents.length),
        SizedBox(height: 20.r),
        _buildStatsBanner(weekEvents.length, venueCount, creatorCount),
        SizedBox(height: 28.r),
        _sectionEyebrow('CURATOR·S'),
        SizedBox(height: 4.r),
        _sectionTitle('PICK OF THE WEEK 🌟'),
        SizedBox(height: 14.r),
        _buildPickCard(pick),
        SizedBox(height: 32.r),
        _sectionEyebrow('DAY BY DAY'),
        SizedBox(height: 4.r),
        _sectionTitle('THE FULL DROP'),
        SizedBox(height: 14.r),
        ..._buildDayBreakdown(weekEvents, pick),
        if (_notableCreators.isNotEmpty) ...[
          SizedBox(height: 32.r),
          _sectionEyebrow('BEHIND THE DROP'),
          SizedBox(height: 4.r),
          _sectionTitle('CREATORS THIS WEEK 🎤'),
          SizedBox(height: 14.r),
          _buildCreatorsRail(_notableCreators),
        ],
        SizedBox(height: 40.r),
        _buildFooter(),
      ],
    );
  }

  // ---------------- Masthead ----------------

  Widget _buildMasthead(int count) {
    final rangeLabel =
        '${DateFormat('MMM d').format(_monday).toUpperCase()} – ${DateFormat('MMM d').format(_sunday).toUpperCase()}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _backChip(onTap: () => Navigator.pop(context)),
            const Spacer(),
            Starburst(size: 28.r, color: AppColors.fuchsia, points: 8),
            SizedBox(width: 6.r),
            Starburst(size: 18.r, color: AppColors.lime, points: 6),
          ],
        ),
        SizedBox(height: 18.r),
        Row(
          children: [
            const StickerLabel(
              text: 'HAAT DROP',
              background: AppColors.lime,
              foreground: AppColors.onNeon,
            ),
            SizedBox(width: 8.r),
            Text(
              'RAIPUR GATHERS',
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
        SizedBox(height: 10.r),
        Text(
          'THIS WEEK\nIN HATRI',
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontWeight: FontWeight.w700,
            fontSize: 44.sp,
            height: 0.9,
            letterSpacing: -1.4.sp,
            color: AppColors.paper,
          ),
        ),
        SizedBox(height: 10.r),
        Text(
          '$rangeLabel · $count EVENTS',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
            letterSpacing: 1.4.sp,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _backChip({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          width: 20.r,
          height: 20.r,
          colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _iconChip(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Icon(icon, color: AppColors.paper, size: 20.r),
      ),
    );
  }

  // ---------------- Stats banner ----------------

  Widget _buildStatsBanner(int events, int venues, int creators) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 14.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        children: [
          Expanded(child: _statCell(events.toString(), 'EVENTS')),
          Container(width: 1, height: 34.r, color: AppColors.border),
          Expanded(child: _statCell(venues.toString(), 'VENUES')),
          Container(width: 1, height: 34.r, color: AppColors.border),
          Expanded(child: _statCell(creators.toString(), 'CREATORS')),
        ],
      ),
    );
  }

  Widget _statCell(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontWeight: FontWeight.w700,
            fontSize: 24.sp,
            letterSpacing: -0.4.sp,
            color: AppColors.paper,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w700,
            fontSize: 10.sp,
            letterSpacing: 1.4.sp,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  // ---------------- Pick of the week ----------------

  Event _pickOfTheWeek(List<Event> events) {
    final hotFirst = [...events]..sort((a, b) {
      final aScore = (a.isHot ? 100 : 0) + (a.isTrending ? 50 : 0) + a.rsvpCount;
      final bScore = (b.isHot ? 100 : 0) + (b.isTrending ? 50 : 0) + b.rsvpCount;
      return bScore.compareTo(aScore);
    });
    return hotFirst.first;
  }

  Widget _buildPickCard(Event event) {
    final accent = AppColors.fromHex(event.colorHex);
    final onAccent = accent.computeLuminance() > 0.55 ? AppColors.onNeon : AppColors.paper;

    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
      ),
      child: StickerShadow(
        color: AppColors.fuchsia,
        offset: Offset(6.r, 6.r),
        radius: Corners.lg,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Corners.lg),
          child: Container(
            decoration: BoxDecoration(
              color: accent,
              border: Border.all(color: AppColors.onNeon, width: 1.4),
              borderRadius: BorderRadius.circular(Corners.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
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
                          opacity: 0.20,
                          child: HalftoneBackground(
                            dotColor: AppColors.onNeon,
                            spacing: 8.r,
                            dotSize: 1.6,
                          ),
                        ),
                      ),
                      // Pick badge
                      Positioned(
                        top: 12.r,
                        left: 12.r,
                        child: StickerLabel(
                          text: '🌟 PICK OF THE WEEK',
                          background: AppColors.lime,
                          foreground: AppColors.onNeon,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryTag(
                        label: event.category.label,
                        color: AppColors.onNeon,
                      ),
                      SizedBox(height: 10.r),
                      Text(
                        event.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                          height: 0.98,
                          letterSpacing: -0.4.sp,
                          color: onAccent,
                        ),
                      ),
                      SizedBox(height: 8.r),
                      Text(
                        '${DateFormat('EEE, MMM d').format(event.date).toUpperCase()} · ${event.time} · ${event.venue}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                          letterSpacing: 0.6.sp,
                          color: onAccent.withValues(alpha: 0.85),
                        ),
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
  }

  // ---------------- Day-by-day breakdown ----------------

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dayAccents = [
    AppColors.fuchsia,
    AppColors.lime,
    AppColors.indigo,
    AppColors.accentOrange,
    AppColors.fuchsia,
    AppColors.lime,
    AppColors.indigo,
  ];

  List<Widget> _buildDayBreakdown(List<Event> events, Event pick) {
    final byDay = <int, List<Event>>{};
    for (final e in events) {
      byDay.putIfAbsent(e.date.weekday, () => []).add(e);
    }
    final widgets = <Widget>[];
    for (int i = 1; i <= 7; i++) {
      final day = _monday.add(Duration(days: i - 1));
      final dayEvents = (byDay[i] ?? const <Event>[])
          .where((e) => e.id != pick.id)
          .toList();
      widgets.add(_dayBlock(day, i, dayEvents));
      if (i < 7) widgets.add(SizedBox(height: 16.r));
    }
    return widgets;
  }

  Widget _dayBlock(DateTime day, int weekday, List<Event> dayEvents) {
    final accent = _dayAccents[(weekday - 1) % _dayAccents.length];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(Corners.md),
              ),
              child: Text(
                _dayLetters[weekday - 1],
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  color: accent.computeLuminance() > 0.55 ? AppColors.onNeon : AppColors.paper,
                ),
              ),
            ),
            SizedBox(width: 10.r),
            Text(
              '${DateFormat('EEEE').format(day).toUpperCase()} · ${DateFormat('MMM d').format(day).toUpperCase()}',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
                letterSpacing: 1.2.sp,
                color: AppColors.paper,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.r),
        if (dayEvents.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 14.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(Corners.md),
            ),
            child: Text(
              'empty vibes today 🌙',
              style: TextStyle(color: AppColors.muted, fontSize: 13.sp),
            ),
          )
        else
          ...dayEvents.map((e) => Padding(
                padding: EdgeInsets.only(bottom: 10.r),
                child: SmallEventCard(
                  event: e,
                  isGrid: true,
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => EventDetailsScreen(event: e)),
                  ),
                ),
              )),
      ],
    );
  }

  // ---------------- Notable creators rail ----------------

  Widget _buildCreatorsRail(List<CreatorProfile> creators) {
    return SizedBox(
      height: 100.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: creators.length,
        separatorBuilder: (_, i) => SizedBox(width: 12.r),
        itemBuilder: (context, i) {
          final c = creators[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreatorProfileScreen(creator: c)),
            ),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 74.r,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: AppColors.surfaceRaised,
                        backgroundImage: NetworkImage(c.avatarUrl),
                      ),
                      if (c.isVerified)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: VerifiedBadge(size: 14.r),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.r),
                  Text(
                    c.name,
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
            ),
          );
        },
      ),
    );
  }

  // ---------------- Footer ----------------

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 22.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'NEXT DROP',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 10.sp,
                  letterSpacing: 1.6.sp,
                  color: AppColors.fuchsia,
                ),
              ),
              SizedBox(width: 6.r),
              Text('📣', style: TextStyle(fontSize: 12.sp)),
            ],
          ),
          SizedBox(height: 6.r),
          Text(
            'SEE YOU NEXT\nTHURSDAY.',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w700,
              fontSize: 26.sp,
              height: 0.95,
              letterSpacing: -0.5.sp,
              color: AppColors.paper,
            ),
          ),
          SizedBox(height: 12.r),
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
                'RAIPUR · CG',
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
    );
  }

  // ---------------- Section utils ----------------

  Widget _sectionEyebrow(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'GeneralSans',
        fontWeight: FontWeight.w800,
        fontSize: 10.sp,
        letterSpacing: 1.8.sp,
        color: AppColors.fuchsia,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.w700,
        fontSize: 26.sp,
        letterSpacing: -0.4.sp,
        height: 1.0,
        color: AppColors.paper,
      ),
    );
  }
}
