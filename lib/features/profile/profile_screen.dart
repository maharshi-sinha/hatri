import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import 'settings_screen.dart';
import 'organizer_dashboard_screen.dart';
import 'dart:ui';
import '../../core/responsive/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final userName = user.name.isNotEmpty ? user.name.toUpperCase() : 'AAROHI SHARMA';
    final userBio = user.bio.isNotEmpty ? user.bio.toUpperCase() : 'RAIPUR, CG';
    final userImage = user.profileImage.isNotEmpty ? user.profileImage : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80';
    final userInterests = user.interests.isNotEmpty ? user.interests : ['Photography', 'Music', 'Coffee'];

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
                    'PROFILE',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 42.sp,
                          color: AppColors.primaryText,
                          letterSpacing: -0.5.sp,
                          height: 1.0,
                        ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
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
                          'assets/icons/Setting.svg',
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
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.r, 24.r, 20.r, 100.r),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120.r,
                          height: 120.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentPink.withValues(alpha: 0.15),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        Container(
                          width: 100.r,
                          height: 100.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accentPink, width: 2),
                            image: DecorationImage(
                              image: NetworkImage(userImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.r),
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 32.sp,
                            color: AppColors.primaryText,
                            letterSpacing: -0.5.sp,
                          ),
                    ),
                    SizedBox(height: 6.r),
                    Text(
                      userBio,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                            letterSpacing: 2.0.sp,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 32.r),
                    
                    // Interests
                    Wrap(
                      spacing: 8.r,
                      runSpacing: 8.r,
                      alignment: WrapAlignment.center,
                      children: userInterests.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final String interest = entry.value;
                        final Color color = index % 3 == 0 
                            ? AppColors.accentPink 
                            : (index % 3 == 1 ? AppColors.accentGreen : AppColors.accentBlue);
                        return _buildInterestChip(context, interest, color);
                      }).toList(),
                    ),
                    
                    SizedBox(height: 48.r),
                    
                    // Sections
                    _buildProfileMenuItem(context, Icons.event_available, 'MY UPCOMING EVENTS', null),
                    _buildProfileMenuItem(context, Icons.people, 'MY COMMUNITIES', null),
                    _buildProfileMenuItem(context, null, 'SAVED EVENTS', null, svgIcon: 'assets/icons/Bookmark.svg'),
                    _buildProfileMenuItem(context, Icons.history, 'PAST EVENTS', null),
                    
                    SizedBox(height: 24.r),
                    _buildProfileMenuItem(
                      context, 
                      Icons.bar_chart, 
                      'ORGANIZER DASHBOARD', 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizerDashboardScreen())),
                      isSpecial: true,
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

  Widget _buildInterestChip(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0.sp,
            ),
      ),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, IconData? icon, String title, VoidCallback? onTap, {bool isSpecial = false, String? svgIcon}) {
    final Color itemColor = isSpecial ? AppColors.accentGreen : AppColors.primaryText;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12.r),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: isSpecial ? AppColors.accentGreen.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isSpecial ? AppColors.accentGreen.withValues(alpha: 0.1) : AppColors.card,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: isSpecial ? AppColors.accentGreen.withValues(alpha: 0.2) : AppColors.border),
          ),
          child: svgIcon != null
              ? SvgPicture.asset(
                  svgIcon,
                  width: 20.r,
                  height: 20.r,
                  colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                )
              : Icon(icon, color: itemColor, size: 20.r),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: itemColor,
                fontWeight: isSpecial ? FontWeight.bold : FontWeight.w600,
              ),
        ),
        trailing: Icon(Icons.chevron_right, color: isSpecial ? AppColors.accentGreen : AppColors.secondaryText),
        onTap: onTap ?? () {},
      ),
      ),
    );
  }
}
