import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../core/models/models.dart';
import '../../core/repositories/mock_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import '../../shared/widgets/community_card.dart';
import '../../shared/widgets/search_screen.dart';
import 'bloc/communities_bloc.dart';
import 'bloc/communities_state.dart';
import 'community_details_screen.dart';
import '../../core/responsive/responsive.dart';

/// Communities — meetup-first. Groups are crews that gather:
/// neighborhoods, colleges, interests, and creator hubs.
class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  CommunityType? _activeType; // null = "All"
  final PageController _featuredCtrl = PageController(viewportFraction: 0.9);
  int _featuredIndex = 0;

  @override
  void dispose() {
    _featuredCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CommunitiesBloc, CommunitiesState>(
          builder: (context, state) {
            if (state is CommunitiesLoading || state is CommunitiesInitial) {
              return const Center(child: CircularProgressIndicator(color: AppColors.fuchsia));
            }
            if (state is! CommunitiesLoaded) return const SizedBox.shrink();

            final all = state.communities;
            final filtered = _activeType == null
                ? all
                : all.where((c) => c.type == _activeType).toList();
            final joined = all.where((c) => AppCommunities.joinedIds.contains(c.id)).toList();
            final featuredList = _pickFeaturedList(all);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildTypeTabs()),
                if (joined.isNotEmpty)
                  SliverToBoxAdapter(child: _buildYourCommunities(joined)),
                if (_activeType == null && featuredList.isNotEmpty) ...[
                  SliverToBoxAdapter(child: _buildFeaturedSectionHeader()),
                  SliverToBoxAdapter(child: _buildFeaturedCarousel(featuredList)),
                ],
                SliverToBoxAdapter(child: _buildGridSectionHeader(filtered.length)),
                if (filtered.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(Insets.lg, 6.r, Insets.lg, 100.r),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.r,
                        mainAxisSpacing: 12.r,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => CommunityCard(
                          community: filtered[i],
                          nextEventLabel: _nextEventLabel(filtered[i]),
                          onTap: () => _openDetails(filtered[i]),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildHeader() {
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
                  'YOUR CREWS',
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
                  'COMMUNITIES',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 34.sp,
                    height: 0.95,
                    letterSpacing: -1.0.sp,
                    color: AppColors.paper,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'Find your people in Raipur.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
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
                  'assets/icons/Search.svg',
                  width: 20.r,
                  height: 20.r,
                  colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TYPE TABS ----------------

  Widget _buildTypeTabs() {
    return SizedBox(
      height: 36.r,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8.r),
            child: FilterChipX(
              label: 'All',
              selected: _activeType == null,
              onTap: () => setState(() => _activeType = null),
              activeColor: AppColors.fuchsia,
            ),
          ),
          for (final t in CommunityType.values)
            Padding(
              padding: EdgeInsets.only(right: 8.r),
              child: FilterChipX(
                label: t.label,
                selected: _activeType == t,
                onTap: () => setState(() => _activeType = _activeType == t ? null : t),
                activeColor: AppColors.fromHex(t.colorHex),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- YOUR COMMUNITIES ----------------

  Widget _buildYourCommunities(List<Community> joined) {
    return Padding(
      padding: EdgeInsets.only(top: 14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, 8.r),
            child: Row(
              children: [
                const StickerLabel(
                  text: 'YOURS',
                  background: AppColors.lime,
                  foreground: AppColors.onNeon,
                ),
                SizedBox(width: 8.r),
                Text(
                  '${joined.length} joined',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    letterSpacing: 0.6.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60.r,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              itemCount: joined.length,
              itemBuilder: (context, i) {
                final c = joined[i];
                final accent = AppColors.fromHex(c.type.colorHex);
                return Padding(
                  padding: EdgeInsets.only(right: 10.r),
                  child: GestureDetector(
                    onTap: () => _openDetails(c),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 44.r,
                          height: 44.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.2),
                            border: Border.all(color: accent, width: 1.4),
                            borderRadius: BorderRadius.circular(Corners.md),
                          ),
                          child: Text(c.emoji, style: TextStyle(fontSize: 20.sp)),
                        ),
                        SizedBox(width: 8.r),
                        SizedBox(
                          width: 90.r,
                          child: Text(
                            c.name.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 10.sp,
                              letterSpacing: 0.6.sp,
                              color: AppColors.paper,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FEATURED ----------------

  Widget _buildFeaturedSectionHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 22.r, Insets.lg, 10.r),
      child: Row(
        children: [
          StickerLabel(
            text: '⭐ FEATURED',
            background: AppColors.fuchsia,
            foreground: AppColors.paper,
          ),
          SizedBox(width: 8.r),
          Text(
            'Crew of the week',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              letterSpacing: -0.2.sp,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }

  List<Community> _pickFeaturedList(List<Community> all) {
    if (all.isEmpty) return const [];
    final sorted = [...all]..sort((a, b) => b.memberCount.compareTo(a.memberCount));
    return sorted.take(5).toList();
  }

  Widget _buildFeaturedCarousel(List<Community> list) {
    return Column(
      children: [
        SizedBox(
          height: 360.r,
          child: PageView.builder(
            controller: _featuredCtrl,
            itemCount: list.length,
            onPageChanged: (i) => setState(() => _featuredIndex = i),
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 4.r),
              child: _buildFeaturedCard(list[i]),
            ),
          ),
        ),
        SizedBox(height: 8.r),
        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < list.length; i++)
              AnimatedContainer(
                duration: Motion.fast,
                margin: EdgeInsets.symmetric(horizontal: 3.r),
                width: i == _featuredIndex ? 18 : 6,
                height: 6.r,
                decoration: BoxDecoration(
                  color: i == _featuredIndex ? AppColors.lime : AppColors.border,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Contrast backdrop so the sticker shadow reads against the card color.
  Color _backdropFor(CommunityType t) {
    switch (t) {
      case CommunityType.interest:      return AppColors.lime;     // fuchsia card
      case CommunityType.neighborhood:  return AppColors.fuchsia;  // indigo card
      case CommunityType.college:       return AppColors.indigo;   // orange card
      case CommunityType.creator:       return AppColors.fuchsia;  // lime card
    }
  }

  Widget _buildFeaturedCard(Community c) {
    final accent = AppColors.fromHex(c.type.colorHex);
    final onAccent = accent.computeLuminance() > 0.55 ? AppColors.onNeon : AppColors.paper;

    return StickerShadow(
        color: _backdropFor(c.type),
        offset: Offset(5.r, 5.r),
        radius: Corners.lg,
        child: GestureDetector(
          onTap: () => _openDetails(c),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Corners.lg),
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                border: Border.all(color: AppColors.onNeon, width: 1.4),
                borderRadius: BorderRadius.circular(Corners.lg),
              ),
              child: AdaptiveCardBody(
                aspectRatio: 16 / 9,
                cover: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      c.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: accent),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: HalftoneBackground(
                          dotColor: AppColors.onNeon,
                          spacing: 8.r,
                          dotSize: 1.6,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10.r,
                      left: 10.r,
                      child: CategoryTag(
                        label: c.type.label,
                        color: AppColors.onNeon,
                      ),
                    ),
                  ],
                ),
                body: Padding(
                    padding: EdgeInsets.fromLTRB(14.r, 12.r, 14.r, 14.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(c.emoji, style: TextStyle(fontSize: 22.sp)),
                            SizedBox(width: 8.r),
                            Expanded(
                              child: Text(
                                c.name.toUpperCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'ClashDisplay',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.sp,
                                  height: 0.98,
                                  letterSpacing: -0.4.sp,
                                  color: onAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.r),
                        Text(
                          c.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            color: onAccent.withValues(alpha: 0.85),
                          ),
                        ),
                        SizedBox(height: 12.r),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatCount(c.memberCount)} MEMBERS',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 11.sp,
                                letterSpacing: 1.2.sp,
                                color: onAccent,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
                              decoration: BoxDecoration(
                                color: AppColors.onNeon,
                                borderRadius: BorderRadius.circular(Corners.pill),
                              ),
                              child: Text(
                                'JOIN →',
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.8.sp,
                                  color: AppColors.paper,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ),
            ),
          ),
        ),
    );
  }

  // ---------------- GRID header + empty ----------------

  Widget _buildGridSectionHeader(int count) {
    final title = _activeType == null
        ? 'ALL CREWS'
        : '${_activeType!.label.toUpperCase()} CREWS';
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 22.r, Insets.lg, 6.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              letterSpacing: -0.2.sp,
              color: AppColors.paper,
            ),
          ),
          SizedBox(width: 8.r),
          Text(
            '· $count',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final typeLabel = _activeType?.label.toLowerCase() ?? 'community';
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 20.r, Insets.lg, 60.r),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.graphite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Column(
          children: [
            Text('🌱', style: TextStyle(fontSize: 32.sp)),
            SizedBox(height: 8.r),
            Text(
              'No $typeLabel crews yet',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              'Wanna start one? (Coming after backend)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------

  void _openDetails(Community c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommunityDetailsScreen(community: c)),
    ).then((_) => setState(() {})); // refresh joined strip on return
  }

  String? _nextEventLabel(Community c) {
    final id = c.nextEventId;
    if (id == null) return null;
    Event? event;
    for (final e in MockRepository.mockEvents) {
      if (e.id == id) {
        event = e;
        break;
      }
    }
    if (event == null) return null;
    return '${DateFormat('EEE').format(event.date)} · ${event.title.split(':').first}';
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
