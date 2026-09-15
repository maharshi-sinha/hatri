import 'dart:io';

import 'package:dio/dio.dart';

import '../api/api_exception.dart';
import '../api/http_client.dart';
import '../models/auth_models.dart';
import 'auth_service.dart';

/// Sends a picked photo file to the backend's avatar upload endpoint.
///
/// The backend handles the actual Supabase Storage write and returns the
/// public URL as part of the updated user object. We then refresh the
/// cached user in AuthService.
class AvatarUploadService {
  final HttpClient _http;
  final AuthService _auth;

  AvatarUploadService({required HttpClient http, required AuthService auth})
      : _http = http,
        _auth = auth;

  /// Uploads [file] as multipart form-data (field name: "file") and
  /// returns the updated ApiUser (with the new avatarUrl).
  Future<ApiUser> uploadAvatar(File file) async {
    final mime = _mimeFor(file.path);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        contentType: mime == null ? null : DioMediaType.parse(mime),
        filename: file.uri.pathSegments.last,
      ),
    });

    try {
      final res = await _http.dio.post<Map<String, dynamic>>(
        '/api/v1/me/avatar',
        data: formData,
        options: Options(
          // Dio would otherwise set application/json from our base options.
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      final user = ApiUser.fromJson(res.data!);
      await _auth.updateCachedUser(user);
      return user;
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  String? _mimeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return null;
  }
}
