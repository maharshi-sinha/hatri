import 'package:flutter/material.dart';

import '../../core/models/makers.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../design/components.dart';
import 'maker_card.dart';

/// Horizontal rail of makers. Matches the visual rhythm of the event rails so
/// home reads as one feed. Set [isHero] true when this rail is the fallback
/// for a quiet-night home (upsized cards, bigger heading).
class MakerRail extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Color accent;
  final List<Maker> makers;
  final void Function(Maker) onTapMaker;
  final VoidCallback? onSeeAll;
  final bool isHero;

  const MakerRail({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.accent,
    required this.makers,
    required this.onTapMaker,
    this.onSeeAll,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (makers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          eyebrow: eyebrow,
          accent: accent,
          actionLabel: onSeeAll != null ? 'SEE ALL' : null,
          onAction: onSeeAll,
        ),
        SizedBox(
          height: isHero ? 380.r : 300.r,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            itemCount: makers.length,
            itemBuilder: (context, i) => MakerCard(
              maker: makers[i],
              isHero: isHero,
              onTap: () => onTapMaker(makers[i]),
            ),
          ),
        ),
        SizedBox(height: 8.r),
      ],
    );
  }
}
