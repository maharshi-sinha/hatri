import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import 'motifs.dart';

enum SnackVibe { info, success, muted }

/// Branded snackbar for Hatri — sticker-shadow card, emoji + bold copy.
/// Use instead of raw ScaffoldMessenger.showSnackBar for anything Gen-Z.
class HatriSnack {
  HatriSnack._();

  static void show(
    BuildContext context,
    String message, {
    SnackVibe vibe = SnackVibe.info,
    String? emoji,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.selectionClick();

    final Color bg;
    final Color fg;
    final Color shadow;
    final String defaultEmoji;
    switch (vibe) {
      case SnackVibe.success:
        bg = AppColors.lime;
        fg = AppColors.onNeon;
        shadow = AppColors.fuchsia;
        defaultEmoji = '✨';
        break;
      case SnackVibe.info:
        bg = AppColors.fuchsia;
        fg = AppColors.paper;
        shadow = AppColors.lime;
        defaultEmoji = '📣';
        break;
      case SnackVibe.muted:
        bg = AppColors.graphite;
        fg = AppColors.paper;
        shadow = AppColors.fuchsia;
        defaultEmoji = '💬';
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.fromLTRB(16.r, 0, 16.r, 20.r),
        duration: duration,
        content: StickerShadow(
          color: shadow,
          offset: const Offset(4, 4),
          radius: Corners.md,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(Corners.md),
              border: Border.all(color: AppColors.onNeon, width: 1.4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji ?? defaultEmoji,
                  style: TextStyle(fontSize: 18.sp),
                ),
                SizedBox(width: 10.r),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
