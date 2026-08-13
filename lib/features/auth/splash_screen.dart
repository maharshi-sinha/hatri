import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/blinking_dot.dart';
import 'dart:ui';
import '../../core/responsive/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/auth');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Background Glows
            Positioned.fill(
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.2,
                    left: MediaQuery.of(context).size.width * 0.1,
                    child: Container(
                      width: 300.r,
                      height: 300.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(255, 45, 141, 0.18),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.6,
                    left: MediaQuery.of(context).size.width * 0.4,
                    child: Container(
                      width: 250.r,
                      height: 250.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(163, 255, 18, 0.1),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'HATRI',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 100.sp,
                      color: AppColors.primaryText,
                      letterSpacing: -2.0.sp,
                      height: 0.85,
                    ),
                  ),
                  SizedBox(height: 18.r),
                  Text(
                    'YOUR CITY. YOUR SCENE.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0.sp,
                    ),
                  ),
                  SizedBox(height: 44.r),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const BlinkingDot(color: AppColors.accentPink),
                      SizedBox(width: 8.r),
                      const BlinkingDot(color: AppColors.accentGreen),
                      SizedBox(width: 8.r),
                      const BlinkingDot(color: AppColors.accentBlue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
