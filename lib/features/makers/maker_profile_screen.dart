import 'package:flutter/material.dart';
import '../../shared/widgets/hatri_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/makers/reviews_store.dart';
import '../../core/models/makers.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/auth_prompt/login_prompt_sheet.dart';
import '../../shared/auth_prompt/require_auth.dart';
import 'rate_maker_sheet.dart';

/// Public maker profile. Full-bleed portrait cover, meta strip, bio, tag row,
/// portfolio grid, sticky TAP TO INQUIRE CTA.
class MakerProfileScreen extends StatefulWidget {
  final Maker maker;
  const MakerProfileScreen({super.key, required this.maker});

  @override
  State<MakerProfileScreen> createState() => _MakerProfileScreenState();
}

class _MakerProfileScreenState extends State<MakerProfileScreen> {
  Maker get maker => widget.maker;

  @override
  void initState() {
    super.initState();
    ReviewsStore.instance.addListener(_onReviewsChanged);
  }

  @override
  void dispose() {
    ReviewsStore.instance.removeListener(_onReviewsChanged);
    super.dispose();
  }

  void _onReviewsChanged() {
    if (mounted) setState(() {});
  }

  List<Review> get _allReviews {
    final fresh = ReviewsStore.instance.forMaker(maker.id);
    return [...fresh, ...maker.reviews];
  }

  double get _liveRating {
    final all = _allReviews;
    if (all.isEmpty) return maker.rating;
    final sum = all.fold<double>(0, (a, r) => a + r.rating);
    return sum / all.length;
  }

  int get _liveReviewCount => maker.reviewCount + ReviewsStore.instance.forMaker(maker.id).length;

  Future<void> _openInquiry(BuildContext context) async {
    await requireAuth(
      context,
      reason: LoginReason.custom,
      customLine: 'inquire first, book first. sign in and send a note. 💌',
      onAuthed: () async {
        HapticFeedback.mediumImpact();
        final url = _buildBookingUrl(maker);
        if (url == null) return;
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
    );
  }

  Future<void> _openRateSheet(BuildContext context) async {
    await requireAuth(
      context,
      reason: LoginReason.custom,
      customLine: 'drop a review. sign in so it counts. ⭐',
      onAuthed: () async {
        if (!context.mounted) return;
        RateMakerSheet.show(context, maker);
      },
    );
  }

  Future<void> _openMaps(BuildContext context) async {
    HapticFeedback.selectionClick();
    final query = Uri.encodeComponent('${maker.neighborhood} Raipur');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _CoverSliver(maker: maker),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(Insets.lg, 24.r, Insets.lg, 160.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NameBlock(maker: maker),
                      SizedBox(height: 16.r),
                      Wrap(
                        spacing: 10.r,
                        runSpacing: 8.r,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StatusPill(maker: maker),
                          if (_liveReviewCount > 0)
                            _InlineRating(rating: _liveRating, reviewCount: _liveReviewCount),
                        ],
                      ),
                      SizedBox(height: 20.r),
                      _MetaRow(maker: maker),
                      SizedBox(height: 14.r),
                      _LocationRow(maker: maker, onTap: () => _openMaps(context)),
                      SizedBox(height: 20.r),
                      Text(
                        maker.bio,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          height: 1.55,
                          color: AppColors.paper.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 20.r),
                      _TagWrap(tags: maker.tags),
                      SizedBox(height: 28.r),
                      _SectionHeader(label: 'THE WORK'),
                      SizedBox(height: 12.r),
                      _PortfolioGrid(images: maker.portfolio),
                      SizedBox(height: 32.r),
                      _SectionHeader(label: 'WHAT PEOPLE SAY'),
                      SizedBox(height: 10.r),
                      if (_liveReviewCount > 0)
                        _RatingSummary(rating: _liveRating, reviewCount: _liveReviewCount),
                      SizedBox(height: 12.r),
                      _RateCta(onTap: () => _openRateSheet(context)),
                      SizedBox(height: 14.r),
                      for (final r in _allReviews) ...[
                        _ReviewCard(review: r),
                        SizedBox(height: 10.r),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Back button overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.r,
            left: 12.r,
            child: _RoundIconButton(
              icon: 'assets/icons/arrow-left.svg',
              onTap: () => Navigator.pop(context),
            ),
          ),
          // Sticky CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _InquireBar(maker: maker, onTap: () => _openInquiry(context)),
          ),
        ],
      ),
    );
  }
}

