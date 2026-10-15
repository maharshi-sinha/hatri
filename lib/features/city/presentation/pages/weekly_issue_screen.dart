import 'package:flutter/material.dart';
import '../../../../shared/widgets/hatri_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/models/makers.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/design/motifs.dart';
import '../../../makers/presentation/pages/maker_profile_screen.dart';

/// The Weekly Issue as a magazine. PageView with distinct spreads that flip
/// left/right. Not a scroll. Each page has its own layout: cover → editor's
/// letter → 3 feature spreads → meet-the-makers grid → back cover.
class WeeklyIssueScreen extends StatefulWidget {
  final WeeklyIssue issue;
  const WeeklyIssueScreen({super.key, required this.issue});

  @override
  State<WeeklyIssueScreen> createState() => _WeeklyIssueScreenState();
}

class _WeeklyIssueScreenState extends State<WeeklyIssueScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _openMaker(Maker m) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => MakerProfileScreen(maker: m)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final makers = issue.makerIds
        .map((id) => AppMakers.all.firstWhere((m) => m.id == id))
        .toList();

    // Only 1-2 makers get the full spotlight treatment per issue. Rest fold
    // into the meet-the-rest grid. Rotates weekly (deterministic by week
    // number) so nobody hogs the cover.
    final spotlightCount = makers.length >= 6 ? 2 : 1;
    final spotlightStart = issue.weekNumber % makers.length;
    final spotlights = <Maker>[
      for (int i = 0; i < spotlightCount; i++) makers[(spotlightStart + i) % makers.length],
    ];

    // Stats for the "by the numbers" spread — Spotify-wrapped moment.
    final categories = makers.map((m) => m.primaryTag).toSet();
    final neighborhoods = makers.map((m) => m.neighborhood).toSet();
    final avgRating = makers.isEmpty
        ? 0.0
        : makers.map((m) => m.rating).reduce((a, b) => a + b) / makers.length;
    final totalReviews = makers.fold<int>(0, (a, m) => a + m.reviewCount);

    // 10-spread magazine order. TOC after cover · Group Chat between
    // features · Oscars right before back cover.
    final feature1Idx = 4;
    final chatIdx = feature1Idx + 1;          // 5
    final feature2Idx = chatIdx + 1;          // 6
    final lineupIdx = feature2Idx + 1;        // 7
    final oscarsIdx = lineupIdx + 1;          // 8
    final backCoverIdx = oscarsIdx + 1;       // 9

    final pages = <Widget>[
      _CoverSpread(
        issue: issue,
        makers: makers,
        spotlightCount: spotlightCount,
        pageActive: _page == 0,
      ),
      _TableOfContentsSpread(
        issue: issue,
        spotlights: spotlights,
        pageActive: _page == 1,
      ),
      _EditorSpread(issue: issue, pageActive: _page == 2),
      _StatsSpread(
        makerCount: makers.length,
        categoryCount: categories.length,
        neighborhoodCount: neighborhoods.length,
        avgRating: avgRating,
        totalReviews: totalReviews,
        pageActive: _page == 3,
      ),
      // Feature 1
      if (spotlights.isNotEmpty)
        _FeatureSpread(
          maker: spotlights[0],
          accent: issue.accent,
          featureNumber: 1,
          totalFeatures: spotlights.length,
          pageActive: _page == feature1Idx,
          onTap: () => _openMaker(spotlights[0]),
        ),
      _GroupChatSpread(
        messages: AppWeeklyIssue.groupChat,
        pageActive: _page == chatIdx,
      ),
      // Feature 2 (if 2 spotlights)
      if (spotlights.length > 1)
        _FeatureSpread(
          maker: spotlights[1],
          accent: issue.accent,
          featureNumber: 2,
          totalFeatures: spotlights.length,
          pageActive: _page == feature2Idx,
          onTap: () => _openMaker(spotlights[1]),
        ),
      _LineupSpread(
        makers: makers,
        onTap: _openMaker,
        pageActive: _page == lineupIdx,
      ),
      _OscarsSpread(
        awards: AppWeeklyIssue.oscars,
        pageActive: _page == oscarsIdx,
      ),
      _BackCoverSpread(
        issue: issue,
        nextWeek: issue.weekNumber + 1,
        pageActive: _page == backCoverIdx,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pc,
              onPageChanged: (p) {
                HapticFeedback.selectionClick();
                setState(() => _page = p);
              },
              children: pages,
            ),
            // Chrome overlay — close + page counter.
            Positioned(
              top: 12.r,
              left: 12.r,
              child: _RoundIconButton(
                icon: 'assets/icons/arrow-left.svg',
                onTap: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 24.r,
              right: 16.r,
              child: _PageCounter(current: _page + 1, total: pages.length),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Entrance animation ──────────────────────────────────────────────────

/// Slides + fades a child in when [active] becomes true. Restarts on re-entry.
/// Compose per-spread by wrapping stagger blocks.
class _Enter extends StatelessWidget {
  final bool active;
  final Duration delay;
  final Offset from;
  final Widget child;

  const _Enter({
    required this.active,
    required this.child,
    this.delay = Duration.zero,
    this.from = const Offset(0, 0.06),
  });

  @override
  Widget build(BuildContext context) {
    if (!active) return Opacity(opacity: 0, child: child);
    return TweenAnimationBuilder<double>(
      key: ValueKey(active),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
      builder: (_, t, c) {
        final eased = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(from.dx * (1 - eased) * 60, from.dy * (1 - eased) * 60),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

// ─── Chrome ────────────────────────────────────────────────────────────────

class _RoundIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            width: 18.r,
            height: 18.r,
            colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
            errorBuilder: (_, _, _) => Icon(Icons.close, size: 18.r, color: AppColors.paper),
          ),
        ),
      ),
    );
  }
}

class _PageCounter extends StatelessWidget {
  final int current;
  final int total;
  const _PageCounter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Text(
        '${current.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w800,
          fontSize: 11.sp,
          letterSpacing: 1.4.sp,
          color: AppColors.paper,
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  final Color accent;
  const _Eyebrow({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14.r, height: 3, color: accent),
        SizedBox(width: 8.r),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w800,
            fontSize: 11.sp,
            letterSpacing: 1.8.sp,
            color: accent,
          ),
        ),
      ],
    );
  }
}

