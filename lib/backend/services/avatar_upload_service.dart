import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

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
  ///
  /// iPhone cameras save HEIC by default. HEIC isn't web-safe (Android, Chrome,
  /// Firefox can't render it), so we transcode to JPEG before upload. Non-HEIC
  /// files pass through untouched.
  Future<ApiUser> uploadAvatar(File file) async {
    final upload = await _normalizeForUpload(file);
    final mime = _mimeFor(upload.path);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        upload.path,
        contentType: mime == null ? null : DioMediaType.parse(mime),
        filename: upload.uri.pathSegments.last,
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

  Future<File> _normalizeForUpload(File file) async {
    final lower = file.path.toLowerCase();
    if (!lower.endsWith('.heic') && !lower.endsWith('.heif')) return file;
    final tmp = await getTemporaryDirectory();
    final target =
        '${tmp.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final out = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      target,
      quality: 88,
      format: CompressFormat.jpeg,
    );
    return out == null ? file : File(out.path);
  }
}