Uri? _buildBookingUrl(Maker maker) {
  switch (maker.bookingChannel) {
    case BookingChannel.whatsapp:
      final msg = Uri.encodeComponent('Hi ${maker.name}! Found you on Hatri. can we chat about a booking?');
      return Uri.parse('https://wa.me/${maker.bookingHandle}?text=$msg');
    case BookingChannel.instagram:
      return Uri.parse('https://instagram.com/${maker.bookingHandle}');
    case BookingChannel.inApp:
      return null;
  }
}

// ─── Cover ────────────────────────────────────────────────────────────────

class _CoverSliver extends StatelessWidget {
  final Maker maker;
  const _CoverSliver({required this.maker});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 380.r,
        child: Stack(
          fit: StackFit.expand,
          children: [
            HatriImage(url: maker.portrait, fit: BoxFit.cover, errorWidget: Container(color: maker.statusColor),
            ),
            // Bottom fade so name reads
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.ground.withValues(alpha: 0.85),
                    ],
                    stops: const [0.55, 1.0],
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

// ─── Name + handle ────────────────────────────────────────────────────────

class _NameBlock extends StatelessWidget {
  final Maker maker;
  const _NameBlock({required this.maker});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                maker.name,
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
            if (maker.verified) ...[
              SizedBox(width: 8.r),
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.check_rounded, size: 16.r, color: AppColors.onNeon),
              ),
            ],
          ],
        ),
        SizedBox(height: 6.r),
        Text(
          maker.handle,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
            color: AppColors.muted,
          ),
        ),
        SizedBox(height: 10.r),
        Text(
          maker.tagline,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
            height: 1.4,
            color: AppColors.paper.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Maker maker;
  const _StatusPill({required this.maker});

  @override
  Widget build(BuildContext context) {
    final bg = maker.statusColor;
    final fg = (bg == AppColors.lime || bg == AppColors.accentYellow)
        ? AppColors.onNeon
        : AppColors.paper;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Text(
        maker.statusLabel,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w800,
          fontSize: 11.sp,
          letterSpacing: 1.2.sp,
          color: fg,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Maker maker;
  const _MetaRow({required this.maker});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.r,
      runSpacing: 8.r,
      children: [
        _MetaChip(icon: Icons.currency_rupee, text: maker.priceBand),
        _MetaChip(icon: Icons.event_outlined, text: 'joined ${_monthYear(maker.joinedAt)}'),
      ],
    );
  }

  String _monthYear(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: AppColors.muted),
          SizedBox(width: 6.r),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rating + reviews ──────────────────────────────────────────────────────

class _InlineRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  const _InlineRating({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 16.r, color: AppColors.accentYellow),
        SizedBox(width: 4.r),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontWeight: FontWeight.w800,
            fontSize: 14.sp,
            color: AppColors.paper,
          ),
        ),
        SizedBox(width: 4.r),
        Text(
          '· $reviewCount reviews',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final double rating;
  final int reviewCount;
  const _RatingSummary({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 34.sp,
              height: 1.0,
              letterSpacing: -1.sp,
              color: AppColors.paper,
            ),
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < rating.floor();
                    final half = !filled && i < rating;
                    return Padding(
                      padding: EdgeInsets.only(right: 2.r),
                      child: Icon(
                        half
                            ? Icons.star_half_rounded
                            : filled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                        size: 16.r,
                        color: AppColors.accentYellow,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 4.r),
                Text(
                  '$reviewCount reviews',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: AppColors.muted,
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

class _RateCta extends StatelessWidget {
  final VoidCallback onTap;
  const _RateCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.lime.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Row(
          children: [
            Icon(Icons.star_border_rounded, size: 20.r, color: AppColors.lime),
            SizedBox(width: 10.r),
            Expanded(
              child: Text(
                'been here? drop a review.',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  color: AppColors.paper,
                ),
              ),
            ),
            Text(
              'RATE',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 11.sp,
                letterSpacing: 1.4.sp,
                color: AppColors.lime,
              ),
            ),
            SizedBox(width: 4.r),
            Icon(Icons.arrow_forward, size: 14.r, color: AppColors.lime),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: AppColors.paper.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  review.authorName.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                    color: AppColors.paper,
                  ),
                ),
              ),
              SizedBox(width: 10.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      review.authorName,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    Row(
                      children: [
                        for (int i = 0; i < 5; i++)
                          Icon(
                            i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 12.r,
                            color: AppColors.accentYellow,
                          ),
                        SizedBox(width: 6.r),
                        Text(
                          _monthYear(review.date),
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.r),
          Text(
            review.text,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              height: 1.5,
              color: AppColors.paper.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  String _monthYear(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _LocationRow extends StatelessWidget {
  final Maker maker;
  final VoidCallback onTap;
  const _LocationRow({required this.maker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.fuchsia;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 14.r),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/Location.svg',
              width: 18.r,
              height: 18.r,
              colorFilter: const ColorFilter.mode(accent, BlendMode.srcIn),
            ),
            SizedBox(width: 10.r),
            Expanded(
              child: Text(
                '${maker.neighborhood}, Raipur',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: AppColors.paper,
                ),
              ),
            ),
            SizedBox(width: 8.r),
            Text(
              'FIND ON MAPS',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 1.0.sp,
                color: accent,
              ),
            ),
            SizedBox(width: 4.r),
            Icon(Icons.arrow_outward_rounded, size: 12.r, color: accent),
          ],
        ),
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  final List<String> tags;
  const _TagWrap({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.r,
      runSpacing: 8.r,
      children: tags.map((t) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
          decoration: BoxDecoration(
            color: AppColors.paper.withValues(alpha: 0.06),
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(Corners.pill),
          ),
          child: Text(
            '#${t.replaceAll(' ', '')}',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w700,
              fontSize: 11.sp,
              color: AppColors.paper.withValues(alpha: 0.85),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14.r, height: 3, color: AppColors.lime),
        SizedBox(width: 8.r),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w800,
            fontSize: 11.sp,
            letterSpacing: 1.8.sp,
            color: AppColors.lime,
          ),
        ),
      ],
    );
  }
}

class _PortfolioGrid extends StatelessWidget {
  final List<String> images;
  const _PortfolioGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.r,
        mainAxisSpacing: 10.r,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (_, i) => ClipRRect(
        borderRadius: BorderRadius.circular(Corners.md),
        child: HatriImage(url: images[i], fit: BoxFit.cover, errorWidget: Container(color: AppColors.surfaceRaised),
        ),
      ),
    );
  }
}

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
            width: 20.r,
            height: 20.r,
            colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _InquireBar extends StatelessWidget {
  final Maker maker;
  final VoidCallback onTap;
  const _InquireBar({required this.maker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final channel = maker.bookingChannel;
    final channelLabel = channel == BookingChannel.whatsapp
        ? 'WHATSAPP'
        : channel == BookingChannel.instagram
            ? 'INSTAGRAM'
            : 'IN-APP';
    return Container(
      padding: EdgeInsets.fromLTRB(Insets.lg, 12.r, Insets.lg, MediaQuery.of(context).padding.bottom + 12.r),
      decoration: BoxDecoration(
        color: AppColors.ground,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 20.r),
          decoration: BoxDecoration(
            color: AppColors.lime,
            borderRadius: BorderRadius.circular(Corners.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TAP TO INQUIRE',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                  letterSpacing: 1.6.sp,
                  color: AppColors.onNeon,
                ),
              ),
              Row(
                children: [
                  Text(
                    'via $channelLabel',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                      letterSpacing: 1.2.sp,
                      color: AppColors.onNeon.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(width: 8.r),
                  Icon(Icons.arrow_forward, size: 18.r, color: AppColors.onNeon),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
