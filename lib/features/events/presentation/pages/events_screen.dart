import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/design/components.dart';
import '../../../../shared/design/motifs.dart';
import '../../../../shared/widgets/burst_star.dart';
import '../../../../shared/widgets/kinetic_marquee.dart';
import '../../../../shared/widgets/shimmer_skeletons.dart';
import '../../../../shared/widgets/small_event_card.dart';
import '../bloc/events_bloc.dart';
import '../bloc/events_event.dart';
import '../bloc/events_state.dart';
import 'event_details_screen.dart';
import 'map_screen.dart';
import '../../../../core/responsive/responsive.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  /// Fires LoadMoreEvents when the viewport is within ~500px of the bottom.
  /// The bloc self-guards against duplicate calls (isLoadingMore / hasMore
  /// checks), so this listener can be chatty without side effects.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final remaining = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 500) {
      context.read<EventsBloc>().add(LoadMoreEvents());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverToBoxAdapter(child: _Header()),
            const SliverToBoxAdapter(child: _DiscoveryFilterBar()),
            SliverToBoxAdapter(child: SizedBox(height: 10.r)),
            const _CategoryBrowseSliver(),
            SliverToBoxAdapter(
              child: KineticMarquee(
                word: 'HAPPENING',
                separatorWidget: BurstStar(size: 28.r, color: AppColors.fuchsia),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10.r)),
            const _EventsSliverGrid(),
            const _LoadMoreTrailer(),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
    );
  }
}

