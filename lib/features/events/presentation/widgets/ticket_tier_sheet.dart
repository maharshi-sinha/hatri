import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/models.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';

/// A tier + quantity selection captured by the tier sheet.
class TicketOrder {
  final TicketTier tier;
  final int quantity;
  const TicketOrder({required this.tier, required this.quantity});
  int get total => tier.priceRupees * quantity;
}

/// Bottom sheet that lets the user pick a ticket tier + quantity for a paid
/// event, then runs a mock payment step and returns the order when it
/// succeeds.
Future<TicketOrder?> showTicketTierSheet(BuildContext context, Event event) {
  return showModalBottomSheet<TicketOrder>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (_) => _TicketTierSheet(event: event),
  );
}

class _TicketTierSheet extends StatefulWidget {
  final Event event;
  const _TicketTierSheet({required this.event});

  @override
  State<_TicketTierSheet> createState() => _TicketTierSheetState();
}

class _TicketTierSheetState extends State<_TicketTierSheet> {
  TicketTier? _selected;
  int _qty = 1;
  static const int _maxQty = 8;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    // Pre-select the popular tier if any, else the first tier.
    final tiers = widget.event.tiers;
    if (tiers.isNotEmpty) {
      _selected = tiers.firstWhere(
        (t) => t.isPopular && !t.soldOut,
        orElse: () => tiers.firstWhere((t) => !t.soldOut, orElse: () => tiers.first),
      );
    }
  }

  Future<void> _pay() async {
    final tier = _selected;
    if (tier == null || tier.soldOut) return;
    HapticFeedback.mediumImpact();
    setState(() => _paying = true);
    // Mock payment — 1.2s pretend-processing.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.pop(context, TicketOrder(tier: tier, quantity: _qty));
  }

  void _bumpQty(int delta) {
    final next = (_qty + delta).clamp(1, _maxQty);
    if (next == _qty) return;
    HapticFeedback.selectionClick();
    setState(() => _qty = next);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final tiers = e.tiers;
    final accent = AppColors.fromHex(e.colorHex);
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.ground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(color: AppColors.paper.withValues(alpha: 0.15), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10.r, bottom: 6.r),
                  width: 40.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: AppColors.paper.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(Insets.lg, 8.r, Insets.lg, 24.r),
                  children: [
                    Text(
                      'PICK YOUR TIER',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 10.sp,
                        letterSpacing: 1.6.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 8.r),
                    Text(
                      e.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 22.sp,
                        height: 1.1,
                        letterSpacing: -0.4.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    SizedBox(height: 20.r),
                    for (final t in tiers) ...[
                      _TierCard(
                        tier: t,
                        accent: accent,
                        selected: _selected?.id == t.id,
                        onTap: () {
                          if (t.soldOut) return;
                          HapticFeedback.selectionClick();
                          setState(() => _selected = t);
                        },
                      ),
                      SizedBox(height: 10.r),
                    ],
                  ],
                ),
              ),
              // Quantity + Pay CTA footer
              Container(
                padding: EdgeInsets.fromLTRB(
                  Insets.lg,
                  12.r,
                  Insets.lg,
                  MediaQuery.of(context).padding.bottom + 16.r,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ground,
                  border: Border(
                    top: BorderSide(color: AppColors.paper.withValues(alpha: 0.1)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQtyRow(),
                    SizedBox(height: 10.r),
                    _buildPayButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQtyRow() {
    final unit = _selected?.priceRupees ?? 0;
    final total = unit * _qty;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'QUANTITY',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 1.4.sp,
                color: AppColors.muted,
              ),
            ),
            SizedBox(height: 6.r),
            _stepper(),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TOTAL',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 1.4.sp,
                color: AppColors.muted,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              _selected == null ? '—' : '₹$total',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 22.sp,
                height: 1.0,
                letterSpacing: -0.4.sp,
                color: AppColors.paper,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepper() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.paper.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(icon: Icons.remove_rounded, onTap: () => _bumpQty(-1), enabled: _qty > 1),
          SizedBox(
            width: 36.r,
            child: Center(
              child: Text(
                '$_qty',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.w800,
                  fontSize: 18.sp,
                  height: 1.0,
                  letterSpacing: -0.4.sp,
                  color: AppColors.paper,
                ),
              ),
            ),
          ),
          _stepperButton(icon: Icons.add_rounded, onTap: () => _bumpQty(1), enabled: _qty < _maxQty),
        ],
      ),
    );
  }

  Widget _stepperButton({required IconData icon, required VoidCallback onTap, required bool enabled}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40.r,
        height: 40.r,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20.r,
          color: enabled ? AppColors.paper : AppColors.paper.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    final total = (_selected?.priceRupees ?? 0) * _qty;
    return Row(children: [Expanded(child: _payInner(total))]);
  }

  Widget _payInner(int total) {
    final disabled = _selected == null || _paying;
    return GestureDetector(
      onTap: disabled ? null : _pay,
      child: Container(
        height: 54.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _selected == null ? AppColors.surfaceRaised : AppColors.fuchsia,
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: _paying
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: const CircularProgressIndicator(color: AppColors.paper, strokeWidth: 2.4),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selected == null ? 'SELECT A TIER' : 'PAY',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      height: 1.0,
                      letterSpacing: -0.2.sp,
                      color: _selected == null ? AppColors.muted : AppColors.paper,
                    ),
                  ),
                  if (_selected != null) ...[
                    SizedBox(width: 10.r),
                    Text(
                      '₹$total',
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 22.sp,
                        height: 1.0,
                        letterSpacing: -0.4.sp,
                        color: AppColors.paper,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

}

class _TierCard extends StatelessWidget {
  final TicketTier tier;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _TierCard({
    required this.tier,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSoldOut = tier.soldOut;
    return Opacity(
      opacity: isSoldOut ? 0.45 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.r, 14.r, 14.r, 14.r),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            border: Border.all(
              color: selected ? accent : AppColors.paper.withValues(alpha: 0.12),
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Radio dot
              Container(
                width: 20.r,
                height: 20.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? accent : AppColors.paper.withValues(alpha: 0.3),
                    width: selected ? 6 : 1.5,
                  ),
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          tier.name,
                          style: TextStyle(
                            fontFamily: 'ClashDisplay',
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
                            height: 1.0,
                            letterSpacing: -0.2.sp,
                            color: AppColors.paper,
                          ),
                        ),
                        if (tier.isPopular) ...[
                          SizedBox(width: 8.r),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                            decoration: BoxDecoration(
                              color: AppColors.lime,
                              borderRadius: BorderRadius.circular(Corners.pill),
                            ),
                            child: Text(
                              'POPULAR',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 8.sp,
                                letterSpacing: 1.0.sp,
                                color: AppColors.onNeon,
                              ),
                            ),
                          ),
                        ],
                        if (isSoldOut) ...[
                          SizedBox(width: 8.r),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                            decoration: BoxDecoration(
                              color: AppColors.paper.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(Corners.pill),
                            ),
                            child: Text(
                              'SOLD OUT',
                              style: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w800,
                                fontSize: 8.sp,
                                letterSpacing: 1.0.sp,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (tier.perk != null) ...[
                      SizedBox(height: 4.r),
                      Text(
                        tier.perk!,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 10.r),
              Text(
                '₹${tier.priceRupees}',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.w800,
                  fontSize: 20.sp,
                  height: 1.0,
                  letterSpacing: -0.4.sp,
                  color: AppColors.paper,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
