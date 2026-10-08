import 'package:dio/dio.dart';

import '../models/auth_models.dart';
import 'http_client.dart';

/// Raw HTTP calls to /api/v1/auth. No caching, no state — this layer
/// just translates JSON to model and Dio errors to ApiException.
class AuthApi {
  final HttpClient _http;
  AuthApi(this._http);

  static const _base = '/api/v1/auth';

  /// Request a fresh OTP for the given E.164 phone number.
  Future<OtpRequestResult> requestOtp(String phone) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>(
        '$_base/otp/request',
        data: {'phone': phone},
      );
      return OtpRequestResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Verify OTP and receive a fresh access+refresh token pair.
  Future<OtpVerifyResult> verifyOtp(String phone, String otp) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>(
        '$_base/otp/verify',
        data: {'phone': phone, 'otp': otp},
      );
      return OtpVerifyResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// MSG91 widget sign-in: send the short-lived accessToken the widget
  /// handed us; backend confirms it with MSG91 and issues our JWT.
  Future<OtpVerifyResult> verifyMsg91(String accessToken) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>(
        '$_base/msg91/verify',
        data: {'accessToken': accessToken},
      );
      return OtpVerifyResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Rotate the token pair using the current refresh token.
  Future<RefreshResult> refresh(String refreshToken) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>(
        '$_base/refresh',
        data: {'refreshToken': refreshToken},
      );
      return RefreshResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Invalidate the current refresh token server-side. Best-effort — swallows
  /// network errors since local sign-out should always succeed.
  Future<void> logout(String refreshToken) async {
    try {
      await _http.dio.post('$_base/logout', data: {'refreshToken': refreshToken});
    } on DioException {
      // Ignore. AuthService will still wipe local tokens.
    }
  }
}
