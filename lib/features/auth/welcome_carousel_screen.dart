import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/motifs.dart';

/// 3-slide welcome carousel — full-screen color blocks with big emoji hero,
/// punchy copy, playful Gen-Z microcopy. Sets the "digital haat" tone.
class WelcomeCarouselScreen extends StatefulWidget {
  const WelcomeCarouselScreen({super.key});

  @override
  State<WelcomeCarouselScreen> createState() => _WelcomeCarouselScreenState();
}

class _WelcomeCarouselScreenState extends State<WelcomeCarouselScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  static const _slides = <_WelcomeSlide>[
    _WelcomeSlide(
      emoji: '🎪',
      title: 'WHERE THE\nCITY GATHERS',
      subtitle: 'The digital haat. Discover, show up, be part of the scene.',
      bg: AppColors.fuchsia,
      motif: AppColors.lime,
    ),
    _WelcomeSlide(
      emoji: '🎟️',
      title: 'NEVER MISS\nTHE DROP',
      subtitle: 'Fests, open mics, club nights, farmers markets. Always in the loop.',
      bg: AppColors.lime,
      motif: AppColors.fuchsia,
    ),
    _WelcomeSlide(
      emoji: '🎤',
      title: 'MEET YOUR\nCITY\'S CREATORS',
      subtitle: 'Follow local artists, DJs, cafés, photographers. All in one place.',
      bg: AppColors.indigo,
      motif: AppColors.lime,
    ),
  ];

  void _next() {
    HapticFeedback.selectionClick();
    if (_page < _slides.length - 1) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/phone');
    }
  }

  void _skip() {
    HapticFeedback.selectionClick();
    context.go('/phone');
  }

  @override
  Widget build(BuildContext context) {
    final currentBg = _slides[_page].bg;

    return Scaffold(
      backgroundColor: currentBg,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        color: currentBg,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar: HATRI wordmark + Skip
              Padding(
                padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HATRI',
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 22.sp,
                        letterSpacing: -0.5.sp,
                        color: _onColor(currentBg),
                      ),
                    ),
                    Visibility(
                      visible: _page < _slides.length - 1,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: TextButton(
                        onPressed:
                            _page < _slides.length - 1 ? _skip : null,
                        style: TextButton.styleFrom(
                          foregroundColor: _onColor(currentBg),
                        ),
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                            letterSpacing: 1.4.sp,
                            color: _onColor(currentBg).withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Slides
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
                ),
              ),
              // Dots + CTA
              Padding(
                padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 20.r),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < _slides.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: EdgeInsets.symmetric(horizontal: 3.r),
                            width: i == _page ? 24.r : 6.r,
                            height: 6.r,
                            decoration: BoxDecoration(
                              color: i == _page
                                  ? _onColor(currentBg)
                                  : _onColor(currentBg).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20.r),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _onColor(currentBg),
                          foregroundColor: currentBg,
                          padding: EdgeInsets.symmetric(vertical: 18.r),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Corners.md),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _page == _slides.length - 1 ? "LET'S GO" : 'NEXT',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
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
        ),
      ),
    );
  }

  Color _onColor(Color bg) =>
      bg.computeLuminance() > 0.55 ? AppColors.onNeon : AppColors.paper;
}

class _WelcomeSlide {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bg;
  final Color motif;

  const _WelcomeSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.motif,
  });
}

class _SlideView extends StatelessWidget {
  final _WelcomeSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final onBg = slide.bg.computeLuminance() > 0.55
        ? AppColors.onNeon
        : AppColors.paper;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 24.r),
      child: Stack(
        children: [
          // Corner starbursts for pop
          Positioned(
            top: 10.r,
            right: 0,
            child: Starburst(size: 48.r, color: slide.motif, points: 8),
          ),
          Positioned(
            bottom: 20.r,
            left: 0,
            child: Starburst(size: 32.r, color: slide.motif, points: 6),
          ),
          Positioned(
            top: 100.r,
            left: 20.r,
            child: Starburst(
                size: 20.r, color: onBg.withValues(alpha: 0.35), points: 6),
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
          // Centered content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.emoji,
                  style: TextStyle(fontSize: 120.sp),
                ),
                SizedBox(height: 24.r),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 40.sp,
                    height: 0.95,
                    letterSpacing: -1.2.sp,
                    color: onBg,
                  ),
                ),
                SizedBox(height: 16.r),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                    height: 1.4,
                    color: onBg.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