/// Thin sliver that lives below the events grid. Shows a loading indicator
/// while a new page is being fetched, or quietly disappears when the feed
/// has reached its end.
class _LoadMoreTrailer extends StatelessWidget {
  const _LoadMoreTrailer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is! EventsLoaded) return const SliverToBoxAdapter();
        if (!state.hasMore && !state.isLoadingMore) {
          return const SliverToBoxAdapter();
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.r),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.fuchsia,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  /// Reads the user's resolved city off `currentUser.currentCitySlug`
  /// (populated from GPS at onboarding or on silent catch-up) and renders
  /// it as "{SLUG} SCENE". Falls back to a plain "SCENE" label when we
  /// haven't resolved yet so we don't lie to the user.
  String _sceneLabel() {
    final slug = currentUser.currentCitySlug;
    if (slug.isEmpty) return 'SCENE';
    return '${slug.toUpperCase().replaceAll('-', ' ')} SCENE';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BurstStar(size: 12.r, color: AppColors.fuchsia),
                    SizedBox(width: 6.r),
                    Text(
                      _sceneLabel(),
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                        letterSpacing: 1.6.sp,
                        color: AppColors.lime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'EVENTS',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 36.sp,
                    height: 0.95,
                    letterSpacing: -1.2.sp,
                    color: AppColors.paper,
                  ),
                ),
              ],
            ),
          ),
          _iconButton(context, 'assets/icons/map.svg', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
          }),
        ],
      ),
    );
  }

  Widget _iconButton(BuildContext context, String svgAsset, {required VoidCallback onTap}) {
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
        child: Center(
          child: SvgPicture.asset(
            svgAsset,
            width: 20.r,
            height: 20.r,
            colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _DiscoveryFilterBar extends StatelessWidget {
  const _DiscoveryFilterBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        final active = state is EventsLoaded ? state.filter : DiscoveryFilter.all;
        return SizedBox(
          height: 40.r,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            children: DiscoveryFilter.values.map((f) {
              return Padding(
                padding: EdgeInsets.only(right: 8.r),
                child: FilterChipX(
                  label: f.label,
                  selected: active == f,
                  onTap: () => context.read<EventsBloc>().add(SetDiscoveryFilter(f)),
                  activeColor: AppColors.lime,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Two-mode category browser — sliver-native so tile grid doesn't nest a
/// GridView inside a SliverToBoxAdapter (that combo over-allocates height and
/// creates a huge dead gap below the tiles).
///   - no category selected → big visual 2x3 SliverGrid of tiles
///   - category selected → compact dismissible chip in a SliverToBoxAdapter
class _CategoryBrowseSliver extends StatelessWidget {
  const _CategoryBrowseSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      buildWhen: (a, b) {
        if (a is! EventsLoaded || b is! EventsLoaded) return true;
        return a.category != b.category;
      },
      builder: (context, state) {
        if (state is! EventsLoaded) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        if (state.category != null) {
          return SliverToBoxAdapter(
            child: _SelectedCategoryChip(category: state.category!),
          );
        }
        final cats = EventCategory.values.where((c) => c != EventCategory.other).toList();
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: Insets.lg),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.r,
              mainAxisSpacing: 10.r,
              childAspectRatio: 1.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _CategoryTile(category: cats[i]),
              childCount: cats.length,
            ),
          ),
        );
      },
    );
  }
}

class _SelectedCategoryChip extends StatelessWidget {
  final EventCategory category;
  const _SelectedCategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 4.r, Insets.lg, 4.r),
      child: Row(
        children: [
          Text(
            'FILTER',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 10.sp,
              letterSpacing: 1.6.sp,
              color: AppColors.muted,
            ),
          ),
          SizedBox(width: 10.r),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<EventsBloc>().add(SetCategoryFilter(null));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
              decoration: BoxDecoration(
                color: AppColors.fromHex(category.colorHex),
                borderRadius: BorderRadius.circular(Corners.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 11.sp,
                      letterSpacing: 1.2.sp,
                      color: AppColors.onNeon,
                    ),
                  ),
                  SizedBox(width: 6.r),
                  Icon(Icons.close_rounded, size: 15.r, color: AppColors.onNeon),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<EventsBloc>().add(SetCategoryFilter(null));
            },
            child: Text(
              'BROWSE ALL',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 1.4.sp,
                color: AppColors.paper,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.paper,
                decorationThickness: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _CategoryTile extends StatelessWidget {
  final EventCategory category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.fromHex(category.colorHex);
    final onLight = bg.computeLuminance() > 0.55;
    final labelColor = onLight ? AppColors.onNeon : AppColors.paper;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<EventsBloc>().add(SetCategoryFilter(category));
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: AppColors.onNeon, width: 1.6),
          borderRadius: BorderRadius.circular(Corners.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.onNeon.withValues(alpha: 0.5),
              offset: Offset(3.r, 3.r),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Halftone dot texture patch — bottom-right zine texture
            Positioned(
              bottom: 0,
              right: 0,
              width: 110.r,
              height: 90.r,
              child: HalftoneBackground(
                dotColor: AppColors.onNeon.withValues(alpha: 0.13),
                dotSize: 2,
                spacing: 8,
              ),
            ),
            // Tilted emoji glyph, bottom-right, oversized
            Positioned(
              bottom: -12.r,
              right: -10.r,
              child: Transform.rotate(
                angle: -14 * 3.14159 / 180,
                child: Text(
                  _glyphFor(category),
                  style: TextStyle(fontSize: 62.sp, height: 1.0),
                ),
              ),
            ),
            // BurstStar accent, top-right, partially bleeding for chaos
            Positioned(
              top: -6.r,
              right: -6.r,
              child: Transform.rotate(
                angle: 18 * 3.14159 / 180,
                child: BurstStar(
                  size: 26.r,
                  color: labelColor.withValues(alpha: 0.28),
                ),
              ),
            ),
            // Small tape-style number badge, top-right (inside)
            Positioned(
              top: 10.r,
              right: 12.r,
              child: Transform.rotate(
                angle: -6 * 3.14159 / 180,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                  decoration: BoxDecoration(
                    color: AppColors.onNeon,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: Text(
                    '0${_orderFor(category)}',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 10.sp,
                      letterSpacing: 0.5.sp,
                      color: labelColor == AppColors.onNeon ? bg : AppColors.paper,
                    ),
                  ),
                ),
              ),
            ),
            // Label top-left
            Padding(
              padding: EdgeInsets.fromLTRB(14.r, 12.r, 12.r, 12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 18.r), // clearance for number badge
                  Text(
                    _shortLabel(category),
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                      height: 0.95,
                      letterSpacing: -0.6.sp,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
            ),
            // TAP → indicator, bottom-left
            Positioned(
              bottom: 10.r,
              left: 14.r,
              child: Text(
                'TAP →',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 9.sp,
                  letterSpacing: 1.4.sp,
                  color: labelColor.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _glyphFor(EventCategory c) {
    switch (c) {
      case EventCategory.fest:
        return '🎪';
      case EventCategory.openMic:
        return '🎤';
      case EventCategory.clubNight:
        return '🪩';
      case EventCategory.market:
        return '🛍️';
      case EventCategory.workshop:
        return '🎨';
      case EventCategory.meetup:
        return '☕';
      case EventCategory.other:
        return '★';
    }
  }

  int _orderFor(EventCategory c) {
    switch (c) {
      case EventCategory.fest:
        return 1;
      case EventCategory.openMic:
        return 2;
      case EventCategory.clubNight:
        return 3;
      case EventCategory.market:
        return 4;
      case EventCategory.workshop:
        return 5;
      case EventCategory.meetup:
        return 6;
      case EventCategory.other:
        return 7;
    }
  }

  String _shortLabel(EventCategory c) {
    switch (c) {
      case EventCategory.fest:
        return 'FESTS';
      case EventCategory.openMic:
        return 'OPEN\nMIC';
      case EventCategory.clubNight:
        return 'NIGHTS\nOUT';
      case EventCategory.market:
        return 'MARKETS';
      case EventCategory.workshop:
        return 'MAKERS';
      case EventCategory.meetup:
        return 'MEETUPS';
      case EventCategory.other:
        return 'OTHER';
    }
  }
}

/// Sliver-based events grid — lives inside the screen's single CustomScrollView
/// so category tiles + event cards scroll together as one surface (no nested
/// scroll region, no bottom-anchored gap).
class _EventsSliverGrid extends StatelessWidget {
  const _EventsSliverGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 8.r),
            sliver: const SliverToBoxAdapter(child: ShimmerEventGrid(count: 6)),
          );
        }
        if (state is EventsLoaded) {
          final events = state.filtered;
          if (events.isEmpty) {
            return const SliverToBoxAdapter(child: _EmptyState());
          }
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.r,
                mainAxisSpacing: 20.r,
                childAspectRatio: 0.56,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final e = events[i];
                  return SmallEventCard(
                    event: e,
                    isGrid: true,
                    onTap: () => Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => EventDetailsScreen(event: e)),
                    ),
                  );
                },
                childCount: events.length,
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 40.r, color: AppColors.muted),
            SizedBox(height: 12.r),
            Text(
              'NOTHING MATCHES YET',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                letterSpacing: -0.2.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 4.r),
            const Text(
              'Try a different filter, or post the event yourself.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

