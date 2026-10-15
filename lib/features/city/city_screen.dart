import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/models/makers.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/widgets/maker_card.dart';
import '../../shared/widgets/search_screen.dart';
import '../../shared/widgets/weekly_issue_card.dart';
import '../makers/presentation/pages/maker_profile_screen.dart';
import 'weekly_issue_screen.dart';

const _cityName = 'RAIPUR';
const _tagAll = 'ALL';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String _activeCategory = _tagAll;

  /// Categories that have at least one maker seeded. Empty ones don't get a
  /// filter chip — no dead ends.
  List<MakerCategory> get _liveCategories => AppMakerCategories.all
      .where((c) => AppMakers.byCategory(c).isNotEmpty)
      .toList();

  List<Maker> get _filteredMakers {
    final pool = _activeCategory == _tagAll
        ? AppMakers.all
        : AppMakers.byCategory(
            AppMakerCategories.all.firstWhere((c) => c.label == _activeCategory),
          );
    return AppMakers.prioritized(pool: pool);
  }

  void _openMaker(Maker maker) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => MakerProfileScreen(maker: maker)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(child: SizedBox(height: 12.r)),
            SliverToBoxAdapter(
              child: WeeklyIssueCard(
                issue: AppWeeklyIssue.current,
                onTap: (issue) => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => WeeklyIssueScreen(issue: issue)),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 8.r)),
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Meet your Raipur',
                eyebrow: 'YOUR $_cityName',
                accent: AppColors.lime,
              ),
            ),
            SliverToBoxAdapter(
              child: _CategoryChipRow(
                active: _activeCategory,
                categories: _liveCategories,
                onSelect: (t) {
                  HapticFeedback.selectionClick();
                  setState(() => _activeCategory = t);
                },
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(Insets.lg, 12.r, Insets.lg, 20.r),
              sliver: SliverGrid.builder(
                itemCount: _filteredMakers.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.r,
                  mainAxisSpacing: 22.r,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, i) => MakerCard(
                  maker: _filteredMakers[i],
                  isGrid: true,
                  onTap: () => _openMaker(_filteredMakers[i]),
                ),
              ),
            ),
            // Empty state safety net — dead ends can't really happen because
            // categories with zero makers are hidden from the chip row, but
            // this catches weird states (e.g., mid-refresh) gracefully.
            if (_filteredMakers.isEmpty)
              SliverToBoxAdapter(child: _EmptyFilter(tag: _activeCategory)),
            // Clearance for the floating tab bar — matches events screen.
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 16.r, Insets.lg, 8.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'CITY',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 42.sp,
              height: 1.0,
              letterSpacing: -1.2.sp,
              color: AppColors.paper,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
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
}

// ─── Category chip row ─────────────────────────────────────────────────────

class _CategoryChipRow extends StatelessWidget {
  final String active;
  final List<MakerCategory> categories;
  final void Function(String tag) onSelect;

  const _CategoryChipRow({
    required this.active,
    required this.categories,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tags = [_tagAll, ...categories.map((c) => c.label)];
    return SizedBox(
      height: 34.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
        itemCount: tags.length,
        itemBuilder: (context, i) {
          final t = tags[i];
          final selected = t == active;
          return Padding(
            padding: EdgeInsets.only(right: 6.r),
            child: GestureDetector(
              onTap: () => onSelect(t),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 6.r),
                decoration: BoxDecoration(
                  color: selected ? AppColors.lime : AppColors.surface,
                  border: Border.all(
                    color: selected ? AppColors.lime : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(Corners.pill),
                ),
                child: Text(
                  t,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 10.sp,
                    letterSpacing: 1.sp,
                    color: selected ? AppColors.onNeon : AppColors.paper,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Empty filter state ────────────────────────────────────────────────────

class _EmptyFilter extends StatelessWidget {
  final String tag;
  const _EmptyFilter({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 40.r, Insets.lg, 40.r),
      child: Column(
        children: [
          Image.asset(
            'assets/images/utility/empty.png',
            width: 180.r,
            height: 180.r,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.r),
          Text(
            'NO $tag YET.',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 26.sp,
              letterSpacing: -0.6.sp,
              color: AppColors.paper,
            ),
          ),
          SizedBox(height: 6.r),
          Text(
            'we\'re still curating this one. check back next week.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

