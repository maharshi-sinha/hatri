import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../events/presentation/pages/host_event_screen.dart';
import '../../core/responsive/responsive.dart';

class OrganizerDashboardScreen extends StatelessWidget {
  const OrganizerDashboardScreen({super.key});

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.r),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10.r,
              spreadRadius: 1.r,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 18.r),
            ),
            SizedBox(height: 12.r),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 4.r),
            // Auto-shrinks the number if the cell is too narrow (small phones).
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, List<Color> gradientColors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.r,
        margin: EdgeInsets.only(right: 12.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 12.r,
              offset: Offset(0, 4.r),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10.r,
              bottom: -10.r,
              child: Icon(icon, size: 70.r, color: Colors.white.withValues(alpha: 0.2)),
            ),
            Padding(
              padding: EdgeInsets.all(16.0.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: Colors.white, size: 28.r),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
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
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.r, bottom: 12.r, top: 24.r),
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

  Widget _buildDashboardTile(BuildContext context, {required String title, required IconData icon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.r),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
          leading: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.primaryText, size: 20.r),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          trailing: SvgPicture.asset(
                        'assets/icons/arrow-right.svg',
                        width: 20.r,
                        height: 20.r,
                        colorFilter: ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
                      ),
          onTap: () {},
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
          'ORGANIZER DASHBOARD',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2.sp,
              ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            width: 20.r,
            height: 20.r,
            colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 40.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Banner (Actionable Alert Edge Case)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107), size: 28.r),
                  SizedBox(width: 16.r),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Action Required',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'You have an unpublished event draft waiting.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryText.withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                        'assets/icons/arrow-right.svg',
                        width: 20.r,
                        height: 20.r,
                        colorFilter: ColorFilter.mode(Color(0xFFFFC107), BlendMode.srcIn),
                      ),
                ],
              ),
            ),
            SizedBox(height: 28.r),

            // High-Level Metrics
            Row(
              children: [
                _buildMetricCard(context, 'Profile Views', '14.5K', Icons.visibility, AppColors.accentPink),
                _buildMetricCard(context, 'RSVPs', '1,240', Icons.local_activity, const Color(0xFF2D7DFF)),
                _buildMetricCard(context, 'Followers', '3.2K', Icons.groups, const Color(0xFFA3FF12)),
              ],
            ),
            SizedBox(height: 32.r),

            // Quick Actions (Horizontal Grid)
            _buildSectionHeader(context, 'Quick Actions'),
            SizedBox(
              height: 130.r,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _buildQuickAction(
                    context, 
                    'Create Event', 
                    Icons.add_box, 
                    [const Color(0xFFFF2D8D), const Color(0xFFFF7A00)],
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostEventScreen())),
                  ),
                  _buildQuickAction(
                    context, 
                    'Scan Tickets', 
                    Icons.qr_code_scanner, 
                    [const Color(0xFF7B2DFF), const Color(0xFF2D7DFF)],
                    () {},
                  ),
                  _buildQuickAction(
                    context, 
                    'Broadcast', 
                    Icons.campaign, 
                    [const Color(0xFF2D7DFF), const Color(0xFFA3FF12)],
                    () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.r),

            // Deep Dives (Navigation List)
            _buildSectionHeader(context, 'Event Management'),
            _buildDashboardTile(context, title: 'My Events', icon: Icons.calendar_month),
            _buildDashboardTile(context, title: 'RSVP Lists', icon: Icons.people_alt),

            _buildSectionHeader(context, 'Insights & Performance'),
            _buildDashboardTile(context, title: 'Analytics', icon: Icons.bar_chart),

            _buildSectionHeader(context, 'Growth'),
            _buildDashboardTile(context, title: 'Marketing Tools', icon: Icons.rocket_launch),
          ],
        ),
      ),
    );
  }
}
