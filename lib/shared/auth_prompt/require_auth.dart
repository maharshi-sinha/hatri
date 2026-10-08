import 'package:flutter/material.dart';

import '../../backend/services/auth_service.dart';
import '../../core/di/injection_container.dart';
import 'login_prompt_sheet.dart';

/// Guards a protected action behind sign-in. If the user is signed in,
/// [onAuthed] runs immediately. If not, the login-prompt sheet appears with
/// a reason-specific line; when they sign in later, they need to tap the
/// original action again (we don't retry across sign-in — too much ceremony
/// for a bottom sheet dismissal).
///
/// Returns true when the action actually ran.
Future<bool> requireAuth(
  BuildContext context, {
  required LoginReason reason,
  String? customLine,
  required Future<void> Function() onAuthed,
}) async {
  if (sl<AuthService>().isSignedIn) {
    await onAuthed();
    return true;
  }
  // Signed-out — prompt. Don't retry the action after sign-in; the flow
  // takes the user elsewhere and resuming mid-interaction is confusing.
  if (!context.mounted) return false;
  await showLoginPromptSheet(context, reason: reason, customLine: customLine);
  return false;
}
