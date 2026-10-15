import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../backend/services/avatar_upload_service.dart';
import '../../../../backend/services/user_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/models/models.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/design/motifs.dart';

/// Celebration — full-bleed lime, oversized type as hero, minimal ornament.
/// "You made it. No fluff."
class CelebrationScreen extends StatefulWidget {
  const CelebrationScreen({super.key});

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _persistProfile();
  }

  /// Fire-and-forget: PATCH /me + upload avatar if the user picked a photo.
  /// Silently logs errors so the celebration animation never blocks.
  /// User can retry later from the edit-profile screen if something fails.
  Future<void> _persistProfile() async {
    // 1. Persist text fields first (fast) so downstream screens see them.
    try {
      await sl<UserService>().updateProfile(
        displayName: currentUser.name.isEmpty ? null : currentUser.name,
        dob: currentUser.birthday.isEmpty ? null : currentUser.birthday,
        interests: currentUser.interests.isEmpty ? null : currentUser.interests,
        bio: currentUser.bio.isEmpty ? null : currentUser.bio,
        gender: currentUser.gender.isEmpty ? null : currentUser.gender,
        energy: currentUser.energy.isEmpty ? null : currentUser.energy,
        homeCitySlug:
            currentUser.homeCitySlug.isEmpty ? null : currentUser.homeCitySlug,
        currentCitySlug: currentUser.currentCitySlug.isEmpty
            ? null
            : currentUser.currentCitySlug,
      );
    } catch (e) {
      debugPrint('Profile PATCH failed (non-fatal): $e');
    }

    // 2. Upload avatar if one was picked. Skips the network round trip
    // when the path is empty or points to a remote URL (nothing to send).
    final path = currentUser.profileImage;
    if (path.isNotEmpty && !path.startsWith('http')) {
      try {
        final file = File(path);
        if (await file.exists()) {
          final user = await sl<AvatarUploadService>().uploadAvatar(file);
          if (user.avatarUrl != null) {
            currentUser.profileImage = user.avatarUrl!;
          }
        }
      } catch (e) {
        debugPrint('Avatar upload failed (non-fatal): $e');
      }
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _enter() {
    HapticFeedback.mediumImpact();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    const bg = AppColors.lime;
    const onBg = AppColors.onNeon;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient slow-spinning giant starburst behind the type
            Positioned(
              top: -60.r,
              right: -80.r,
              child: RotationTransition(
                turns: _spin,
                child: Starburst(
                  size: 380.r,
                  color: AppColors.fuchsia.withValues(alpha: 0.10),
                  points: 8,
                ),
              ),
            ),
            // Scattered accent starbursts (static)
            Positioned(
              top: 60.r,
              left: 24.r,
              child: Starburst(size: 22.r, color: AppColors.fuchsia, points: 6),
            ),
            Positioned(
              top: 180.r,
              right: 42.r,
              child: Starburst(size: 14.r, color: AppColors.indigo, points: 6),
            ),
            Positioned(
              bottom: 180.r,
              left: 40.r,
              child: Starburst(size: 18.r, color: AppColors.indigo, points: 8),
            ),
            Positioned(
              bottom: 260.r,
              right: 30.r,
              child: Starburst(size: 12.r, color: AppColors.fuchsia, points: 6),
            ),
            // Subtle halftone wash for texture
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: HalftoneBackground(
                  dotColor: onBg,
                  spacing: 14.r,
                  dotSize: 2.4,
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top brand anchor
                Padding(
                  padding: EdgeInsets.fromLTRB(24.r, 16.r, 24.r, 0),
                  child: Text(
                    'HATRI',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                      letterSpacing: -0.4.sp,
                      color: onBg,
                    ),
                  ),
                ),
                // The type IS the design — massive brutalist headline
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "YOU'RE\nIN THE\nHAAT.",
                            style: TextStyle(
                              fontFamily: 'ClashDisplay',
                              fontWeight: FontWeight.w800,
                              fontSize: 92.sp,
                              height: 0.9,
                              letterSpacing: -3.0.sp,
                              color: onBg,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.r),
                        Text(
                          "your city's scene starts now.\nlet's find your first plan.",
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                            height: 1.4,
                            color: onBg.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // CTA — dark bg + white text (inverts against lime for contrast pop)
                Padding(
                  padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 20.r),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _enter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.onNeon,
                        foregroundColor: AppColors.paper,
                        padding: EdgeInsets.symmetric(vertical: 18.r),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Corners.md),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'EXPLORE HATRI',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          letterSpacing: 1.0.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
