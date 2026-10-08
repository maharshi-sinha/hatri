import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// Profile tab when nobody's signed in. Replaces the "AAROHI SHARMA" mock
/// that used to leak through when currentUser was empty — a privacy-ish bug
/// where someone opening the app via a deeplink saw placeholder user data.
///
/// Vibe: casual nudge, not a wall. The user already saw the app's content;
/// this just names what sign-in unlocks.
class SignedOutProfile extends StatelessWidget {
  const SignedOutProfile({super.key});

  void _goSignIn(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.push('/phone');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header pinned to the top — matches the signed-in Profile tab
            // so switching between states doesn't shift the brand frame.
            Padding(
              padding: EdgeInsets.fromLTRB(28.r, 20.r, 28.r, 0),
              child: Text(
                'PROFILE',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.w800,
                  fontSize: 42.sp,
                  height: 1.0,
                  letterSpacing: -1.2.sp,
                  color: AppColors.paper,
                ),
              ),
            ),

            // Rest of the screen centers the mascot + copy + CTA so the
            // vertical rhythm feels composed on any device size.
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(28.r, 24.r, 28.r, 24.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 240.r,
                        child: Image.asset(
                          'assets/images/stickers/chill_cat.webp',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 28.r),
                      Text(
                        "you're just vibing. 👀",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w800,
                          fontSize: 34.sp,
                          height: 1.05,
                          letterSpacing: -0.8.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SizedBox(height: 14.r),
                      Text(
                        'save spots. flex your going-list.\nget tickets that actually mean something.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp,
                          height: 1.5,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 40.r),
                      GestureDetector(
                        onTap: () => _goSignIn(context),
                        child: Container(
                          height: 56.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.fuchsia,
                            borderRadius: BorderRadius.circular(Corners.md),
                          ),
                          child: Text(
                            'SIGN IN →',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w800,
                              fontSize: 15.sp,
                              letterSpacing: 1.2.sp,
                              color: AppColors.paper,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
