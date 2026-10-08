import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

/// Thin wrapper around MSG91's official Flutter SDK. Keeps the same public
/// surface Hatri's auth screens already consume ([sendOtp], [verifyOtp]) so
/// the WebView → SDK swap stays invisible to the UI layer.
///
/// Why MSG91 widget: no DLT template registration needed — MSG91 ships OTPs
/// via their own pre-registered templates. Flutter SDK path works on real
/// devices and emulators without the "Web requests are not allowed" rejection
/// the JS/WebView path hits.
///
/// Prerequisites in the MSG91 dashboard for this widget:
///   • Mobile Integration enabled
///   • Invisible OTP disabled (the SDK explicitly doesn't support it)
class Msg91WidgetService {
  Msg91WidgetService({
    required this.widgetId,
    required this.tokenAuth,
  }) {
    OTPWidget.initializeWidget(widgetId, tokenAuth);
  }

  final String widgetId;
  final String tokenAuth;

  /// MSG91 returns a request id with the sendOTP response; verifyOTP then
  /// needs it to match the pending OTP. Stored per-service-instance which is
  /// fine for a single-user mobile app.
  String? _lastReqId;

  /// Trigger the SMS. Resolves when MSG91 confirms dispatch (not when the
  /// user actually receives the message). Throws [Msg91WidgetException] on
  /// any non-success response.
  Future<void> sendOtp(String e164Phone) async {
    // MSG91 wants the mobile number WITHOUT the leading '+'.
    final mobile = e164Phone.replaceFirst(RegExp(r'^\+'), '');
    final response =
        await OTPWidget.sendOTP({'identifier': mobile}) as Map<dynamic, dynamic>?;
    _logResponse('sendOTP', response);
    if (!_isSuccess(response)) {
      throw Msg91WidgetException(_extractError(response, 'send failed'));
    }
    _lastReqId = _extractReqId(response);
    if (_lastReqId == null) {
      throw Msg91WidgetException(
        'sendOTP succeeded but no reqId in response — cannot verify.',
      );
    }
  }

  /// Verify the 6-digit code the user typed. On success returns the
  /// short-lived accessToken that must be POSTed to the backend's
  /// `/auth/msg91/verify` endpoint for the final JWT exchange.
  Future<String> verifyOtp(String otp) async {
    final reqId = _lastReqId;
    if (reqId == null) {
      throw Msg91WidgetException(
        'no pending OTP request — call sendOtp first.',
      );
    }
    final response = await OTPWidget.verifyOTP(
      {'reqId': reqId, 'otp': otp},
    ) as Map<dynamic, dynamic>?;
    _logResponse('verifyOTP', response);
    if (!_isSuccess(response)) {
      throw Msg91WidgetException(_extractError(response, 'verify failed'));
    }
    final token = _extractAccessToken(response);
    if (token == null || token.isEmpty) {
      throw Msg91WidgetException('verifyOTP returned no access token');
    }
    return token;
  }

  /// Resend over the default channel. Convenience wrapper that just re-sends
  /// to the same phone we last used.
  Future<void> resendOtp() async {
    final reqId = _lastReqId;
    if (reqId == null) {
      throw Msg91WidgetException('no previous sendOtp to retry');
    }
    final response = await OTPWidget.retryOTP(
      {'reqId': reqId},
    ) as Map<dynamic, dynamic>?;
    _logResponse('retryOTP', response);
    if (!_isSuccess(response)) {
      throw Msg91WidgetException(_extractError(response, 'retry failed'));
    }
  }

  // ─── Response parsing ────────────────────────────────────────────────
  // MSG91's SDK responses are not strictly typed; the shape varies slightly
  // between send/verify/retry and between success/error. We stay defensive
  // and look at a handful of common fields.

  bool _isSuccess(Map<dynamic, dynamic>? r) {
    if (r == null) return false;
    final type = r['type']?.toString().toLowerCase();
    final hasError = r['hasError'];
    final status = r['status']?.toString().toLowerCase();
    if (type == 'success') return true;
    if (hasError == false) return true;
    if (status == 'success') return true;
    return false;
  }

  String _extractError(Map<dynamic, dynamic>? r, String fallback) {
    if (r == null) return fallback;
    final msg = r['message'] ?? r['error'] ?? r['errorMessage'];
    return msg?.toString() ?? fallback;
  }

  String? _extractReqId(Map<dynamic, dynamic>? r) {
    if (r == null) return null;
    // MSG91's Flutter SDK returns the request ID in `message` for sendOTP
    // (and in verifyOTP uses `message` for the access token — delightful).
    // We check the explicit names first for forward-compatibility and fall
    // back to `message` last.
    final candidates = <dynamic>[
      r['request_id'],
      r['reqId'],
      r['requestId'],
    ];
    final data = r['data'];
    if (data is Map) {
      candidates.addAll([
        data['request_id'],
        data['reqId'],
        data['requestId'],
      ]);
    }
    candidates.add(r['message']);
    for (final c in candidates) {
      if (c != null && c.toString().isNotEmpty) return c.toString();
    }
    return null;
  }

  String? _extractAccessToken(Map<dynamic, dynamic>? r) {
    if (r == null) return null;
    // For verifyOTP, MSG91 historically returns the access token in `message`
    // on success. We also check obvious alternates in case the SDK changes.
    final candidates = [
      r['accessToken'],
      r['access_token'],
      r['message'],
      r['token'],
    ];
    final data = r['data'];
    if (data is Map) {
      candidates.addAll([
        data['accessToken'],
        data['access_token'],
        data['token'],
      ]);
    }
    for (final c in candidates) {
      final v = c?.toString();
      if (v == null || v.isEmpty) continue;
      // Guard against generic "OTP verified" strings being treated as tokens.
      // Real MSG91 tokens are JWT-ish — contain two dots. Fall back to the
      // raw string if nothing looks like a JWT (older SDKs return opaque IDs).
      if (v.split('.').length >= 3) return v;
    }
    // Nothing JWT-shaped — return the first non-empty candidate anyway;
    // backend will reject if it's really not a token.
    for (final c in candidates) {
      final v = c?.toString();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  void _logResponse(String op, Map<dynamic, dynamic>? r) {
    if (kDebugMode) debugPrint('msg91 $op → $r');
  }
}

class Msg91WidgetException implements Exception {
  final String message;
  Msg91WidgetException(this.message);
  @override
  String toString() => 'Msg91WidgetException: $message';
}
