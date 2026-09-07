import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../core/models/models.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../features/communities/bloc/communities_bloc.dart';
import '../../features/communities/bloc/communities_state.dart';
import '../../features/communities/community_details_screen.dart';
import '../../features/events/bloc/events_bloc.dart';
import '../../features/events/bloc/events_state.dart';
import '../../features/events/event_details_screen.dart';

/// Search across events + scenes by title, venue, organizer, category, and
/// location. Live-filters as the user types. Empty query → prompt state.
/// Query with zero matches → mascot empty state.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final q = _controller.text.trim();
      if (q == _query) return;
      setState(() => _query = q);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Event> _matchEvents(List<Event> events) {
    if (_query.isEmpty) return const [];
    final q = _query.toLowerCase();
    return events.where((e) {
      return e.title.toLowerCase().contains(q) ||
          e.venue.toLowerCase().contains(q) ||
          e.organizer.toLowerCase().contains(q) ||
          e.category.label.toLowerCase().contains(q);
    }).toList();
  }

  List<Community> _matchScenes(List<Community> scenes) {
    if (_query.isEmpty) return const [];
    final q = _query.toLowerCase();
    return scenes.where((c) {
      return c.name.toLowerCase().contains(q) ||
          (c.location?.toLowerCase().contains(q) ?? false) ||
          c.type.label.toLowerCase().contains(q) ||
          c.vibeTags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 16.r),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
            child: Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  width: 22.r,
                  height: 22.r,
                  colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.r),
              height: 50.r,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/Search.svg',
                    width: 20.r,
                    height: 20.r,
                    colorFilter: const ColorFilter.mode(AppColors.muted, BlendMode.srcIn),
                  ),
                  SizedBox(width: 10.r),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        color: AppColors.paper,
                      ),
                      cursorColor: AppColors.fuchsia,
                      decoration: InputDecoration(
                        hintText: 'Search events, scenes, venues…',
                        hintStyle: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: AppColors.muted,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _controller.clear();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.r),
                        child: Icon(Icons.close_rounded, size: 20.r, color: AppColors.muted),
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

  Widget _buildBody() {
    if (_query.isEmpty) return _buildPrompt();
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, eventsState) {
        final events = eventsState is EventsLoaded ? _matchEvents(eventsState.events) : <Event>[];
        return BlocBuilder<CommunitiesBloc, CommunitiesState>(
          builder: (context, commsState) {
            final scenes = commsState is CommunitiesLoaded ? _matchScenes(commsState.communities) : <Community>[];
            if (events.isEmpty && scenes.isEmpty) return _buildNoResults();
            return _buildResults(events, scenes);
          },
        );
      },
    );
  }

  Widget _buildPrompt() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SEARCH',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 44.sp,
              letterSpacing: -1.2.sp,
              height: 1.0,
              color: AppColors.paper.withValues(alpha: 0.08),
            ),
          ),
          SizedBox(height: 10.r),
          Text(
            'find events, scenes, venues, vibes.',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
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
            'NO HITS.',
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
              "nothing matched '$_query'. try a scene name, venue, or vibe.",
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

  Widget _buildResults(List<Event> events, List<Community> scenes) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.r, 4.r, 16.r, 32.r),
      children: [
        if (events.isNotEmpty) ...[
          _sectionHeader('EVENTS · ${events.length}'),
          SizedBox(height: 10.r),
          for (final e in events) ...[
            _EventResultTile(event: e),
            SizedBox(height: 10.r),
          ],
        ],
        if (scenes.isNotEmpty) ...[
          SizedBox(height: 8.r),
          _sectionHeader('SCENES · ${scenes.length}'),
          SizedBox(height: 10.r),
          for (final c in scenes) ...[
            _SceneResultTile(community: c),
            SizedBox(height: 10.r),
          ],
        ],
      ],
    );
  }

  Widget _sectionHeader(String label) => Row(
        children: [
          Container(width: 20.r, height: 3.r, color: AppColors.fuchsia),
          SizedBox(width: 10.r),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 11.sp,
              letterSpacing: 1.6.sp,
              color: AppColors.muted,
            ),
          ),
        ],
      );
}

class _EventResultTile extends StatelessWidget {
  final Event event;
  const _EventResultTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromHex(event.colorHex);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 56.r,
                height: 56.r,
                child: Image.network(
                  event.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: accent),
                ),
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          event.category.label.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 8.sp,
                            letterSpacing: 1.0.sp,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    event.title,
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
                    '${DateFormat('EEE, MMM d').format(event.date)} · ${event.venue}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.r),
            Icon(Icons.chevron_right_rounded, size: 22.r, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _SceneResultTile extends StatelessWidget {
  final Community community;
  const _SceneResultTile({required this.community});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromHex(community.colorHex);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => CommunityDetailsScreen(community: community)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 56.r,
                height: 56.r,
                child: Image.network(
                  community.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: accent),
                ),
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'SCENE · ${community.type.label.toUpperCase()}',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 8.sp,
                            letterSpacing: 1.0.sp,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    community.name,
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
                    community.location != null
                        ? '${community.memberCount} members · ${community.location}'
                        : '${community.memberCount} members',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.r),
            Icon(Icons.chevron_right_rounded, size: 22.r, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
