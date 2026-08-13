import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import 'dart:ui';
import 'create_post_screen.dart';
import '../../core/responsive/responsive.dart';

class CommunityDetailsScreen extends StatefulWidget {
  final Community community;

  const CommunityDetailsScreen({super.key, required this.community});

  @override
  State<CommunityDetailsScreen> createState() => _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen> {
  bool _isJoined = false;
  int _currentTab = 0; // 0 = Feed, 1 = Events

  @override
  Widget build(BuildContext context) {
    final Color commColor = AppColors.fromHex(widget.community.colorHex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  commColor.withValues(alpha: 0.35),
                  AppColors.surface,
                ],
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -30.r,
                  right: -30.r,
                  child: Container(
                    width: 180.r,
                    height: 180.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: commColor.withValues(alpha: 0.2),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTopIconBtn(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.pop(context),
                            ),
                            ElevatedButton(
                              onPressed: () => setState(() => _isJoined = !_isJoined),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isJoined ? Colors.transparent : commColor,
                                foregroundColor: _isJoined ? commColor : AppColors.primaryText,
                                padding: EdgeInsets.symmetric(horizontal: 16.r),
                                minimumSize: Size(0, 38.r),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                side: BorderSide(
                                  color: commColor,
                                  width: 2,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _isJoined ? "JOINED" : "JOIN",
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _isJoined ? commColor : AppColors.primaryText,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.r),
                        // Community Title Info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 64.r,
                              height: 64.r,
                              decoration: BoxDecoration(
                                color: commColor.withValues(alpha: 0.25),
                                border: Border.all(color: commColor.withValues(alpha: 0.4)),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(widget.community.emoji, style: TextStyle(fontSize: 32.sp)),
                            ),
                            SizedBox(width: 16.r),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.community.name.toUpperCase(),
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                          fontSize: 32.sp,
                                          color: AppColors.primaryText,
                                          height: 1.0,
                                          letterSpacing: 0.5.sp,
                                        ),
                                  ),
                                  SizedBox(height: 6.r),
                                  Text(
                                    '${widget.community.memberCount} MEMBERS',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.0.sp,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                _buildTab(title: 'FEED', index: 0, color: commColor),
                _buildTab(title: 'EVENTS', index: 1, color: commColor),
              ],
            ),
          ),

          // Tab Content (Placeholder implementation)
          Expanded(
            child: _currentTab == 0
                ? _buildFeedTab(commColor)
                : _buildEventsTab(commColor),
          ),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                );
              },
              backgroundColor: commColor,
              child: const Icon(Icons.edit, color: AppColors.primaryText),
            )
          : null,
    );
  }

  Widget _buildTopIconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Icon(icon, color: Colors.white, size: 20.r),
          ),
        ),
      ),
    );
  }

  Widget _buildTab({required String title, required int index, required Color color}) {
    final bool isActive = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.r),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? color : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0.sp,
                  color: isActive ? color : AppColors.secondaryText,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedTab(Color color) {
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        _buildPostCard('Ananya', '2h ago', 'Anyone up for a photowalk at Marine Drive this Sunday evening?', 12, color),
        SizedBox(height: 16.r),
        _buildPostCard('Rohan', '5h ago', 'Just dropped some new long exposure shots in the gallery! Check them out.', 24, color),
        SizedBox(height: 16.r),
        _buildPostCard('Sneha', '1d ago', 'The lighting during golden hour today was absolutely stunning. Perfect for portraits.', 45, color),
      ],
    );
  }

  Widget _buildPostCard(String author, String time, String content, int likes, Color color) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  author[0].toUpperCase(), 
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
              ),
              SizedBox(width: 12.r),
              Text(
                author.toUpperCase(), 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              const Spacer(),
              Text(
                time.toUpperCase(), 
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Text(
            content, 
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4, color: AppColors.primaryText),
          ),
          SizedBox(height: 20.r),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 20.r, color: AppColors.secondaryText),
              SizedBox(width: 6.r),
              Text(
                '$likes', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryText, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 24.r),
              Icon(Icons.chat_bubble_outline, size: 20.r, color: AppColors.secondaryText),
              SizedBox(width: 6.r),
              Text(
                'Reply', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryText, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab(Color color) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_outlined, size: 48.r, color: color.withValues(alpha: 0.5)),
            SizedBox(height: 16.r),
            Text(
              'No upcoming events.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
