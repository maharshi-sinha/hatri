import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/di/injection_container.dart';
import '../api/api_exception.dart';
import '../api/auth_api.dart';
import '../api/http_client.dart';
import '../models/auth_models.dart';

/// Auth state the UI reads through `ValueListenableBuilder<AuthState>`.
enum AuthStatus {
  /// Boot state before init() finishes reading storage.
  unknown,

  /// No token or refresh failed. UI shows sign-in.
  signedOut,

  /// Access token valid. UI shows the app.
  signedIn,
}

class AuthState {
  final AuthStatus status;
  final ApiUser? user;
  const AuthState(this.status, this.user);

  static const unknown = AuthState(AuthStatus.unknown, null);
}

/// Owns the JWT lifecycle. Everything auth-related goes through here:
/// - persistent token storage (secure keychain / keystore)
/// - transparent access-token refresh
/// - login state broadcasts via ValueNotifier
///
/// Provides HttpClient with a token getter + 401 handler at DI time so the
/// interceptor can attach the Bearer header on every request.
class AuthService {
  final AuthApi _api;
  final HttpClient _http;
  final FlutterSecureStorage _storage;

  static const _accessKey = 'hatri.auth.access';
  static const _refreshKey = 'hatri.auth.refresh';
  static const _userKey = 'hatri.auth.user';

  String? _accessToken;
  String? _refreshToken;
  ApiUser? _user;

  /// Ensures a single in-flight refresh even if many requests hit 401 at once.
  Future<void>? _refreshInFlight;

  final ValueNotifier<AuthState> state =
      ValueNotifier<AuthState>(AuthState.unknown);

  AuthService({
    required AuthApi api,
    required HttpClient http,
    FlutterSecureStorage? storage,
  })  : _api = api,
        _http = http,
        _storage = storage ?? const FlutterSecureStorage();

  /// Boot-time initialization. Loads tokens from storage; if the access
  /// token is expired, attempts a silent refresh.
  Future<void> init() async {
    _http.wireAuth(
      tokenProvider: () => _accessToken,
      onUnauthorized: _handleUnauthorized,
    );

    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    final userJson = await _storage.read(key: _userKey);

    if (access == null || refresh == null) {
      state.value = const AuthState(AuthStatus.signedOut, null);
      return;
    }
    _accessToken = access;
    _refreshToken = refresh;
    _user = userJson == null
        ? null
        : ApiUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);

    if (_isExpired(access)) {
      try {
        await _refresh();
      } catch (_) {
        await _clear();
        return;
      }
    }
    state.value = AuthState(AuthStatus.signedIn, _user);
  }

  /// Called by the phone-entry screen.
  Future<OtpRequestResult> requestOtp(String phone) {
    return _api.requestOtp(phone);
  }

  /// Called by the OTP screen. On success, persists tokens and flips auth
  /// state to signedIn.
  Future<void> verifyOtp(String phone, String otp) async {
    final result = await _api.verifyOtp(phone, otp);
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    _user = result.user;
    await _persist();
    state.value = AuthState(AuthStatus.signedIn, _user);
    // Identify the user to analytics + Crashlytics now that we know who they
    // are. Non-blocking: analytics must never fail the auth flow.
    unawaited(sl<AnalyticsService>().identify(userId: _user!.id, phone: phone));
    unawaited(sl<AnalyticsService>().signInCompleted());
  }

  /// Called by the sign-out button.
  Future<void> signOut() async {
    final rt = _refreshToken;
    if (rt != null) {
      // Fire and don't wait — local sign-out should always succeed.
      unawaited(_api.logout(rt));
    }
    unawaited(sl<AnalyticsService>().signedOut());
    unawaited(sl<AnalyticsService>().reset());
    await _clear();
  }

  /// Updates the cached user object after a profile PATCH.
  Future<void> updateCachedUser(ApiUser user) async {
    _user = user;
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    if (state.value.status == AuthStatus.signedIn) {
      state.value = AuthState(AuthStatus.signedIn, user);
    }
  }

  ApiUser? get user => _user;

  bool get isSignedIn => state.value.status == AuthStatus.signedIn;

  // ─── Internal ───

  Future<void> _persist() async {
    await Future.wait([
      _storage.write(key: _accessKey, value: _accessToken),
      _storage.write(key: _refreshKey, value: _refreshToken),
      if (_user != null)
        _storage.write(key: _userKey, value: jsonEncode(_user!.toJson())),
    ]);
  }

  Future<void> _clear() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _userKey),
    ]);
    state.value = const AuthState(AuthStatus.signedOut, null);
  }

  bool _isExpired(String jwt) {
    try {
      return JwtDecoder.isExpired(jwt);
    } catch (_) {
      return true;
    }
  }

  Future<void> _handleUnauthorized() async {
    // Try refresh once; on failure, sign out.
    try {
      await _refresh();
    } catch (_) {
      await _clear();
    }
  }

  Future<void> _refresh() {
    // Coalesce concurrent refreshes.
    _refreshInFlight ??= _doRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
  }

  Future<void> _doRefresh() async {
    final rt = _refreshToken;
    if (rt == null) throw const UnauthorizedException('No refresh token');
    final result = await _api.refresh(rt);
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    await _persist();
  }
}
