import '../../../../backend/api/auth_api.dart';
import '../../../../backend/models/auth_models.dart';

/// Thin seam for the clean-arch data layer. Mirrors AuthApi 1:1. In this
/// pass it is a passthrough wrapper; a later PR inlines the HTTP calls
/// here and retires the old AuthApi.
abstract class AuthRemoteDataSource {
  Future<OtpRequestResult> requestOtp(String phone);
  Future<OtpVerifyResult> verifyOtp(String phone, String otp);
  Future<OtpVerifyResult> verifyMsg91(String accessToken);
  Future<RefreshResult> refresh(String refreshToken);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApi _api;
  const AuthRemoteDataSourceImpl(this._api);

  @override
  Future<OtpRequestResult> requestOtp(String phone) => _api.requestOtp(phone);

  @override
  Future<OtpVerifyResult> verifyOtp(String phone, String otp) =>
      _api.verifyOtp(phone, otp);

  @override
  Future<OtpVerifyResult> verifyMsg91(String accessToken) =>
      _api.verifyMsg91(accessToken);

  @override
  Future<RefreshResult> refresh(String refreshToken) =>
      _api.refresh(refreshToken);

  @override
  Future<void> logout(String refreshToken) => _api.logout(refreshToken);
}
