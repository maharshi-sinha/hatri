import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../design/components.dart';
import '../design/motifs.dart';
import 'burst_star.dart';

/// A shared full-screen shell for every non-happy-path state — offline,
/// error, 404, maintenance, sold out, etc. Pass in the mascot asset and copy
/// per screen. Layout, spacing, sparkles + typography stay consistent so the
/// whole system reads as one design language.
class UtilityScreen extends StatelessWidget {
  final String assetPath;
  final String eyebrow;
  final String headlineTop;
  final String headlineBottom;
  final String subtitle;
  final String? ctaLabel;
  final Future<void> Function()? onCta;
  final Widget? footer;
  final Color eyebrowColor;

  const UtilityScreen({
    super.key,
    required this.assetPath,
    required this.eyebrow,
    required this.headlineTop,
    required this.headlineBottom,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
    this.footer,
    this.eyebrowColor = AppColors.lime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: HalftoneBackground(
                dotColor: AppColors.paper,
                spacing: 14,
                dotSize: 1.6,
              ),
            ),
          ),
          Positioned(top: 120.r, right: 32.r, child: _spark(20.sp, eyebrowColor)),
          Positioned(top: 260.r, left: 28.r, child: _spark(14.sp, AppColors.lime)),
          Positioned(bottom: 200.r, right: 60.r, child: _spark(16.sp, eyebrowColor.withValues(alpha: 0.6))),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 12.r),
                  // Eyebrow pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
                    decoration: BoxDecoration(
                      color: eyebrowColor.withValues(alpha: 0.15),
                      border: Border.all(color: eyebrowColor.withValues(alpha: 0.55), width: 1),
                      borderRadius: BorderRadius.circular(Corners.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BurstStar(size: 12.r, color: eyebrowColor),
                        SizedBox(width: 6.r),
                        Text(
                          eyebrow,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 10.sp,
                            letterSpacing: 1.6.sp,
                            color: eyebrowColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Mascot with soft accent-colored spotlight
                  SizedBox(
                    width: 260.r,
                    height: 260.r,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 220.r,
                          height: 220.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                eyebrowColor.withValues(alpha: 0.28),
                                eyebrowColor.withValues(alpha: 0.08),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                        Image.asset(
                          assetPath,
                          width: 220.r,
                          height: 220.r,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.r),
                  // Headline stack
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 58.sp,
                        height: 0.9,
                        letterSpacing: -2.2.sp,
                        color: AppColors.paper,
                      ),
                      children: [
                        TextSpan(text: '$headlineTop\n'),
                        TextSpan(text: headlineBottom),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.r),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.r),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        height: 1.5,
                        color: AppColors.paper.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (ctaLabel != null && onCta != null)
                    _UtilityCta(label: ctaLabel!, onTap: onCta!),
                  if (footer != null) ...[
                    SizedBox(height: 14.r),
                    footer!,
                  ],
                  SizedBox(height: 24.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _spark(double size, Color color) => Text(
        '✦',
        style: TextStyle(
          fontFamily: 'ClashDisplay',
          fontWeight: FontWeight.w800,
          fontSize: size,
          color: color,
        ),
      );
}

class _UtilityCta extends StatefulWidget {
  final String label;
  final Future<void> Function() onTap;
  const _UtilityCta({required this.label, required this.onTap});

  @override
  State<_UtilityCta> createState() => _UtilityCtaState();
}

class _UtilityCtaState extends State<_UtilityCta> {
  bool _busy = false;

  Future<void> _handle() async {
    if (_busy) return;
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StickerShadow(
      color: AppColors.onNeon,
      offset: Offset(4.r, 4.r),
      radius: Corners.md,
      child: GestureDetector(
        onTap: _handle,
        child: Container(
          width: double.infinity,
          height: 56.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.lime,
            border: Border.all(color: AppColors.onNeon, width: 1.6),
            borderRadius: BorderRadius.circular(Corners.md),
          ),
          child: _busy
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(
                    color: AppColors.onNeon,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                    letterSpacing: 1.4.sp,
                    color: AppColors.onNeon,
                  ),
                ),
        ),
      ),
    );
  }
}
