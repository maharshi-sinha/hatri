import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/makers/reviews_store.dart';
import '../../../../core/models/makers.dart';
import '../../../../core/models/models.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';

/// Bottom sheet for leaving a review. Big star row → text field → submit.
/// Persists to [ReviewsStore] which the maker profile listens to.
class RateMakerSheet extends StatefulWidget {
  final Maker maker;
  const RateMakerSheet({super.key, required this.maker});

  static Future<void> show(BuildContext context, Maker maker) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RateMakerSheet(maker: maker),
    );
  }

  @override
  State<RateMakerSheet> createState() => _RateMakerSheetState();
}

class _RateMakerSheetState extends State<RateMakerSheet> {
  int _stars = 0;
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_stars == 0 || _text.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    final authorName = currentUser.name.isNotEmpty
        ? currentUser.name.toLowerCase()
        : 'you';
    ReviewsStore.instance.addReview(
      widget.maker.id,
      Review(
        authorName: authorName,
        rating: _stars.toDouble(),
        text: _text.text.trim(),
        date: DateTime.now(),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom = keyboard height; padding.bottom = system UI safe area
    // (iOS home indicator, Android gesture bar). Add both so the CTA never
    // slides under a system chrome no matter the platform.
    final media = MediaQuery.of(context);
    final canSubmit = _stars > 0 && _text.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: AppColors.border),
        ),
        padding: EdgeInsets.fromLTRB(20.r, 14.r, 20.r, 24.r + media.padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.r,
                height: 4.r,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.r),
            Row(
              children: [
                Container(width: 14.r, height: 3, color: AppColors.lime),
                SizedBox(width: 8.r),
                Text(
                  'RATE ${widget.maker.name.toUpperCase()}',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                    letterSpacing: 1.6.sp,
                    color: AppColors.lime,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.r),
            Text(
              'How\'d it go?',
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 28.sp,
                height: 1.0,
                letterSpacing: -0.8.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 20.r),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _stars = i);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.r),
                      child: Icon(
                        i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 44.r,
                        color: i <= _stars
                            ? AppColors.accentYellow
                            : AppColors.border,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 18.r),
            TextField(
              controller: _text,
              onChanged: (_) => setState(() {}),
              maxLines: 4,
              maxLength: 300,
              cursorColor: AppColors.lime,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: AppColors.paper,
              ),
              decoration: InputDecoration(
                hintText: 'what worked, what didn\'t. keep it real.',
                hintStyle: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: AppColors.muted,
                ),
                filled: true,
                fillColor: AppColors.surface,
                counterStyle: TextStyle(color: AppColors.muted, fontSize: 10.sp),
                contentPadding: EdgeInsets.all(14.r),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Corners.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Corners.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Corners.md),
                  borderSide: BorderSide(color: AppColors.lime, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 14.r),
            GestureDetector(
              onTap: canSubmit ? _submit : null,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.r),
                decoration: BoxDecoration(
                  color: canSubmit ? AppColors.lime : AppColors.surface,
                  borderRadius: BorderRadius.circular(Corners.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  'DROP IT',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 13.sp,
                    letterSpacing: 1.6.sp,
                    color: canSubmit ? AppColors.onNeon : AppColors.muted,
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
