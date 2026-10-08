import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../backend/services/auth_service.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/di/injection_container.dart';
import '../../core/models/makers.dart';
import '../../core/models/models.dart';
import '../../core/notifications/notifications_store.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/auth_prompt/login_prompt_sheet.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import '../../shared/widgets/event_card.dart';
import '../../shared/widgets/maker_rail.dart';
import '../../shared/widgets/small_event_card.dart';
import '../../shared/widgets/pull_reveal.dart';
import '../../shared/widgets/stacked_hero_carousel.dart';
import '../../shared/widgets/ticker_widget.dart';
import '../../shared/widgets/notifications_screen.dart';
import '../../shared/widgets/search_screen.dart';
import '../discovery/this_week_screen.dart';
import '../events/event_details_screen.dart';
import '../events/bloc/events_bloc.dart';
import '../events/bloc/events_state.dart';
import '../makers/maker_profile_screen.dart';
import '../../core/responsive/responsive.dart';

// Session-scoped flag: the soft login nudge fires at most once per app launch.
// Resets on hot restart / cold start, which is the intent — one gentle poke,
// not a nag loop.
bool _loginNudgeShownThisSession = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _nudgeTimer;

  @override
  void initState() {
    super.initState();
    _scheduleLoginNudge();
  }

  @override
  void dispose() {
    _nudgeTimer?.cancel();
    super.dispose();
  }

  void _scheduleLoginNudge() {
    if (_loginNudgeShownThisSession) return;
    if (sl<AuthService>().isSignedIn) return;
    _nudgeTimer = Timer(const Duration(seconds: 45), () async {
      if (!mounted) return;
      if (_loginNudgeShownThisSession) return;
      if (sl<AuthService>().isSignedIn) return;
      _loginNudgeShownThisSession = true;
      unawaited(sl<AnalyticsService>().loginNudgeShown(reason: 'home_timer'));
      final wentToSignIn = await showLoginPromptSheet(
        context,
        reason: LoginReason.generic,
      );
      unawaited(sl<AnalyticsService>().loginNudgeDismissed(
        reason: 'home_timer',
        wentToSignIn: wentToSignIn,
      ));
    });
  }

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

    final headerH = 34.r;
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: PullReveal(
                headerHeight: headerH,
                header: const TickerWidget(texts: tickerTexts),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(top: headerH),
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
                      final openNow = AppMakers.prioritized(pool: AppMakers.takingBookings());
                      // Adaptive: when tonight is empty, Open Right Now moves up
                      // and upsizes to hero to keep home from reading empty.
                      final quietNight = tonight.isEmpty;

                      // Events lead. Makers surface below — or take over the
                      // top slot only on quiet nights when tonight is empty.
                      const city = 'RAIPUR';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StackedHeroCarousel(
                            cards: AppHomeHero.cards,
                            onTap: (card) => _handleHeroTap(context, card),
                          ),
                          SizedBox(height: 8.r),
                          // Quiet-night promotion: makers upsized to the top.
                          if (quietNight)
                            MakerRail(
                              eyebrow: 'OPEN RIGHT NOW · MAKERS',
                              title: 'Off night. they\'re on.',
                              accent: AppColors.accentYellow,
                              makers: openNow,
                              isHero: true,
                              onTapMaker: (m) => _openMaker(context, m),
                            ),
                          if (!quietNight)
                            _bigRail(
                              context,
                              eyebrow: 'HAPPENING TONIGHT IN $city',
                              title: 'Tonight in Raipur',
                              accent: AppColors.lime,
                              events: tonight,
                            ),
                          _bigRail(
                            context,
                            eyebrow: 'THIS WEEKEND IN $city',
                            title: 'Weekend plans',
                            accent: AppColors.fuchsia,
                            events: weekend,
                          ),
                          _smallRail(
                            context,
                            eyebrow: 'HANDPICKED FOR YOU',
                            title: 'Handpicked',
                            accent: AppColors.indigo,
                            events: trending,
                          ),
                          // Makers rail lives BELOW events on regular nights.
                          if (!quietNight)
                            MakerRail(
                              eyebrow: 'OPEN RIGHT NOW · MAKERS',
                              title: 'Raipur folks taking bookings',
                              accent: AppColors.accentYellow,
                              makers: openNow,
                              onTapMaker: (m) => _openMaker(context, m),
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
            ),
          ],
        ),
      ),
    );
  }

  void _handleHeroTap(BuildContext context, HeroCard card) {
    switch (card.type) {
      case HeroType.weekDrop:
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const ThisWeekScreen()),
        );
        break;
      case HeroType.theList:
      case HeroType.sceneOfTheWeek:
      case HeroType.cityMoment:
        // TODO: wire dedicated screens (TheListDetail, SceneDetail).
        // For now no-op — the card animation + rotation still feels alive.
        break;
    }
  }

  void _openMaker(BuildContext context, Maker maker) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => MakerProfileScreen(maker: maker)),
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
          // Diagnostic: in debug builds only, long-pressing the HATRI logo
          // forces a native crash so we can confirm Crashlytics reporting
          // after any change to Firebase setup. Stripped out of release.
          GestureDetector(
            onLongPress: kDebugMode
                ? () => FirebaseCrashlytics.instance.crash()
                : null,
            child: Row(
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
          ),
          const Spacer(),
          _iconButton(context, 'assets/icons/Search.svg', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
          }),
          SizedBox(width: 8.r),
          AnimatedBuilder(
            animation: NotificationsStore.instance,
            builder: (context, _) => _iconButton(
              context,
              'assets/icons/Notification.svg',
              badge: NotificationsStore.instance.hasUnread,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
            ),
          ),
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
