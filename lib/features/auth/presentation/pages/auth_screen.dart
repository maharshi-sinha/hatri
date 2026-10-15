import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../shared/widgets/blinking_dot.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/responsive/responsive.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onAuthSuccess() {
    HapticFeedback.mediumImpact();
    // In a real app, OAuth logic goes here.
    // We route to the onboarding flow to collect their details.
    context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient blurred background
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100.r + (50 * _animController.value),
                    left: -100.r,
                    child: Container(
                      width: 300.r,
                      height: 300.r,
                      decoration: BoxDecoration(
                        color: AppColors.accentPink.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50.r - (50 * _animController.value),
                    right: -50.r,
                    child: Container(
                      width: 400.r,
                      height: 400.r,
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
          // Massive blur layer to create glassmorphism glow
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(28.r, 60.r, 28.r, 40.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Branding & Tagline
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 5.r),
                      decoration: BoxDecoration(
                        color: AppColors.accentPink.withValues(alpha: 0.14),
                        border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.35)),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const BlinkingDot(color: AppColors.accentPink),
                          SizedBox(width: 7.r),
                          Text(
                            'RAIPUR',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.accentPink,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0.sp,
                            ),
                          ),
                          SizedBox(width: 15.r),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.r),
                  Text(
                    'DISCOVER',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 56.sp,
                      color: AppColors.primaryText,
                      height: 0.9,
                      letterSpacing: -0.5.sp,
                    ),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    'THE BEST',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 56.sp,
                      color: AppColors.primaryText,
                      height: 0.9,
                      letterSpacing: -0.5.sp,
                    ),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    'EVENTS',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 56.sp,
                      color: AppColors.accentPink,
                      height: 0.9,
                      letterSpacing: -0.5.sp,
                    ),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    'IN YOUR CITY.',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 56.sp,
                      color: AppColors.accentBlue,
                      height: 0.9,
                      letterSpacing: -0.5.sp,
                    ),
                  ),
                  const Spacer(),

                  // Auth Buttons
                  _buildAuthButton(
                    context, 
                    title: 'Continue with Phone', 
                    icon: Icons.phone_iphone, 
                    bgColor: Colors.white, 
                    textColor: Colors.black,
                  ),
                  SizedBox(height: 16.r),
                  _buildAuthButton(
                    context, 
                    title: 'Continue with Google', 
                    icon: null,
                    svgAsset: 'assets/icons/google.svg',
                    iconSize: 24.r,
                    bgColor: AppColors.card, 
                    textColor: Colors.white,
                  ),
                  SizedBox(height: 16.r),
                  _buildAuthButton(
                    context, 
                    title: 'Continue with Apple', 
                    icon: Icons.apple, 
                    bgColor: AppColors.card, 
                    textColor: Colors.white,
                  ),
                  SizedBox(height: 32.r),
                  
                  // Privacy & Terms Disclaimer
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0.r),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12.sp,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButton(BuildContext context, {
    required String title,
    IconData? icon,
    String? svgAsset,
    double iconSize = 24,
    required Color bgColor,
    required Color textColor,
    BoxBorder? border,
  }) {
    return InkWell(
      onTap: _onAuthSuccess,
      borderRadius: BorderRadius.circular(100.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.r, horizontal: 24.r),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100.r),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgAsset != null)
              SvgPicture.asset(svgAsset, height: iconSize, width: iconSize)
            else if (icon != null)
              Icon(icon, color: textColor, size: iconSize),
            SizedBox(width: 12.r),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
