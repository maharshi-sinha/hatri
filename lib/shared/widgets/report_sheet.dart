import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/reports/reports_store.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// Bottom sheet to file a report against any content in the app — wall posts,
/// makers, scenes, comments. Reason picker up top, details textarea below.
///
/// Details are always REQUIRED for "Something else", optional but encouraged
/// for the preset reasons. A clear preset lets moderators triage without
/// reading; the free text catches nuance.
class ReportSheet extends StatefulWidget {
  final ReportTarget target;
  final String targetId;
  final String subjectLabel; // "Kavya", "this post", "Raipur Photography Club"

  const ReportSheet({
    super.key,
    required this.target,
    required this.targetId,
    required this.subjectLabel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required ReportTarget target,
    required String targetId,
    required String subjectLabel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportSheet(
        target: target,
        targetId: targetId,
        subjectLabel: subjectLabel,
      ),
    );
  }

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  ReportReason? _reason;
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_reason == null) return false;
    if (_reason == ReportReason.other && _text.text.trim().isEmpty) return false;
    return true;
  }

  void _submit() {
    if (!_canSubmit) return;
    HapticFeedback.mediumImpact();
    ReportsStore.instance.submit(
      target: widget.target,
      targetId: widget.targetId,
      reason: _reason!,
      details: _text.text,
    );
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reported. our team\'ll take a look.',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
            color: AppColors.onNeon,
          ),
        ),
        backgroundColor: AppColors.lime,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
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
                Container(width: 14.r, height: 3, color: AppColors.fuchsia),
                SizedBox(width: 8.r),
                Text(
                  'REPORT ${widget.subjectLabel.toUpperCase()}',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                    letterSpacing: 1.6.sp,
                    color: AppColors.fuchsia,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.r),
            Text(
              "What's wrong?",
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 28.sp,
                height: 1.0,
                letterSpacing: -0.8.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 6.r),
            Text(
              'pick the closest reason. anything extra helps our team decide faster.',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                height: 1.4,
                color: AppColors.muted,
              ),
            ),
            SizedBox(height: 16.r),
            // Reason chips — single select
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: ReportReason.values.map((r) {
                final selected = _reason == r;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _reason = r);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 10.r),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.fuchsia : AppColors.surface,
                      border: Border.all(
                        color: selected ? AppColors.fuchsia : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(Corners.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(r.emoji, style: TextStyle(fontSize: 13.sp)),
                        SizedBox(width: 6.r),
                        Text(
                          r.label,
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                            color: selected ? AppColors.paper : AppColors.paper.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.r),
            // Details field
            Text(
              _reason == ReportReason.other ? 'What happened? *' : 'Extra context (optional)',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 11.sp,
                letterSpacing: 1.2.sp,
                color: AppColors.muted,
              ),
            ),
            SizedBox(height: 8.r),
            TextField(
              controller: _text,
              onChanged: (_) => setState(() {}),
              maxLines: 4,
              maxLength: 400,
              cursorColor: AppColors.fuchsia,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: AppColors.paper,
              ),
              decoration: InputDecoration(
                hintText: 'what did they post, when, why does it break things?',
                hintStyle: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
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
                  borderSide: BorderSide(color: AppColors.fuchsia, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 14.r),
            GestureDetector(
              onTap: _canSubmit ? _submit : null,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.r),
                decoration: BoxDecoration(
                  color: _canSubmit ? AppColors.fuchsia : AppColors.surface,
                  borderRadius: BorderRadius.circular(Corners.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  'SEND REPORT',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 13.sp,
                    letterSpacing: 1.6.sp,
                    color: _canSubmit ? AppColors.paper : AppColors.muted,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.r),
            Center(
              child: Text(
                'reports are private. the person you reported won\'t know.',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 10.sp,
                  color: AppColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
