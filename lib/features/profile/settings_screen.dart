import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/responsive.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 20.r, bottom: 8.r, top: 24.r),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5.sp,
            ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required String title, IconData? icon, String? svgIcon, VoidCallback? onTap, bool isDestructive = false}) {
    final Color itemColor = isDestructive ? AppColors.accentPink : AppColors.primaryText;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 6.r),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: isDestructive ? AppColors.accentPink.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
          leading: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDestructive ? AppColors.accentPink.withValues(alpha: 0.1) : AppColors.card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDestructive ? AppColors.accentPink.withValues(alpha: 0.2) : AppColors.border,
              ),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: itemColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          trailing: isDestructive 
              ? null 
              : Icon(Icons.chevron_right, color: AppColors.secondaryText, size: 20.r),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'SETTINGS',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2.sp,
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 40.r),
        children: [
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(context, title: 'Personal Information', svgIcon: 'assets/icons/Profile.svg'),
          _buildSettingsTile(context, title: 'Payment Methods', icon: Icons.payment),
          
          _buildSectionHeader(context, 'Preferences'),
          _buildSettingsTile(context, title: 'Notifications', icon: Icons.notifications_none),
          _buildSettingsTile(context, title: 'Security', icon: Icons.security),
          _buildSettingsTile(context, title: 'App Theme', icon: Icons.dark_mode_outlined),
          
          _buildSectionHeader(context, 'Support'),
          _buildSettingsTile(context, title: 'Help Center', icon: Icons.help_outline),
          _buildSettingsTile(context, title: 'Privacy Policy', icon: Icons.privacy_tip_outlined),
          _buildSettingsTile(context, title: 'Terms of Service', icon: Icons.description_outlined),
          
          SizedBox(height: 32.r),
          _buildSettingsTile(
            context, 
            title: 'Log Out', 
            icon: Icons.logout, 
            isDestructive: true,
            onTap: () {
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}
