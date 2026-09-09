import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';

/// Snapchat-style overscroll reveal. Wraps a vertically scrolling child and
/// stacks a sticky [header] over it. The mascot sits hidden BEHIND the header
/// at rest and rides down into the gap as the user pulls, so it feels like
/// it's being dragged out from behind the marquee.
///
/// Purely decorative — no refresh trigger.
class PullReveal extends StatefulWidget {
  final Widget child;

  /// Sticky header (e.g. the marquee). Painted on top of the scroll + mascot.
  final Widget? header;

  /// Height of the sticky header — needed to hide the mascot behind it at rest.
  final double headerHeight;

  /// Asset path for the mascot.
  final String mascot;

  /// Pixels of overscroll needed to reach full reveal.
  final double revealDistance;

  /// Rendered mascot size (logical px, scaled with .r).
  final double mascotSize;

  const PullReveal({
    super.key,
    required this.child,
    this.header,
    this.headerHeight = 0,
    this.mascot = 'assets/images/utility/pull_refresh.png',
    this.revealDistance = 140,
    this.mascotSize = 84,
  });

  @override
  State<PullReveal> createState() => _PullRevealState();
}

class _PullRevealState extends State<PullReveal> {
  final ValueNotifier<double> _pull = ValueNotifier(0);

  @override
  void dispose() {
    _pull.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final over = -n.metrics.pixels.clamp(-widget.revealDistance * 2, 0.0);
    _pull.value = (over / widget.revealDistance).clamp(0.0, 1.0);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.mascotSize.r;
    final headerH = widget.headerHeight;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // 1) Scroll content (bottom layer).
            widget.child,
            // 2) Mascot — hidden behind the header at rest, slides down as pull grows.
            Positioned(
              top: headerH,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _pull,
                builder: (_, t, _) {
                  if (t <= 0) return const SizedBox.shrink();
                  final eased = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
                  // At t=0 mascot sits behind the header (translated up by its own
                  // height). At t=1 its top edge is flush with the header bottom.
                  final translateY = -size * (1 - eased);
                  final tilt = (t - 0.6).clamp(0.0, 0.4) * 0.35;
                  return IgnorePointer(
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, translateY),
                        child: Transform.rotate(
                          angle: tilt,
                          child: Opacity(
                            opacity: eased,
                            child: Image.asset(
                              widget.mascot,
                              width: size,
                              height: size,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 3) Sticky header (top layer) — covers the mascot at rest.
            if (widget.header != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: widget.header!,
              ),
          ],
        ),
      ),
    );
  }
}