// ─── Spread 1 · Cover ──────────────────────────────────────────────────────

class _CoverSpread extends StatelessWidget {
  final WeeklyIssue issue;
  final List<Maker> makers;
  final int spotlightCount;
  final bool pageActive;
  const _CoverSpread({
    required this.issue,
    required this.makers,
    required this.spotlightCount,
    required this.pageActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: issue.accent,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: HalftoneBackground(
                dotColor: AppColors.onNeon,
                spacing: 12.r,
                dotSize: 2,
              ),
            ),
          ),
          // Disco ball — sits in the upper-right, out of the title's way.
          Positioned(
            top: 150.r,
            right: -40.r,
            child: _Enter(
              active: pageActive,
              delay: const Duration(milliseconds: 240),
              from: const Offset(0.4, -0.1),
              child: Transform.rotate(
                angle: 0.15,
                child: Image.asset(
                  'assets/images/stickers/disco_ball.png',
                  width: 150.r,
                  height: 150.r,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Starburst(
                    size: 120.r,
                    color: AppColors.onNeon,
                    points: 12,
                  ),
                ),
              ),
            ),
          ),
          // Vinyl — top-left, tucked under the WEEK label, well clear of title.
          Positioned(
            top: 140.r,
            left: -28.r,
            child: _Enter(
              active: pageActive,
              delay: const Duration(milliseconds: 360),
              from: const Offset(-0.4, -0.1),
              child: Transform.rotate(
                angle: -0.22,
                child: Image.asset(
                  'assets/images/stickers/vinyl.png',
                  width: 96.r,
                  height: 96.r,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.r, 90.r, 24.r, 40.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Enter(
                  active: pageActive,
                  from: const Offset(-0.3, 0),
                  child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                      decoration: BoxDecoration(
                        color: AppColors.onNeon,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'FEATURING $spotlightCount',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                          letterSpacing: 1.6.sp,
                          color: issue.accent,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.r),
                    Text(
                      'HANDPICKED, NOT AN AD',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 9.sp,
                        letterSpacing: 1.4.sp,
                        color: AppColors.onNeon.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                ),
                SizedBox(height: 16.r),
                _Enter(
                  active: pageActive,
                  delay: const Duration(milliseconds: 60),
                  from: const Offset(-0.2, 0),
                  child: Text(
                    '#HATRI · MAG',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                      letterSpacing: -0.6.sp,
                      color: AppColors.onNeon,
                    ),
                  ),
                ),
                SizedBox(height: 4.r),
                _Enter(
                  active: pageActive,
                  delay: const Duration(milliseconds: 120),
                  from: const Offset(-0.2, 0),
                  child: Text(
                    'WEEK ${issue.weekNumber} · ${issue.year}',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 11.sp,
                      letterSpacing: 2.sp,
                      color: AppColors.onNeon.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                SizedBox(height: 180.r),
                _Enter(
                  active: pageActive,
                  delay: const Duration(milliseconds: 260),
                  from: const Offset(0, 0.15),
                  child: _TitleWithLightning(
                    title: issue.title,
                    pageActive: pageActive,
                  ),
                ),
                SizedBox(height: 16.r),
                _Enter(
                  active: pageActive,
                  delay: const Duration(milliseconds: 340),
                  child: Text(
                    issue.blurb,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 1.4,
                      color: AppColors.onNeon.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                SizedBox(height: 20.r),
                _Enter(
                  active: pageActive,
                  delay: const Duration(milliseconds: 420),
                  from: const Offset(0.2, 0),
                  child: _PortraitStrip(portraits: makers.map((m) => m.portrait).toList()),
                ),
                const Spacer(),
                _Enter(
                  active: pageActive,
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    'SWIPE',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 12.sp,
                      letterSpacing: 2.sp,
                      color: AppColors.onNeon,
                    ),
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

/// Cover title with an inline lightning sticker floating above the city-name
/// line. Splits on `\n` so it adapts to whatever city name the issue carries —
/// RAIPUR, MUMBAI, HYDERABAD — the sticker tracks the last letter of that
/// specific line.
class _TitleWithLightning extends StatelessWidget {
  final String title;
  final bool pageActive;
  const _TitleWithLightning({required this.title, required this.pageActive});

  @override
  Widget build(BuildContext context) {
    final lines = title.split('\n');
    final cityLine = lines.first;
    final tail = lines.length > 1 ? lines.sublist(1).join('\n') : '';

    final titleStyle = TextStyle(
      fontFamily: 'ClashDisplay',
      fontWeight: FontWeight.w800,
      fontSize: 56.sp,
      height: 0.92,
      letterSpacing: -2.sp,
      color: AppColors.onNeon,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // City name — sizes to its own content, so we know its right edge.
            Text(cityLine, style: titleStyle),
            // Lightning floats above the city name's tail letter.
            Positioned(
              right: -34.r,
              top: -46.r,
              child: _Enter(
                active: pageActive,
                delay: const Duration(milliseconds: 480),
                from: const Offset(0.3, -0.2),
                child: Transform.rotate(
                  angle: 0.18,
                  child: Image.asset(
                    'assets/images/stickers/lightning.png',
                    width: 92.r,
                    height: 92.r,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (tail.isNotEmpty)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(tail, style: titleStyle),
          ),
      ],
    );
  }
}

class _PortraitStrip extends StatelessWidget {
  final List<String> portraits;
  const _PortraitStrip({required this.portraits});

  @override
  Widget build(BuildContext context) {
    const overlap = 18.0;
    final size = 46.r;
    return SizedBox(
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < portraits.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.onNeon, width: 2),
                ),
                child: ClipOval(
                  child: HatriImage(url: portraits[i], fit: BoxFit.cover, errorWidget: Container(color: AppColors.surface),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Spread 2 · Editor's letter ────────────────────────────────────────────

class _EditorSpread extends StatelessWidget {
  final WeeklyIssue issue;
  final bool pageActive;
  const _EditorSpread({required this.issue, required this.pageActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Megaphone sticker — editor's voice metaphor.
        Positioned(
          top: 70.r,
          right: 14.r,
          child: _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 300),
            from: const Offset(0.3, -0.2),
            child: Transform.rotate(
              angle: 0.18,
              child: Image.asset(
                'assets/images/stickers/megaphone.png',
                width: 140.r,
                height: 140.r,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        Padding(
      padding: EdgeInsets.fromLTRB(24.r, 90.r, 24.r, 40.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Enter(active: pageActive, from: const Offset(-0.2, 0),
            child: _Eyebrow(text: 'EDITOR\'S LETTER', accent: issue.accent),
          ),
          SizedBox(height: 14.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 100),
            from: const Offset(0, 0.1),
            child: Text(
              'Hi.',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 44.sp,
                height: 0.95,
                letterSpacing: -1.4.sp,
                color: AppColors.paper,
              ),
            ),
          ),
          SizedBox(height: 20.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 200),
            child: Text(
              'This week we pulled six people who all make something with their hands, from home. no salons, no studios, no algorithms.',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                fontSize: 18.sp,
                height: 1.5,
                color: AppColors.paper.withValues(alpha: 0.9),
              ),
            ),
          ),
          SizedBox(height: 16.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Some of them you\'ll want to book right now. Some of them you\'ll want to send to your group chat. Both are fine.\n\nHatri is a magazine, not a marketplace. we pick, you decide. no ads. no sponsored slots. every maker in this issue got here because someone on our team saw their work and said yes.',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                height: 1.65,
                color: AppColors.paper.withValues(alpha: 0.75),
              ),
            ),
          ),
          SizedBox(height: 24.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 400),
            from: const Offset(-0.2, 0),
            child: Text(
              '— #HATRI',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                letterSpacing: -0.4.sp,
                color: issue.accent,
              ),
            ),
          ),
        ],
      ),
    ),
      ],
    );
  }
}

// ─── Spread 3 · Stats (Spotify-wrapped moment) ────────────────────────────

class _StatsSpread extends StatelessWidget {
  final int makerCount;
  final int categoryCount;
  final int neighborhoodCount;
  final double avgRating;
  final int totalReviews;
  final bool pageActive;

  const _StatsSpread({
    required this.makerCount,
    required this.categoryCount,
    required this.neighborhoodCount,
    required this.avgRating,
    required this.totalReviews,
    required this.pageActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.fuchsia,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: HalftoneBackground(
                dotColor: AppColors.paper,
                spacing: 12.r,
                dotSize: 2,
              ),
            ),
          ),
          Positioned(
            top: 60.r,
            right: -30.r,
            child: _Enter(
              active: pageActive,
              delay: const Duration(milliseconds: 250),
              from: const Offset(0.5, -0.2),
              child: Transform.rotate(
                angle: 0.3,
                child: Starburst(size: 130.r, color: AppColors.accentYellow, points: 12),
              ),
            ),
          ),
          // Camera sticker — left-aligned, sits directly above the rating
          // badge in the bottom-left area.
          Positioned(
            bottom: 90.r,
            left: -14.r,
            child: _Enter(
              active: pageActive,
              delay: const Duration(milliseconds: 560),
              from: const Offset(-0.3, 0.2),
              child: Transform.rotate(
                angle: -0.16,
                child: Image.asset(
                  'assets/images/stickers/camera.png',
                  width: 130.r,
                  height: 130.r,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.r, 90.r, 24.r, 40.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Enter(
                  active: pageActive,
                  from: const Offset(-0.2, 0),
                  child: _Eyebrow(text: 'BY THE NUMBERS', accent: AppColors.accentYellow),
                ),
                SizedBox(height: 14.r),
                _Enter(
                  active: pageActive,
                  delay: const Duration(milliseconds: 100),
                  from: const Offset(0, 0.15),
                  child: Text(
                    'This\nissue in\nnumbers.',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 44.sp,
                      height: 0.92,
                      letterSpacing: -1.6.sp,
                      color: AppColors.paper,
                    ),
                  ),
                ),
                SizedBox(height: 32.r),
                _StatRow(
                  active: pageActive,
                  delayMs: 200,
                  bigNumber: '$makerCount',
                  label: 'MAKERS',
                  sub: 'picked by hand this week',
                ),
                _StatRow(
                  active: pageActive,
                  delayMs: 320,
                  bigNumber: '$categoryCount',
                  label: 'CATEGORIES',
                  sub: 'wildly different vibes under one roof',
                ),
                _StatRow(
                  active: pageActive,
                  delayMs: 440,
                  bigNumber: '$neighborhoodCount',
                  label: 'NEIGHBOURHOODS',
                  sub: 'walkable if you\'re willing',
                ),
                const Spacer(),
                _Enter(
                  active: pageActive,
                  delay: const Duration(milliseconds: 620),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
                    decoration: BoxDecoration(
                      color: AppColors.onNeon,
                      borderRadius: BorderRadius.circular(Corners.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 20.r, color: AppColors.accentYellow),
                        SizedBox(width: 6.r),
                        Text(
                          '${avgRating.toStringAsFixed(1)} avg · $totalReviews reviews across the issue',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                            color: AppColors.paper,
                          ),
                        ),
                      ],
                    ),
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

class _StatRow extends StatelessWidget {
  final bool active;
  final int delayMs;
  final String bigNumber;
  final String label;
  final String sub;
  const _StatRow({
    required this.active,
    required this.delayMs,
    required this.bigNumber,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return _Enter(
      active: active,
      delay: Duration(milliseconds: delayMs),
      from: const Offset(-0.15, 0),
      child: Padding(
        padding: EdgeInsets.only(bottom: 18.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              bigNumber,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 72.sp,
                height: 0.8,
                letterSpacing: -3.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(width: 14.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 12.sp,
                      letterSpacing: 1.8.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    sub,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                      height: 1.3,
                      color: AppColors.paper.withValues(alpha: 0.8),
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
}

// ─── Spread 3–5 · Feature ─────────────────────────────────────────────────

class _FeatureSpread extends StatelessWidget {
  final Maker maker;
  final Color accent;
  final int featureNumber;
  final int totalFeatures;
  final bool pageActive;
  final VoidCallback onTap;
  const _FeatureSpread({
    required this.maker,
    required this.accent,
    required this.featureNumber,
    required this.totalFeatures,
    required this.pageActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-bleed portrait, top half
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                HatriImage(url: maker.portrait, fit: BoxFit.cover, errorWidget: Container(color: accent),
                ),
                Positioned(
                  top: 90.r,
                  left: 24.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 4.r),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'FEATURE $featureNumber / $totalFeatures',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 10.sp,
                        letterSpacing: 1.6.sp,
                        color: AppColors.onNeon,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Editorial info block, bottom half
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: AppColors.ground,
              padding: EdgeInsets.fromLTRB(24.r, 20.r, 24.r, 24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maker.primaryTag,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 11.sp,
                      letterSpacing: 1.8.sp,
                      color: accent,
                    ),
                  ),
                  SizedBox(height: 6.r),
                  Text(
                    maker.name,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 40.sp,
                      height: 0.9,
                      letterSpacing: -1.4.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 10.r),
                  Text(
                    '"${maker.tagline}"',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      height: 1.4,
                      color: AppColors.paper.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: 16.r),
                  Row(
                    children: [
                      Container(width: 14.r, height: 3, color: accent),
                      SizedBox(width: 6.r),
                      Text(
                        'THE STORY',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                          letterSpacing: 1.6.sp,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.r),
                  Expanded(
                    child: Text(
                      maker.bio,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                        height: 1.55,
                        color: AppColors.paper.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 14.r, color: AppColors.muted),
                      SizedBox(width: 4.r),
                      Text(
                        maker.neighborhood,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(width: 12.r),
                      if (maker.reviewCount > 0) ...[
                        Icon(Icons.star_rounded, size: 14.r, color: AppColors.accentYellow),
                        SizedBox(width: 2.r),
                        Text(
                          '${maker.rating.toStringAsFixed(1)} · ${maker.reviewCount}',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                            color: AppColors.paper,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(Corners.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'OPEN PROFILE',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 10.sp,
                                letterSpacing: 1.4.sp,
                                color: AppColors.onNeon,
                              ),
                            ),
                            SizedBox(width: 4.r),
                            Icon(Icons.arrow_forward, size: 12.r, color: AppColors.onNeon),
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
    );
  }
}

// ─── Spread 6 · Meet the rest ─────────────────────────────────────────────

class _LineupSpread extends StatelessWidget {
  final List<Maker> makers;
  final bool pageActive;
  final void Function(Maker) onTap;
  const _LineupSpread({required this.makers, required this.onTap, required this.pageActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Decorative starburst behind the header, top-right.
        Positioned(
          top: 60.r,
          right: -30.r,
          child: _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 220),
            from: const Offset(0.4, -0.2),
            child: Transform.rotate(
              angle: 0.25,
              child: Starburst(size: 120.r, color: AppColors.lime, points: 12),
            ),
          ),
        ),
        // Flame heart bottom-left — love for the cast.
        Positioned(
          bottom: 60.r,
          left: -20.r,
          child: _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 700),
            from: const Offset(-0.3, 0.2),
            child: Transform.rotate(
              angle: -0.15,
              child: Image.asset(
                'assets/images/stickers/flame_heart.png',
                width: 110.r,
                height: 110.r,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.r, 90.r, 20.r, 30.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Enter(
                active: pageActive,
                from: const Offset(-0.2, 0),
                child: _Eyebrow(text: 'THIS WEEK\'S ROLL CALL', accent: AppColors.lime),
              ),
              SizedBox(height: 10.r),
              _Enter(
                active: pageActive,
                delay: const Duration(milliseconds: 100),
                from: const Offset(0, 0.1),
                child: Text(
                  'Names in the credits.',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 30.sp,
                    height: 0.95,
                    letterSpacing: -1.sp,
                    color: AppColors.paper,
                  ),
                ),
              ),
              SizedBox(height: 4.r),
              _Enter(
                active: pageActive,
                delay: const Duration(milliseconds: 180),
                child: Text(
                  '${makers.length} names. no leads. no extras.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: AppColors.muted,
                  ),
                ),
              ),
              SizedBox(height: 22.r),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: makers.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.paper.withValues(alpha: 0.08),
                  ),
                  itemBuilder: (_, i) => _RollCallRow(
                    maker: makers[i],
                    number: i + 1,
                    pageActive: pageActive,
                    delayMs: 260 + i * 70,
                    onTap: () => onTap(makers[i]),
                  ),
                ),
              ),
              SizedBox(height: 8.r),
              _Enter(
                active: pageActive,
                delay: const Duration(milliseconds: 720),
                child: Center(
                  child: Text(
                    '— roll credits.',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One row of the roll-call list. Big lime number + portrait circle + name +
/// role tag + tap chevron. Reads like a movie's end credits.
class _RollCallRow extends StatelessWidget {
  final Maker maker;
  final int number;
  final bool pageActive;
  final int delayMs;
  final VoidCallback onTap;
  const _RollCallRow({
    required this.maker,
    required this.number,
    required this.pageActive,
    required this.delayMs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Enter(
      active: pageActive,
      delay: Duration(milliseconds: delayMs),
      from: const Offset(-0.15, 0),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 44.r,
                child: Text(
                  number.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 26.sp,
                    height: 1.0,
                    letterSpacing: -0.8.sp,
                    color: AppColors.lime,
                  ),
                ),
              ),
              // Portrait circle
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipOval(
                  child: HatriImage(url: maker.portrait, fit: BoxFit.cover, errorWidget: Container(color: AppColors.surface),
                  ),
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      maker.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 20.sp,
                        height: 1.0,
                        letterSpacing: -0.6.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    SizedBox(height: 4.r),
                    Text(
                      '— ${maker.primaryTag.toLowerCase()} · ${maker.neighborhood}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.r),
              if (maker.reviewCount > 0) ...[
                Icon(Icons.star_rounded, size: 13.r, color: AppColors.accentYellow),
                SizedBox(width: 2.r),
                Text(
                  maker.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                    color: AppColors.paper,
                  ),
                ),
                SizedBox(width: 8.r),
              ],
              Icon(Icons.arrow_forward, size: 16.r, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Spread 7 · Back cover ─────────────────────────────────────────────────

class _BackCoverSpread extends StatelessWidget {
  final WeeklyIssue issue;
  final int nextWeek;
  final bool pageActive;
  const _BackCoverSpread({required this.issue, required this.nextWeek, required this.pageActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppColors.ground,
          padding: EdgeInsets.fromLTRB(24.r, 90.r, 24.r, 40.r),
          child: _BackCoverBody(issue: issue, nextWeek: nextWeek, pageActive: pageActive),
        ),
        // Confetti fires only when this spread is currently active.
        if (pageActive)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/lottie/Confetti.json',
                fit: BoxFit.cover,
                repeat: false,
              ),
            ),
          ),
      ],
    );
  }
}

class _BackCoverBody extends StatelessWidget {
  final WeeklyIssue issue;
  final int nextWeek;
  final bool pageActive;
  const _BackCoverBody({required this.issue, required this.nextWeek, required this.pageActive});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Enter(active: pageActive, from: const Offset(-0.2, 0),
            child: _Eyebrow(text: 'END OF ISSUE', accent: AppColors.fuchsia),
          ),
          SizedBox(height: 20.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 120),
            from: const Offset(0, 0.15),
            child: Text(
              'That\'s the cut.',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 44.sp,
                height: 0.95,
                letterSpacing: -1.6.sp,
                color: AppColors.paper,
              ),
            ),
          ),
          SizedBox(height: 20.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 220),
            from: const Offset(0, 0.2),
            child: Center(
              child: TweenAnimationBuilder<double>(
                key: ValueKey(pageActive),
                tween: Tween(begin: -0.1, end: 0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (_, angle, child) => Transform.rotate(angle: angle, child: child),
                child: Image.asset(
                  'assets/images/stickers/main_character.png',
                  width: 240.r,
                  height: 240.r,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Lottie.asset(
                    'assets/lottie/movie_clapperboard.json',
                    width: 220.r,
                    height: 220.r,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 360),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 320.r),
              child: Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(Corners.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT ISSUE',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                    letterSpacing: 1.8.sp,
                    color: AppColors.lime,
                  ),
                ),
                SizedBox(height: 8.r),
                Text(
                  'WEEK $nextWeek DROPS\nFRIDAY 8PM',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 24.sp,
                    height: 1.05,
                    letterSpacing: -0.6.sp,
                    color: AppColors.paper,
                  ),
                ),
                SizedBox(height: 8.r),
                Text(
                  'six more people. mixed bag. we\'ll see you here.',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    height: 1.4,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          ),
          ),
          ),
          const Spacer(),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 460),
            from: const Offset(0, 0.2),
            child: Center(
              child: Transform.rotate(
                angle: -0.1,
                child: Image.asset(
                  'assets/images/stickers/lightning.png',
                  width: 90.r,
                  height: 90.r,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          SizedBox(height: 4.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 540),
            child: Center(
              child: Column(
                children: [
                  Text(
                    '#HATRI',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 44.sp,
                      height: 1.0,
                      letterSpacing: -1.4.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    'MAGAZINE · WEEK ${issue.weekNumber}',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                      letterSpacing: 2.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  }
}

// ─── Spread · Table of Contents ────────────────────────────────────────────

class _TableOfContentsSpread extends StatelessWidget {
  final WeeklyIssue issue;
  final List<Maker> spotlights;
  final bool pageActive;
  const _TableOfContentsSpread({
    required this.issue,
    required this.spotlights,
    required this.pageActive,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <_TocEntry>[
      const _TocEntry(page: '02', title: 'EDITOR\'S LETTER', teaser: 'a note from the desk.'),
      const _TocEntry(page: '03', title: 'BY THE NUMBERS', teaser: '6 · 6 · 4. this issue in stats.'),
      if (spotlights.isNotEmpty)
        _TocEntry(page: '04', title: 'FEATURE · ${spotlights[0].name.toUpperCase()}', teaser: spotlights[0].tagline),
      const _TocEntry(page: '05', title: 'OVERHEARD', teaser: 'raipur, off the record.'),
      if (spotlights.length > 1)
        _TocEntry(page: '06', title: 'FEATURE · ${spotlights[1].name.toUpperCase()}', teaser: spotlights[1].tagline),
      const _TocEntry(page: '07', title: 'ROLL CALL', teaser: 'the full cast.'),
      const _TocEntry(page: '08', title: 'THE OSCARS', teaser: 'and the winner is.'),
      const _TocEntry(page: '09', title: 'END OF ISSUE', teaser: 'that\'s the cut.'),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.r, 90.r, 24.r, 40.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Enter(active: pageActive, from: const Offset(-0.2, 0),
            child: _Eyebrow(text: 'IN THIS ISSUE', accent: issue.accent),
          ),
          SizedBox(height: 10.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 100),
            from: const Offset(0, 0.1),
            child: Text(
              'Contents.',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 40.sp,
                height: 0.95,
                letterSpacing: -1.4.sp,
                color: AppColors.paper,
              ),
            ),
          ),
          SizedBox(height: 20.r),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 1,
                color: AppColors.paper.withValues(alpha: 0.08),
              ),
              itemBuilder: (_, i) {
                final e = entries[i];
                return _Enter(
                  active: pageActive,
                  delay: Duration(milliseconds: 220 + i * 60),
                  from: const Offset(-0.15, 0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        SizedBox(
                          width: 38.r,
                          child: Text(
                            e.page,
                            style: TextStyle(
                              fontFamily: 'ClashDisplay',
                              fontWeight: FontWeight.w800,
                              fontSize: 20.sp,
                              letterSpacing: -0.6.sp,
                              color: issue.accent,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                e.title,
                                style: TextStyle(
                                  fontFamily: 'ClashDisplay',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.sp,
                                  height: 1.05,
                                  letterSpacing: -0.2.sp,
                                  color: AppColors.paper,
                                ),
                              ),
                              SizedBox(height: 2.r),
                              Text(
                                e.teaser,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'ClashDisplay',
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TocEntry {
  final String page;
  final String title;
  final String teaser;
  const _TocEntry({required this.page, required this.title, required this.teaser});
}

// ─── Spread · Group Chat ───────────────────────────────────────────────────

class _GroupChatSpread extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool pageActive;
  const _GroupChatSpread({required this.messages, required this.pageActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 90.r, 20.r, 30.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Enter(
            active: pageActive,
            from: const Offset(-0.2, 0),
            child: _Eyebrow(text: 'THE GROUP CHAT', accent: AppColors.lime),
          ),
          SizedBox(height: 10.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 100),
            from: const Offset(0, 0.1),
            child: Text(
              'Makers only.',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 34.sp,
                height: 0.95,
                letterSpacing: -1.2.sp,
                color: AppColors.paper,
              ),
            ),
          ),
          SizedBox(height: 4.r),
          _Enter(
            active: pageActive,
            delay: const Duration(milliseconds: 180),
            child: Text(
              'a peek at this week\'s featured chat.',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: AppColors.muted,
              ),
            ),
          ),
          SizedBox(height: 18.r),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.r),
              itemBuilder: (_, i) => _Enter(
                active: pageActive,
                delay: Duration(milliseconds: 240 + i * 80),
                from: Offset(messages[i].alignRight ? 0.2 : -0.2, 0),
                child: _ChatBubble(msg: messages[i]),
              ),
            ),
          ),
          SizedBox(height: 8.r),
          _Enter(
            active: pageActive,
            delay: Duration(milliseconds: 240 + messages.length * 80 + 100),
            child: Center(
              child: Text(
                'read · ${_readTime()}',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp,
                  letterSpacing: 1.4.sp,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _readTime() {
    final now = DateTime.now();
    final h = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final bg = msg.alignRight ? AppColors.lime : AppColors.surface;
    final fg = msg.alignRight ? AppColors.onNeon : AppColors.paper;
    final senderColor = msg.alignRight ? AppColors.onNeon.withValues(alpha: 0.6) : AppColors.muted;
    return Row(
      mainAxisAlignment: msg.alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: 280.r),
            padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(msg.alignRight ? 16.r : 4.r),
                bottomRight: Radius.circular(msg.alignRight ? 4.r : 16.r),
              ),
              border: msg.alignRight ? null : Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.sender,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 10.sp,
                    letterSpacing: 1.2.sp,
                    color: senderColor,
                  ),
                ),
                SizedBox(height: 3.r),
                Text(
                  msg.text,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    height: 1.35,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Spread · The Oscars ───────────────────────────────────────────────────

class _OscarsSpread extends StatelessWidget {
  final List<Award> awards;
  final bool pageActive;
  const _OscarsSpread({required this.awards, required this.pageActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentYellow,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: HalftoneBackground(
                dotColor: AppColors.onNeon,
                spacing: 12.r,
                dotSize: 2,
              ),
            ),
          ),
          Positioned(
            top: 60.r,
            right: -30.r,
            child: _Enter(
              active: pageActive,
              delay: const Duration(milliseconds: 250),
              from: const Offset(0.4, -0.2),
              child: Transform.rotate(
                angle: 0.25,
                child: Starburst(size: 130.r, color: AppColors.fuchsia, points: 12),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.r, 90.r, 24.r, 40.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Enter(
                  active: pageActive,
                  from: const Offset(-0.2, 0),
                  child: Row(
                    children: [
                      Container(width: 14.r, height: 3, color: AppColors.fuchsia),
                      SizedBox(width: 8.r),
                      Text(
                        'THE OSCARS · WEEK 42',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 11.sp,
                          letterSpacing: 1.8.sp,
                          color: AppColors.fuchsia,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.r),
                _Enter(
                  active: pageActive,
                  delay: const Duration(milliseconds: 100),
                  from: const Offset(0, 0.1),
                  child: Text(
                    'And the winner is...',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 30.sp,
                      height: 0.95,
                      letterSpacing: -1.2.sp,
                      color: AppColors.onNeon,
                    ),
                  ),
                ),
                SizedBox(height: 18.r),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: awards.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      thickness: 1.5,
                      color: AppColors.onNeon.withValues(alpha: 0.15),
                    ),
                    itemBuilder: (_, i) => _Enter(
                      active: pageActive,
                      delay: Duration(milliseconds: 260 + i * 80),
                      from: const Offset(-0.15, 0),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.r),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              awards[i].glyph,
                              style: TextStyle(fontSize: 28.sp),
                            ),
                            SizedBox(width: 12.r),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    awards[i].category,
                                    style: TextStyle(
                                      fontFamily: 'GeneralSans',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10.sp,
                                      letterSpacing: 1.4.sp,
                                      color: AppColors.fuchsia,
                                    ),
                                  ),
                                  SizedBox(height: 2.r),
                                  Text(
                                    awards[i].winner,
                                    style: TextStyle(
                                      fontFamily: 'ClashDisplay',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18.sp,
                                      height: 1.05,
                                      letterSpacing: -0.4.sp,
                                      color: AppColors.onNeon,
                                    ),
                                  ),
                                  SizedBox(height: 2.r),
                                  Text(
                                    awards[i].blurb,
                                    style: TextStyle(
                                      fontFamily: 'ClashDisplay',
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.sp,
                                      height: 1.3,
                                      color: AppColors.onNeon.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

