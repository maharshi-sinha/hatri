import 'package:dio/dio.dart';

import '../api/api_exception.dart';
import '../api/http_client.dart';
import '../models/auth_models.dart';
import 'auth_service.dart';

/// Talks to /api/v1/me. Wraps the raw call, then feeds the fresh user
/// object back to AuthService so the app's cached copy stays in sync.
class UserService {
  final HttpClient _http;
  final AuthService _auth;

  UserService({required HttpClient http, required AuthService auth})
      : _http = http,
        _auth = auth;

  /// PATCH /api/v1/me. Send only the fields that changed.
  Future<ApiUser> updateProfile({
    String? displayName,
    String? dob,
    String? homeCitySlug,
    String? currentCitySlug,
    List<String>? interests,
    String? bio,
    String? gender,
    String? energy,
    bool? pushDailyVibes,
  }) async {
    final body = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (dob != null) 'dob': dob,
      if (homeCitySlug != null) 'homeCitySlug': homeCitySlug,
      if (currentCitySlug != null) 'currentCitySlug': currentCitySlug,
      if (interests != null) 'interests': interests,
      if (bio != null) 'bio': bio,
      if (gender != null) 'gender': gender,
      if (energy != null) 'energy': energy,
      if (pushDailyVibes != null) 'pushDailyVibes': pushDailyVibes,
    };
    if (body.isEmpty) {
      // Nothing to patch — just return cached user.
      final u = _auth.user;
      if (u == null) throw const UnauthorizedException('Not signed in');
      return u;
    }
    try {
      final res = await _http.dio.patch<Map<String, dynamic>>(
        '/api/v1/me',
        data: body,
      );
      final user = ApiUser.fromJson(res.data!);
      await _auth.updateCachedUser(user);
      return user;
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// DELETE /api/v1/me. Schedules the account for hard deletion 7 days from
  /// now. The user is signed out immediately. Signing back in with the same
  /// phone within 7 days transparently cancels the pending deletion.
  Future<void> deleteAccount() async {
    try {
      await _http.dio.delete<void>('/api/v1/me');
      await _auth.signOut();
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// GET /api/v1/me. Useful after sign-in to refresh the cached user.
  Future<ApiUser> fetchMe() async {
    try {
      final res = await _http.dio.get<Map<String, dynamic>>('/api/v1/me');
      final user = ApiUser.fromJson(res.data!);
      await _auth.updateCachedUser(user);
      return user;
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }
}
