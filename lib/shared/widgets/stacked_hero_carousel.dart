import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/makers.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../design/motifs.dart';

/// Deck-of-Polaroids hero carousel. Renders the front 3 cards from [cards].
///   • Every [cycleDuration] the top card "throws" down-right (rotates + fades),
///     the card behind snaps up to the front, and a new card fades in at the back.
///   • Tap a card = navigate. Manual left-swipe advances the deck.
///   • Auto-rotation pauses on user touch, resumes after [resumeDelay].
class StackedHeroCarousel extends StatefulWidget {
  final List<HeroCard> cards;
  final void Function(HeroCard) onTap;
  final Duration cycleDuration;
  final Duration throwDuration;
  final Duration resumeDelay;

  const StackedHeroCarousel({
    super.key,
    required this.cards,
    required this.onTap,
    this.cycleDuration = const Duration(seconds: 6),
    this.throwDuration = const Duration(milliseconds: 520),
    this.resumeDelay = const Duration(seconds: 8),
  });

  @override
  State<StackedHeroCarousel> createState() => _StackedHeroCarouselState();
}

class _StackedHeroCarouselState extends State<StackedHeroCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  Timer? _timer;
  int _front = 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.throwDuration);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.cycleDuration, (_) => _advance());
  }

  void _pauseAndResume() {
    _timer?.cancel();
    _timer = Timer(widget.resumeDelay, _startTimer);
  }

  Future<void> _advance() async {
    if (_c.isAnimating) return;
    await _c.forward(from: 0);
    if (!mounted) return;
    setState(() => _front = (_front + 1) % widget.cards.length);
    _c.value = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.sm),
      child: SizedBox(
        height: 240.r,
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) < -200) {
              HapticFeedback.selectionClick();
              _pauseAndResume();
              _advance();
            }
          },
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, _) => _buildStack(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStack(BuildContext context) {
    final N = widget.cards.length;
    final t = Curves.easeInOutCubic.transform(_c.value);
    final rendered = <_CardRender>[];

    for (int i = 0; i < N; i++) {
      final oldSlot = (i - _front + N) % N;
      final newSlot = (i - _front - 1 + N) % N;
      if (oldSlot >= 4 && newSlot >= 4) continue;
      final geom = _lerpGeom(oldSlot, newSlot, t);
      if (geom.opacity <= 0.01) continue;
      rendered.add(_CardRender(card: widget.cards[i], geom: geom));
    }
    // Deepest first so top card paints last.
    rendered.sort((a, b) => b.geom.depth.compareTo(a.geom.depth));

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        for (final r in rendered)
          Positioned.fill(
            child: Transform.translate(
              offset: r.geom.offset,
              child: Transform.rotate(
                angle: r.geom.rotation,
                child: Transform.scale(
                  scale: r.geom.scale,
                  alignment: Alignment.topCenter,
                  child: Opacity(
                    opacity: r.geom.opacity,
                    child: IgnorePointer(
                      ignoring: r.geom.depth != 0,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _pauseAndResume();
                          widget.onTap(r.card);
                        },
                        child: HeroCardWidget(card: r.card),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  _Geom _lerpGeom(int oldSlot, int newSlot, double t) {
    final a = _slotGeom(oldSlot);
    final b = _slotGeom(newSlot);
    return _Geom(
      offset: Offset.lerp(a.offset, b.offset, t)!,
      scale: a.scale + (b.scale - a.scale) * t,
      opacity: (a.opacity + (b.opacity - a.opacity) * t).clamp(0.0, 1.0),
      rotation: a.rotation + (b.rotation - a.rotation) * t,
      depth: t < 0.5 ? a.depth : b.depth,
    );
  }

  /// Slot geometry map. Slot 0 is the front card; higher = deeper.
  /// Slot 3 = thrown-off state (used as newSlot for the exiting front card).
  _Geom _slotGeom(int slot) {
    switch (slot) {
      case 0:
        return const _Geom(
            offset: Offset.zero, scale: 1.0, opacity: 1.0, rotation: 0, depth: 0);
      case 1:
        return _Geom(
            offset: Offset(6.r, 8.r),
            scale: 0.96,
            opacity: 1.0,
            rotation: -0.02,
            depth: 1);
      case 2:
        return _Geom(
            offset: Offset(12.r, 16.r),
            scale: 0.92,
            opacity: 1.0,
            rotation: 0.02,
            depth: 2);
      case 3:
        // Thrown-off: down-right with tilt.
        return _Geom(
            offset: Offset(80.r, 60.r),
            scale: 0.94,
            opacity: 0.0,
            rotation: 0.12,
            depth: -1);
      default:
        return const _Geom(
            offset: Offset.zero, scale: 0.88, opacity: 0.0, rotation: 0, depth: 99);
    }
  }
}

class _Geom {
  final Offset offset;
  final double scale;
  final double opacity;
  final double rotation;
  final int depth;
  const _Geom({
    required this.offset,
    required this.scale,
    required this.opacity,
    required this.rotation,
    required this.depth,
  });
}

class _CardRender {
  final HeroCard card;
  final _Geom geom;
  _CardRender({required this.card, required this.geom});
}

// ─── The card visual ───────────────────────────────────────────────────────

class HeroCardWidget extends StatelessWidget {
  final HeroCard card;
  const HeroCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final accent = card.accent;
    // Eyebrow + title read best in near-black on lime/yellow, paper on dark tints.
    final onAccent = (accent == AppColors.lime || accent == AppColors.accentYellow)
        ? AppColors.onNeon
        : AppColors.paper;
    // Shadow color rotates through the palette to give each card its own "peek".
    final shadowColor = _peekFor(accent);

    return StickerShadow(
      color: shadowColor,
      offset: Offset(5.r, 5.r),
      radius: Corners.lg,
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(Corners.lg),
          border: Border.all(color: AppColors.onNeon, width: 1.5),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.10,
                child: HalftoneBackground(
                  dotColor: onAccent,
                  spacing: 10.r,
                  dotSize: 2,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.eyebrow,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                          letterSpacing: 1.6.sp,
                          color: onAccent,
                        ),
                      ),
                      SizedBox(height: 6.r),
                      Text(
                        card.title,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 34.sp,
                          height: 0.92,
                          letterSpacing: -1.2.sp,
                          color: onAccent,
                        ),
                      ),
                      SizedBox(height: 8.r),
                      Text(
                        card.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          height: 1.3,
                          color: onAccent.withValues(alpha: 0.75),
                        ),
                      ),
                      SizedBox(height: 12.r),
                      _CardCta(label: card.cta, accent: accent, onAccent: onAccent),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.r),
                  child: Column(
                    children: [
                      Starburst(size: 44.r, color: _primaryStar(accent), points: 8),
                      SizedBox(height: 8.r),
                      Starburst(size: 22.r, color: _secondaryStar(accent), points: 6),
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

  /// Shadow "peek" behind the card. Contrasting hue that reads at a glance
  /// when the card is stacked deeper in the deck.
  Color _peekFor(Color c) {
    if (c == AppColors.lime) return AppColors.fuchsia;
    if (c == AppColors.fuchsia) return AppColors.indigo;
    if (c == AppColors.indigo) return AppColors.accentYellow;
    if (c == AppColors.accentYellow) return AppColors.indigo;
    return AppColors.fuchsia;
  }

  /// Big starburst — bold contrast against the card bg.
  Color _primaryStar(Color bg) {
    if (bg == AppColors.lime) return AppColors.indigo;         // purple on lime
    if (bg == AppColors.fuchsia) return AppColors.indigo;      // purple on pink
    if (bg == AppColors.indigo) return AppColors.accentYellow; // yellow on purple
    if (bg == AppColors.accentYellow) return AppColors.indigo; // purple on yellow
    return AppColors.fuchsia;
  }

  /// Small starburst — a third hue so the pair reads as two dots, not a shadow.
  Color _secondaryStar(Color bg) {
    if (bg == AppColors.lime) return AppColors.fuchsia;
    if (bg == AppColors.fuchsia) return AppColors.accentYellow;
    if (bg == AppColors.indigo) return AppColors.fuchsia;
    if (bg == AppColors.accentYellow) return AppColors.fuchsia;
    return AppColors.indigo;
  }
}

class _CardCta extends StatelessWidget {
  final String label;
  final Color accent;
  final Color onAccent;
  const _CardCta(
      {required this.label, required this.accent, required this.onAccent});

  @override
  Widget build(BuildContext context) {
    // Invert: CTA background = the "on" color; text = accent. Reads as a chip
    // that pops off the card.
    final bg = onAccent;
    final fg = accent;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w800,
          fontSize: 12.sp,
          letterSpacing: 1.4.sp,
          color: fg,
        ),
      ),
    );
  }
}
