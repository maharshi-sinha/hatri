import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import '../../shared/widgets/event_card.dart';
import '../../shared/widgets/small_event_card.dart';
import '../../shared/widgets/ticker_widget.dart';
import '../../shared/widgets/notifications_screen.dart';
import '../../shared/widgets/search_screen.dart';
import '../discovery/this_week_screen.dart';
import '../events/event_details_screen.dart';
import '../events/bloc/events_bloc.dart';
import '../events/bloc/events_state.dart';
import '../../core/responsive/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tickerTexts = [
      "🔥 THIS WEEK IN HATRI:",
      "ECLECTIKA 2026",
      "·",
      "CIRCUIT TECHNO NIGHT",
      "·",
      "OPEN MIC @ MOCHA",
      "·",
      "FARMERS MARKET",
      "·",
      "PHOTO WALK · PURANI BASTI",
      "·",
    ];

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopBar(),
            const TickerWidget(texts: tickerTexts),
            Expanded(
              child: SingleChildScrollView(
                // No bottom padding — the footer image runs flush to the nav.
                padding: EdgeInsets.zero,
                child: BlocBuilder<EventsBloc, EventsState>(
                  builder: (context, state) {
                    if (state is EventsLoading) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 120.r),
                        child: Center(child: CircularProgressIndicator(color: AppColors.fuchsia)),
                      );
                    }
                    if (state is EventsLoaded) {
                      final all = state.events;
                      final tonight = _tonight(all);
                      final weekend = all.where((e) => e.isWeekend).toList();
                      final trending = all.where((e) => e.isTrending).toList();
                      final newlyAdded = all.where((e) => e.isNewlyAdded).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _WeekDropCard(),
                          SizedBox(height: 8.r),
                          _bigRail(
                            context,
                            eyebrow: 'HAPPENING TONIGHT',
                            title: 'Tonight in Raipur',
                            accent: AppColors.lime,
                            events: tonight.isEmpty ? all.take(2).toList() : tonight,
                          ),
                          _bigRail(
                            context,
                            eyebrow: 'THIS WEEKEND',
                            title: 'Weekend plans',
                            accent: AppColors.fuchsia,
                            events: weekend,
                          ),
                          _smallRail(
                            context,
                            eyebrow: 'HOT RIGHT NOW',
                            title: 'Trending',
                            accent: AppColors.indigo,
                            events: trending,
                          ),
                          _smallRail(
                            context,
                            eyebrow: 'JUST DROPPED',
                            title: 'Newly added',
                            accent: AppColors.lime,
                            events: newlyAdded,
                          ),
                          SizedBox(height: 48.r),
                          const _FooterCityscape(),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Event> _tonight(List<Event> all) {
    final now = DateTime.now();
    return all
        .where((e) =>
            e.date.year == now.year && e.date.month == now.month && e.date.day == now.day)
        .toList();
  }

  Widget _bigRail(BuildContext context,
      {required String eyebrow,
      required String title,
      required Color accent,
      required List<Event> events}) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, eyebrow: eyebrow, accent: accent),
        SizedBox(
          height: 380.r,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            itemCount: events.length,
            itemBuilder: (context, i) => EventCard(
              event: events[i],
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => EventDetailsScreen(event: events[i]))),
            ),
          ),
        ),
        SizedBox(height: 8.r),
      ],
    );
  }

  Widget _smallRail(BuildContext context,
      {required String eyebrow,
      required String title,
      required Color accent,
      required List<Event> events}) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, eyebrow: eyebrow, accent: accent),
        SizedBox(
          height: 340.r,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            itemCount: events.length,
            itemBuilder: (context, i) => SmallEventCard(
              event: events[i],
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => EventDetailsScreen(event: events[i]))),
            ),
          ),
        ),
        SizedBox(height: 8.r),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Starburst(size: 22.r, color: AppColors.lime),
              SizedBox(width: 8.r),
              Text(
                'HATRI',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 34.sp,
                  height: 1.0,
                  letterSpacing: -1.4.sp,
                  color: AppColors.paper,
                ),
              ),
              SizedBox(width: 6.r),
              Text(
                'RAIPUR',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp,
                  letterSpacing: 1.6.sp,
                  color: AppColors.fuchsia,
                ),
              ),
            ],
          ),
          const Spacer(),
          _iconButton(context, 'assets/icons/Search.svg', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
          }),
          SizedBox(width: 8.r),
          _iconButton(context, 'assets/icons/Notification.svg', badge: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _iconButton(BuildContext context, String svgAsset,
      {required VoidCallback onTap, bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 20.r,
              height: 20.r,
              colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
            ),
            if (badge)
              Positioned(
                top: 10.r,
                right: 10.r,
                child: Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: AppColors.fuchsia,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceRaised, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The weekly "haat drop" hero — the app's heartbeat surface.
class _WeekDropCard extends StatelessWidget {
  const _WeekDropCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.sm),
      child: StickerShadow(
        color: AppColors.fuchsia,
        offset: Offset(5.r, 5.r),
        radius: Corners.lg,
        child: Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: AppColors.lime,
            borderRadius: BorderRadius.circular(Corners.lg),
            border: Border.all(color: AppColors.onNeon, width: 1.5),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.10,
                  child: HalftoneBackground(
                    dotColor: AppColors.onNeon,
                    spacing: 10.r,
                    dotSize: 2,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const StickerLabel(
                              text: 'NEW',
                              background: AppColors.fuchsia,
                              foreground: AppColors.paper,
                            ),
                            SizedBox(width: 8.r),
                            Text(
                              'THIS WEEK IN HATRI',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w700,
                                fontSize: 10.sp,
                                letterSpacing: 1.6.sp,
                                color: AppColors.onNeon,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.r),
                        Text(
                          'RAIPUR\nGATHERS',
                          style: TextStyle(
                            fontFamily: 'ClashDisplay',
                            fontWeight: FontWeight.w700,
                            fontSize: 34.sp,
                            height: 0.92,
                            letterSpacing: -1.2.sp,
                            color: AppColors.onNeon,
                          ),
                        ),
                        SizedBox(height: 8.r),
                        Text(
                          'Your weekly drop of the scene. Fests, open mics, club nights.',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            height: 1.3,
                            color: AppColors.onNeon.withValues(alpha: 0.75),
                          ),
                        ),
                        SizedBox(height: 12.r),
                        PrimaryButton(
                          label: 'See the drop',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ThisWeekScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.r),
                    child: Column(
                      children: [
                        Starburst(size: 44.r, color: AppColors.fuchsia, points: 8),
                        SizedBox(height: 8.r),
                        Starburst(size: 22.r, color: AppColors.indigo, points: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// End-of-scroll cityscape moment — big italic #HATRI wordmark over a subtle
/// city-skyline line-art background, plus a "crafted with ❤ in India" tag.
class _FooterCityscape extends StatelessWidget {
  const _FooterCityscape();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 620.r,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Illustration — full-bleed to width, anchored bottom. Bottom
          // padding lifts it clear of the nav bar. iOS uses the floating
          // glass nav (needs more clearance) while Android's material nav
          // sits flush, so the offset stays tight.
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: Platform.isIOS ? 50.r : 0),
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/city_skyline.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          // Wordmark + tagline — left, nudged just below vertical center so
          // more of the skyline art breathes above it.
          Align(
            alignment: const Alignment(-1.0, 0.05),
            child: Padding(
              padding: EdgeInsets.only(left: 20.r, right: 20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#HATRI',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      fontSize: 52.sp,
                      height: 1.0,
                      letterSpacing: -1.6.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Crafted with ',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/heart.svg',
                        width: 16.r,
                        height: 14.r,
                      ),
                      Text(
                        ' in India',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.paper,
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
}
