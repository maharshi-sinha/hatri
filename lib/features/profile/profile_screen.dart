import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/models/models.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/motifs.dart';
import 'organizer_dashboard_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final userName = user.name.isNotEmpty ? user.name.toUpperCase() : 'AAROHI SHARMA';
    final userBio = user.bio.isNotEmpty ? user.bio : 'Photographer. Chai fiend.';
    final userImage = user.profileImage.isNotEmpty
        ? user.profileImage
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80';
    final userInterests = user.interests.isNotEmpty
        ? user.interests
        : ['Photography', 'Music', 'Coffee', 'Design'];

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(Insets.lg, 8.r, Insets.lg, 120.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Hero(userName: userName, userBio: userBio, userImage: userImage),
                    SizedBox(height: 24.r),
                    const _StatsRow(),
                    SizedBox(height: 28.r),
                    _InterestsRow(interests: userInterests),
                    SizedBox(height: 32.r),
                    _MenuCard(
                      title: 'MY UPCOMING EVENTS',
                      count: '3',
                      accent: AppColors.lime,
                      icon: Icons.event_available_rounded,
                      onTap: () {},
                    ),
                    _MenuCard(
                      title: 'MY COMMUNITIES',
                      count: '4',
                      accent: AppColors.fuchsia,
                      icon: Icons.people_alt_rounded,
                      onTap: () {},
                    ),
                    _MenuCard(
                      title: 'SAVED EVENTS',
                      count: '12',
                      accent: AppColors.paper,
                      svgIcon: 'assets/icons/Bookmark.svg',
                      onTap: () {},
                    ),
                    _MenuCard(
                      title: 'PAST EVENTS',
                      count: '9',
                      accent: AppColors.muted,
                      icon: Icons.history_rounded,
                      onTap: () {},
                    ),
                    SizedBox(height: 20.r),
                    _OrganizerCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrganizerDashboardScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PROFILE',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 42.sp,
              height: 0.95,
              letterSpacing: -1.4.sp,
              color: AppColors.paper,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
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
                  'assets/icons/Setting.svg',
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

// ─── Hero (avatar + name + bio + edit) ─────────────────────────────────────

class _Hero extends StatelessWidget {
  final String userName;
  final String userBio;
  final String userImage;
  const _Hero({required this.userName, required this.userBio, required this.userImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.r),
        StickerShadow(
          color: AppColors.fuchsia,
          offset: Offset(5.r, 5.r),
          radius: 100,
          child: Container(
            width: 110.r,
            height: 110.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.paper, width: 3),
              image: DecorationImage(
                image: NetworkImage(userImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 22.r),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontWeight: FontWeight.w800,
            fontSize: 32.sp,
            height: 1.0,
            letterSpacing: -0.8.sp,
            color: AppColors.paper,
          ),
        ),
        SizedBox(height: 8.r),
        Text(
          userBio,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            color: AppColors.muted,
          ),
        ),
        SizedBox(height: 18.r),
        GestureDetector(
          onTap: () => HapticFeedback.selectionClick(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 10.r),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.paper, width: 1.5),
              borderRadius: BorderRadius.circular(Corners.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/Edit.svg',
                  width: 14.r,
                  height: 14.r,
                  colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                ),
                SizedBox(width: 8.r),
                Text(
                  'EDIT PROFILE',
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
          ),
        ),
      ],
    );
  }
}

// ─── Stats row ─────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _StatTile(value: '12', label: 'EVENTS', color: AppColors.lime)),
        SizedBox(width: 10),
        Expanded(child: _StatTile(value: '4', label: 'COMMUNITIES', color: AppColors.fuchsia)),
        SizedBox(width: 10),
        Expanded(child: _StatTile(value: '3', label: 'PLANS', color: AppColors.indigo)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatTile({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 10.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 30.sp,
              height: 1.0,
              letterSpacing: -0.6.sp,
              color: color,
            ),
          ),
          SizedBox(height: 4.r),
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
      ),
    );
  }
}

// ─── Interests row ─────────────────────────────────────────────────────────

class _InterestsRow extends StatelessWidget {
  final List<String> interests;
  const _InterestsRow({required this.interests});

  @override
  Widget build(BuildContext context) {
    const rota = [AppColors.fuchsia, AppColors.lime, AppColors.indigo];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 14.r, height: 3, color: AppColors.lime),
            SizedBox(width: 8.r),
            Text(
              'MY VIBE',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 11.sp,
                letterSpacing: 1.8.sp,
                color: AppColors.lime,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.r),
        Wrap(
          spacing: 8.r,
          runSpacing: 8.r,
          children: interests.asMap().entries.map((entry) {
            final color = rota[entry.key % rota.length];
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                border: Border.all(color: color.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(Corners.pill),
              ),
              child: Text(
                entry.value.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 12.sp,
                  letterSpacing: 0.6.sp,
                  color: color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Menu cards ────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final String title;
  final String count;
  final Color accent;
  final IconData? icon;
  final String? svgIcon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.count,
    required this.accent,
    this.icon,
    this.svgIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.r),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.graphite,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(Corners.md),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(Corners.sm),
                ),
                child: Center(
                  child: svgIcon != null
                      ? SvgPicture.asset(
                          svgIcon!,
                          width: 20.r,
                          height: 20.r,
                          colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                        )
                      : Icon(icon, color: accent, size: 22.r),
                ),
              ),
              SizedBox(width: 14.r),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                    letterSpacing: 0.6.sp,
                    color: AppColors.paper,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 4.r),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(Corners.pill),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 13.sp,
                    color: accent,
                  ),
                ),
              ),
              SizedBox(width: 8.r),
              SvgPicture.asset(
                        'assets/icons/arrow-right.svg',
                        width: 20.r,
                        height: 20.r,
                        colorFilter: ColorFilter.mode(AppColors.muted, BlendMode.srcIn),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Organizer promoted card ───────────────────────────────────────────────

class _OrganizerCard extends StatelessWidget {
  final VoidCallback onTap;
  const _OrganizerCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StickerShadow(
      color: AppColors.onNeon,
      offset: Offset(5.r, 5.r),
      radius: Corners.lg,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.lime,
            border: Border.all(color: AppColors.onNeon, width: 1.5),
            borderRadius: BorderRadius.circular(Corners.lg),
          ),
          child: Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: AppColors.onNeon,
                  borderRadius: BorderRadius.circular(Corners.sm),
                ),
                child: Icon(Icons.bar_chart_rounded, color: AppColors.lime, size: 28.r),
              ),
              SizedBox(width: 16.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORGANIZER',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 11.sp,
                        letterSpacing: 1.6.sp,
                        color: AppColors.onNeon.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      'DASHBOARD',
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 20.sp,
                        height: 1.0,
                        letterSpacing: -0.6.sp,
                        color: AppColors.onNeon,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                        'assets/icons/arrow-right.svg',
                        width: 22.r,
                        height: 22.r,
                        colorFilter: ColorFilter.mode(AppColors.onNeon, BlendMode.srcIn),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
