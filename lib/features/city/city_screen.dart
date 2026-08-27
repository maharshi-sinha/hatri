import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/widgets/event_card.dart';
import '../events/event_details_screen.dart';
import '../../shared/widgets/search_screen.dart';
import '../events/bloc/events_bloc.dart';
import '../events/bloc/events_state.dart';
import 'dart:ui';
import '../../core/responsive/responsive.dart';

class CityScreen extends StatelessWidget {
  const CityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CITY',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 42.sp,
                          color: AppColors.primaryText,
                          letterSpacing: -0.5.sp,
                          height: 1.0,
                        ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/Search.svg',
                          width: 20.r,
                          height: 20.r,
                          colorFilter: const ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) {
                  if (state is EventsLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.accentPink));
                  } else if (state is EventsLoaded) {
                    final events = state.events;
                    return ListView(
                      padding: EdgeInsets.only(bottom: 140.r),
                      children: [
                        const SectionHeader(
                          eyebrow: 'JUST DROPPED',
                          title: 'New this week',
                          accent: AppColors.accentBlue,
                        ),
                        _buildEventList(context, events),

                        SizedBox(height: 16.r),
                        const SectionHeader(
                          eyebrow: 'AROUND TOWN',
                          title: 'Seasonal highlights',
                          accent: AppColors.fuchsia,
                        ),
                        _buildEventList(context, events.reversed.toList()),

                        SizedBox(height: 16.r),
                        const SectionHeader(
                          eyebrow: 'STAPLES',
                          title: 'Featured venues',
                          accent: AppColors.accentYellow,
                        ),
                        _buildVenueList(context),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(BuildContext context, List events) {
    return SizedBox(
      height: 380.r,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.0.r),
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(
            event: events[index],
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(event: events[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVenueList(BuildContext context) {
    final venues = [
      {'name': 'Mocha Raipur', 'type': 'Cafe • Live Music', 'color': AppColors.accentPink},
      {'name': 'Magneto Mall', 'type': 'Shopping • Events', 'color': AppColors.accentBlue},
      {'name': 'Mayfair Resort', 'type': 'Luxury • Exhibitions', 'color': AppColors.accentYellow},
    ];

    return SizedBox(
      height: 190.r,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.0.r),
        scrollDirection: Axis.horizontal,
        itemCount: venues.length,
        itemBuilder: (context, index) {
          final venue = venues[index];
          final Color vColor = venue['color'] as Color;
          return Container(
            width: 280.r,
            margin: EdgeInsets.only(right: 14.0.r),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  // base fill
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                  // bottom-right soft accent blob (Gaussian blurred)
                  Positioned(
                    right: -50.r,
                    bottom: -60.r,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                      child: Container(
                        width: 180.r,
                        height: 180.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: vColor.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                  // top-left soft counter-blob for balance
                  Positioned(
                    left: -40.r,
                    top: -50.r,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        width: 120.r,
                        height: 120.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: vColor.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  ),
                  // content
                  Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
                          decoration: BoxDecoration(
                            color: vColor.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            venue['type'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: vColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.r),
                        Text(
                          (venue['name'] as String).toUpperCase(),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 26.sp,
                            color: AppColors.primaryText,
                            height: 1.1,
                            letterSpacing: 0.5.sp,
                          ),
                        ),
                      ],
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
}
