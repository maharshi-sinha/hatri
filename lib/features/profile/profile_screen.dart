import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/models/models.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../core/tickets/tickets_store.dart';
import '../../shared/design/motifs.dart';
import '../tickets/my_tickets_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _openEditProfile() async {
    HapticFeedback.selectionClick();
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (changed == true && mounted) setState(() {});
  }

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
                    _Hero(
                      userName: userName,
                      userBio: userBio,
                      userImage: userImage,
                      userBirthday: user.birthday,
                      userGender: user.gender,
                      userEnergy: user.energy,
                      onEdit: _openEditProfile,
                    ),
                    SizedBox(height: 24.r),
                    const _StatsRow(),
                    SizedBox(height: 28.r),
                    _InterestsRow(interests: userInterests),
                    SizedBox(height: 32.r),
                    AnimatedBuilder(
                      animation: TicketsStore.instance,
                      builder: (_, _) => _MenuCard(
                        title: 'MY UPCOMING EVENTS',
                        count: '${TicketsStore.instance.upcoming.length}',
                        accent: AppColors.lime,
                        icon: Icons.event_available_rounded,
                        onTap: () => Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
                        ),
                      ),
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
                    AnimatedBuilder(
                      animation: TicketsStore.instance,
                      builder: (_, _) => _MenuCard(
                        title: 'PAST EVENTS',
                        count: '${TicketsStore.instance.past.length}',
                        accent: AppColors.muted,
                        icon: Icons.history_rounded,
                        onTap: () => Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
                        ),
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
              Navigator.of(context, rootNavigator: true).push(
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
  final String userBirthday;
  final String userGender;
  final String userEnergy;
  final VoidCallback onEdit;
  const _Hero({
    required this.userName,
    required this.userBio,
    required this.userImage,
    required this.userBirthday,
    required this.userGender,
    required this.userEnergy,
    required this.onEdit,
  });

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
                image: userImage.startsWith('http')
                    ? NetworkImage(userImage) as ImageProvider
                    : FileImage(File(userImage)),
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
        _buildIdentityRow(),
        SizedBox(height: 18.r),
        GestureDetector(
          onTap: onEdit,
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
                    fontSize: 10.sp,
                    letterSpacing: 1.4.sp,
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

  Widget _buildIdentityRow() {
    final chips = <Widget>[];
    final birthDate = DateTime.tryParse(userBirthday);

    // Age chip
    if (birthDate != null) {
      final age = _yearsSince(birthDate);
      chips.add(_metaChip(
        label: '$age',
        accent: AppColors.fuchsia,
        leadingAsset: 'assets/icons/cake.png',
      ));
    }

    // Astro sign chip
    if (birthDate != null) {
      final sign = _zodiacFor(birthDate);
      chips.add(_metaChip(
        label: sign.name.toUpperCase(),
        accent: AppColors.accentYellow,
        leadingText: sign.symbol,
      ));
    }

    // Energy chip
    if (userEnergy.isNotEmpty) {
      final emoji = switch (userEnergy.toLowerCase()) {
        'introvert' => '🌙',
        'extrovert' => '⚡',
        'ambivert' => '🌗',
        _ => '✦',
      };
      chips.add(_metaChip(
        label: userEnergy.toUpperCase(),
        accent: AppColors.lime,
        leadingText: emoji,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 14.r),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              if (i > 0) SizedBox(width: 6.r),
              chips[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _socialChip({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(height: 28.r, child: child),
    );
  }

  Widget _metaChip({
    required String label,
    required Color accent,
    String? leadingText,
    String? leadingAsset,
    Widget? leadingWidget,
  }) {
    // Fixed-size leading slot so all chips match in height.
    Widget leading = SizedBox(
      width: 18.r,
      height: 18.r,
      child: Center(
        child: leadingWidget ??
            (leadingAsset != null
                ? Image.asset(
                    leadingAsset,
                    width: 16.r,
                    height: 16.r,
                    color: accent,
                  )
                : Text(
                    leadingText ?? '',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 15.sp,
                      height: 1.0,
                      color: accent,
                    ),
                  )),
      ),
    );
    return Container(
      height: 28.r,
      padding: EdgeInsets.symmetric(horizontal: 10.r),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          SizedBox(width: 6.r),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 10.sp,
              letterSpacing: 1.2.sp,
              height: 1.0,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  int _yearsSince(DateTime d) {
    final now = DateTime.now();
    var years = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
      years--;
    }
    return years;
  }

  ({String name, String symbol}) _zodiacFor(DateTime d) {
    final m = d.month, day = d.day;
    if ((m == 3 && day >= 21) || (m == 4 && day <= 19)) return (name: 'Aries', symbol: '♈');
    if ((m == 4 && day >= 20) || (m == 5 && day <= 20)) return (name: 'Taurus', symbol: '♉');
    if ((m == 5 && day >= 21) || (m == 6 && day <= 20)) return (name: 'Gemini', symbol: '♊');
    if ((m == 6 && day >= 21) || (m == 7 && day <= 22)) return (name: 'Cancer', symbol: '♋');
    if ((m == 7 && day >= 23) || (m == 8 && day <= 22)) return (name: 'Leo', symbol: '♌');
    if ((m == 8 && day >= 23) || (m == 9 && day <= 22)) return (name: 'Virgo', symbol: '♍');
    if ((m == 9 && day >= 23) || (m == 10 && day <= 22)) return (name: 'Libra', symbol: '♎');
    if ((m == 10 && day >= 23) || (m == 11 && day <= 21)) return (name: 'Scorpio', symbol: '♏');
    if ((m == 11 && day >= 22) || (m == 12 && day <= 21)) return (name: 'Sagittarius', symbol: '♐');
    if ((m == 12 && day >= 22) || (m == 1 && day <= 19)) return (name: 'Capricorn', symbol: '♑');
    if ((m == 1 && day >= 20) || (m == 2 && day <= 18)) return (name: 'Aquarius', symbol: '♒');
    return (name: 'Pisces', symbol: '♓');
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
