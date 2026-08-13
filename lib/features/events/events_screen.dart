import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/widgets/small_event_card.dart';
import 'bloc/events_bloc.dart';
import 'bloc/events_event.dart';
import 'bloc/events_state.dart';
import 'event_details_screen.dart';
import 'host_event_screen.dart';
import 'map_screen.dart';
import '../../core/responsive/responsive.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            const _DiscoveryFilterBar(),
            SizedBox(height: 8.r),
            const _CategoryChipsBar(),
            SizedBox(height: 14.r),
            const Expanded(child: _EventsGrid()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HostEventScreen()));
        },
        backgroundColor: AppColors.fuchsia,
        foregroundColor: AppColors.onNeon,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'POST EVENT',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6.sp,
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
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
                Text(
                  'RAIPUR SCENE',
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

class _CategoryChipsBar extends StatelessWidget {
  const _CategoryChipsBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        final active = state is EventsLoaded ? state.category : null;
        return SizedBox(
          height: 40.r,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            children: [
              _catChip(context, null, 'All', active == null),
              for (final c in EventCategory.values.where((c) => c != EventCategory.other))
                _catChip(context, c, c.label, active == c),
            ],
          ),
        );
      },
    );
  }

  Widget _catChip(BuildContext context, EventCategory? cat, String label, bool selected) {
    return Padding(
      padding: EdgeInsets.only(right: 8.r),
      child: FilterChipX(
        label: label,
        selected: selected,
        onTap: () => context.read<EventsBloc>().add(SetCategoryFilter(selected ? null : cat)),
        activeColor: cat == null ? AppColors.fuchsia : AppColors.fromHex(cat.colorHex),
      ),
    );
  }
}

class _EventsGrid extends StatelessWidget {
  const _EventsGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.fuchsia));
        }
        if (state is EventsLoaded) {
          final events = state.filtered;
          if (events.isEmpty) return const _EmptyState();
          return GridView.builder(
            padding: EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, 100.r),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.r,
              mainAxisSpacing: 12.r,
              childAspectRatio: 0.72,
            ),
            itemCount: events.length,
            itemBuilder: (context, i) {
              final e = events[i];
              return SmallEventCard(
                event: e,
                isGrid: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventDetailsScreen(event: e)),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
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
              'Try a different filter — or post the event yourself.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

