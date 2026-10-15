import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/models/models.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/community_card.dart';
import '../../shared/widgets/shimmer_skeletons.dart';
import '../communities/presentation/bloc/communities_bloc.dart';
import '../communities/presentation/bloc/communities_state.dart';
import '../communities/presentation/pages/community_details_screen.dart';

/// Scenes the user has joined — reads AppCommunities.joinedIds.
class MyCommunitiesScreen extends StatefulWidget {
  const MyCommunitiesScreen({super.key});

  @override
  State<MyCommunitiesScreen> createState() => _MyCommunitiesScreenState();
}

class _MyCommunitiesScreenState extends State<MyCommunitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
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
            'MY SCENES',
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

  Widget _buildBody() {
    return BlocBuilder<CommunitiesBloc, CommunitiesState>(
      builder: (context, state) {
        if (state is! CommunitiesLoaded) {
          return Padding(
            padding: EdgeInsets.fromLTRB(Insets.lg, 16.r, Insets.lg, 40.r),
            child: const ShimmerCommunityStack(count: 5),
          );
        }
        final joined = state.communities
            .where((c) => AppCommunities.joinedIds.contains(c.id))
            .toList();
        if (joined.isEmpty) return _buildEmpty();
        return _buildGrid(joined);
      },
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
            'NO SCENES YET.',
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
              "browse the scenes tab and stamp the rooms you'd show up for.",
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

  Widget _buildGrid(List<Community> comms) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(Insets.lg, 8.r, Insets.lg, 40.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.r,
        mainAxisSpacing: 20.r,
        childAspectRatio: 0.68,
      ),
      itemCount: comms.length,
      itemBuilder: (context, i) => CommunityCard(
        community: comms[i],
        onTap: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => CommunityDetailsScreen(community: comms[i])),
        ),
      ),
    );
  }
}
