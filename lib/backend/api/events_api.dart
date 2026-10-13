import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../core/images/image_compressor.dart';
import '../models/event_models.dart';
import 'http_client.dart';

class EventsApi {
  final HttpClient _http;
  EventsApi(this._http);

  static const _base = '/api/v1/events';

  /// Discovery feed. All query params optional.
  Future<ApiEventFeed> list({
    String? citySlug,
    String? category,
    String? cursor,
    String? q,
    int limit = 20,
  }) async {
    try {
      final res = await _http.dio.get<Map<String, dynamic>>(
        _base,
        queryParameters: {
          'limit': limit,
          if (citySlug != null) 'citySlug': citySlug,
          if (category != null) 'category': category,
          if (cursor != null) 'cursor': cursor,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );
      return ApiEventFeed.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Event detail. Increments the view counter server-side.
  Future<ApiEventDetail> getById(String id) async {
    try {
      final res = await _http.dio.get<Map<String, dynamic>>('$_base/$id');
      return ApiEventDetail.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Slug-keyed detail. Powers deeplink arrival — the hatri:// scheme and
  /// share URLs carry the slug, not the id. No view increment on this path.
  Future<ApiEventDetail> getBySlug(String slug) async {
    try {
      final res = await _http.dio
          .get<Map<String, dynamic>>('$_base/by-slug/$slug');
      return ApiEventDetail.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Requires auth.
  Future<SaveResult> save(String id) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>('$_base/$id/save');
      return SaveResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  Future<SaveResult> unsave(String id) async {
    try {
      final res = await _http.dio.delete<Map<String, dynamic>>('$_base/$id/save');
      return SaveResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Requires auth. Reaction toggles server-side.
  Future<ReactResult> react(String id, String reaction) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>(
        '$_base/$id/react',
        data: {'reaction': reaction},
      );
      return ReactResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Requires auth.
  Future<ShareResult> share(String id) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>('$_base/$id/share');
      return ShareResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Requires auth. Creates a new event owned by the current user and
  /// returns its full detail.
  Future<ApiEventDetail> create(Map<String, dynamic> body) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>(_base, data: body);
      return ApiEventDetail.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Requires auth. Uploads a cover image via multipart form-data; returns
  /// the public URL to pass as `coverUrl` to [create].
  Future<String> uploadCover(File file) async {
    final upload = await _normalizeForUpload(file);
    final mime = _mimeForPath(upload.path);
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          upload.path,
          filename: upload.uri.pathSegments.last,
          contentType: MediaType.parse(mime),
        ),
      });
      final res = await _http.dio.post<Map<String, dynamic>>(
        '$_base/cover',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      final url = res.data?['url'] as String?;
      if (url == null || url.isEmpty) {
        throw DioException(
          requestOptions: res.requestOptions,
          message: 'cover upload returned no url',
        );
      }
      return url;
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  static String _mimeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  /// Resize + compress event covers to <=500 KB JPEG at 1200 px on the
  /// longest side. Also converts HEIC/HEIF for free since the compressor
  /// always outputs JPEG.
  static Future<File> _normalizeForUpload(File file) async {
    return const ImageCompressor().compressForUpload(
      file,
      maxDimension: 1200,
      maxBytes: 500 * 1024,
      label: 'cover',
    );
  }
}
