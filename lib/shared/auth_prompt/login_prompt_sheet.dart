import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// Context-aware copy for the sheet. Each is a single short line (keeps the
/// sheet short and the vibe light). Pass [LoginReason.custom] with [customLine]
/// for one-offs.
enum LoginReason { rsvp, save, react, follow, generic, custom }

String _lineFor(LoginReason reason, String? custom) {
  switch (reason) {
    case LoginReason.rsvp:
      return 'quick thing — one phone number and this spot is yours. 📲';
    case LoginReason.save:
      return 'save it to find it later — need a quick sign in first. 🔖';
    case LoginReason.react:
      return 'login first — then react, save, show up. 🔥';
    case LoginReason.follow:
      return 'follow the makers you vibe with — sign in to lock it in. ✨';
    case LoginReason.generic:
      return 'sign in once. then everything on hatri remembers you.';
    case LoginReason.custom:
      return custom ?? 'sign in to make it stick.';
  }
}

/// Shows the login prompt as a modal bottom sheet. Returns true if the user
/// chose to go to the sign-in flow (we navigate for them), false otherwise.
Future<bool> showLoginPromptSheet(
  BuildContext context, {
  required LoginReason reason,
  String? customLine,
}) async {
  HapticFeedback.selectionClick();
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.ground,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(Corners.lg.toDouble())),
    ),
    builder: (ctx) => _LoginPromptSheet(line: _lineFor(reason, customLine)),
  );
  return result == true;
}

class _LoginPromptSheet extends StatelessWidget {
  final String line;
  const _LoginPromptSheet({required this.line});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.r, 16.r, 24.r, 20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grabber
            Center(
              child: Container(
                width: 40.r,
                height: 4.r,
                margin: EdgeInsets.only(bottom: 16.r),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            // Mascot peeking in
            Center(
              child: SizedBox(
                height: 120.r,
                child: Image.asset(
                  'assets/images/stickers/main_character.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 12.r),
            // Headline
            Text(
              'hop in first.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w800,
                fontSize: 32.sp,
                height: 1.0,
                letterSpacing: -0.6.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 10.r),
            // Reason-specific line
            Text(
              line,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
                height: 1.35,
                color: AppColors.muted,
              ),
            ),
            SizedBox(height: 24.r),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 52.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(Corners.md),
                      ),
                      child: Text(
                        'LATER',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          letterSpacing: 1.2.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, true);
                      context.push('/phone');
                    },
                    child: Container(
                      height: 52.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.fuchsia,
                        borderRadius: BorderRadius.circular(Corners.md),
                      ),
                      child: Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          letterSpacing: 1.2.sp,
                          color: AppColors.paper,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
