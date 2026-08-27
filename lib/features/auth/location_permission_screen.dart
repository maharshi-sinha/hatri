import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/motifs.dart';

/// Location permission — full indigo background, bobbing pin, punchy copy.
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  bool _busy = false;
  bool _needsSettings = false;
  bool _confirmed = false;
  bool _checking = true;
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _skipIfGranted());
  }

  Future<void> _skipIfGranted() async {
    final status = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    if (status.isGranted) {
      context.pushReplacement('/celebration');
    } else {
      setState(() => _checking = false);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  Future<void> _requestOrOpenSettings() async {
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);

    if (_needsSettings) {
      await openAppSettings();
      final after = await Permission.locationWhenInUse.status;
      if (!mounted) return;
      setState(() {
        _busy = false;
        _needsSettings = !after.isGranted;
      });
      if (after.isGranted) await _celebrateAndAdvance();
      return;
    }

    final result = await Permission.locationWhenInUse.request();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _needsSettings = !result.isGranted;
    });

    if (result.isGranted) await _celebrateAndAdvance();
  }

  Future<void> _celebrateAndAdvance() async {
    HapticFeedback.mediumImpact();
    _bob.stop();
    setState(() => _confirmed = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    context.push('/celebration');
  }

  @override
  Widget build(BuildContext context) {
    const bg = AppColors.indigo;
    const onBg = AppColors.paper;

    if (_checking) return const Scaffold(backgroundColor: bg);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Corner starbursts
            Positioned(
              top: 24.r,
              left: 24.r,
              child: Starburst(size: 42.r, color: AppColors.lime, points: 8),
            ),
            Positioned(
              top: 90.r,
              left: 66.r,
              child: Starburst(size: 22.r, color: AppColors.fuchsia, points: 6),
            ),
            Positioned(
              bottom: 200.r,
              right: 24.r,
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
                        // Pin block — bobs until confirmed, then flips to a
                        // paper-white block with a checkmark and a scale bump.
                        AnimatedBuilder(
                          animation: _bob,
                          builder: (context, child) {
                            if (_confirmed) return child!;
                            final t =
                                Curves.easeInOut.transform(_bob.value);
                            return Transform.translate(
                              offset: Offset(0, -8.0 * t),
                              child: child,
                            );
                          },
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutBack,
                            scale: _confirmed ? 1.08 : 1.0,
                            child: StickerShadow(
                              color: AppColors.fuchsia,
                              offset: const Offset(6, 6),
                              radius: Corners.xl,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOut,
                                width: 140.r,
                                height: 140.r,
                                decoration: BoxDecoration(
                                  color: _confirmed ? AppColors.paper : AppColors.lime,
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
                                            'assets/icons/Location.svg',
                                            key: const ValueKey('pin'),
                                            width: 66.r,
                                            height: 66.r,
                                            colorFilter: const ColorFilter.mode(
                                                AppColors.onNeon, BlendMode.srcIn),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.r),
                        Text(
                          "WHAT'S\nNEAR YOU",
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
                            'Events, cafés, and meetups happening right around your neighborhood.',
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
                            backgroundColor: AppColors.lime,
                            foregroundColor: AppColors.onNeon,
                            disabledBackgroundColor:
                                AppColors.lime.withValues(alpha: 0.5),
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
                                        : 'ALLOW LOCATION',
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w800,
                              fontSize: 15.sp,
                              letterSpacing: 1.0.sp,
                            ),
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
