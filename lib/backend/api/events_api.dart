import 'package:dio/dio.dart';

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
}
