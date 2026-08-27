import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 24.r),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                          'assets/icons/arrow-left.svg',
                          width: 20.r,
                          height: 20.r,
                          colorFilter: ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.r),
                  Text(
                    'NOTIFICATIONS',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32.sp,
                      color: AppColors.primaryText,
                      letterSpacing: -0.5.sp,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        color: AppColors.accentPink.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.2)),
                      ),
                      child: Icon(Icons.notifications_off_outlined, size: 32.r, color: AppColors.accentPink),
                    ),
                    SizedBox(height: 24.r),
                    Text(
                      'ALL CAUGHT UP.',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 24.sp,
                        color: AppColors.primaryText,
                        letterSpacing: -0.5.sp,
                      ),
                    ),
                    SizedBox(height: 8.r),
                    Text(
                      'No new notifications right now.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
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
