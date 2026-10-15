import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/design/motifs.dart';

/// Notification permission — full lime background, wiggling bell, punchy copy.
class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
    with SingleTickerProviderStateMixin {
  bool _busy = false;
  bool _needsSettings = false;
  bool _confirmed = false;
  bool _checking = false;
  late final AnimationController _wiggle;

  @override
  void initState() {
    super.initState();
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  Future<void> _requestOrOpenSettings() async {
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);

    if (_needsSettings) {
      await openAppSettings();
      final after = await Permission.notification.status;
      if (!mounted) return;
      setState(() {
        _busy = false;
        _needsSettings = !after.isGranted;
      });
      if (after.isGranted) await _celebrateAndAdvance();
      return;
    }

    final result = await Permission.notification.request();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _needsSettings = !result.isGranted;
    });

    if (result.isGranted) await _celebrateAndAdvance();
  }

  Future<void> _celebrateAndAdvance() async {
    HapticFeedback.mediumImpact();
    _wiggle.stop();
    setState(() => _confirmed = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    context.go('/location-permission');
  }

  void _skipForNow() {
    HapticFeedback.selectionClick();
    context.go('/location-permission');
  }


  @override
  Widget build(BuildContext context) {
    const bg = AppColors.lime;
    const onBg = AppColors.onNeon;

    // While permissions are being checked, paint only the bg color so a skip
    // looks like a smooth colour hold rather than a flash of full UI.
    if (_checking) return const Scaffold(backgroundColor: bg);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Corner starbursts
            Positioned(
              top: 24.r,
              right: 24.r,
              child: Starburst(size: 42.r, color: AppColors.fuchsia, points: 8),
            ),
            Positioned(
              top: 90.r,
              right: 66.r,
              child: Starburst(size: 22.r, color: AppColors.indigo, points: 6),
            ),
            Positioned(
              bottom: 180.r,
              left: 20.r,
              child: Starburst(
                  size: 30.r,
                  color: onBg.withValues(alpha: 0.25),
                  points: 6),
            ),
            // Halftone wash
            Positioned.fill(
              child: Opacity(
                opacity: 0.10,
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
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bell block — wiggles until confirmed, then flips to
                        // a paper-white block with a checkmark and a scale bump.
                        AnimatedBuilder(
                          animation: _wiggle,
                          builder: (context, child) {
                            if (_confirmed) return child!;
                            final t =
                                Curves.easeInOut.transform(_wiggle.value);
                            final angle = math.sin(t * math.pi * 2) * 0.14;
                            return Transform.rotate(angle: angle, child: child);
                          },
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutBack,
                            scale: _confirmed ? 1.08 : 1.0,
                            child: StickerShadow(
                              color: AppColors.indigo,
                              offset: const Offset(6, 6),
                              radius: Corners.xl,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOut,
                                width: 140.r,
                                height: 140.r,
                                decoration: BoxDecoration(
                                  color: _confirmed ? AppColors.paper : AppColors.fuchsia,
                                  borderRadius: BorderRadius.circular(Corners.xl),
                                  border: Border.all(color: AppColors.onNeon, width: 1.6),
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    transitionBuilder: (child, anim) => ScaleTransition(
                                      scale: anim,
                                      child: FadeTransition(opacity: anim, child: child),
                                    ),
                                    child: _confirmed
                                        ? Icon(
                                            Icons.check_rounded,
                                            key: const ValueKey('check'),
                                            size: 78.r,
                                            color: AppColors.onNeon,
                                          )
                                        : SvgPicture.asset(
                                            'assets/icons/Notification.svg',
                                            key: const ValueKey('bell'),
                                            width: 66.r,
                                            height: 66.r,
                                            colorFilter: const ColorFilter.mode(
                                                AppColors.paper, BlendMode.srcIn),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.r),
                        Text(
                          'STAY IN\nTHE LOOP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'ClashDisplay',
                            fontWeight: FontWeight.w800,
                            fontSize: 56.sp,
                            height: 0.9,
                            letterSpacing: -1.6.sp,
                            color: onBg,
                          ),
                        ),
                        SizedBox(height: 18.r),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.r),
                          child: Text(
                            'Weekly drops, RSVP reminders, creator alerts. Never miss the moment.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                              height: 1.45,
                              color: onBg.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 20.r),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _busy ? null : _requestOrOpenSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: onBg,
                            foregroundColor: bg,
                            disabledBackgroundColor:
                                onBg.withValues(alpha: 0.5),
                            padding: EdgeInsets.symmetric(vertical: 18.r),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Corners.md),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _confirmed
                                ? 'DONE ✓'
                                : _busy
                                    ? 'REQUESTING...'
                                    : _needsSettings
                                        ? 'OPEN SETTINGS'
                                        : 'TURN ON NOTIFICATIONS',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w800,
                              fontSize: 15.sp,
                              letterSpacing: 1.0.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.r),
                      TextButton(
                        onPressed: (_busy || _confirmed) ? null : _skipForNow,
                        style: TextButton.styleFrom(
                          foregroundColor: onBg.withValues(alpha: 0.7),
                          padding: EdgeInsets.symmetric(vertical: 10.r),
                        ),
                        child: Text(
                          'maybe later',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            letterSpacing: 0.4.sp,
                            decoration: TextDecoration.underline,
                          ),
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
    );
  }
}
