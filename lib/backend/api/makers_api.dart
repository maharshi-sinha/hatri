import 'package:dio/dio.dart';

import '../models/maker_models.dart';
import 'http_client.dart';

class MakersApi {
  final HttpClient _http;
  MakersApi(this._http);

  static const _base = '/api/v1/makers';

  Future<ApiMakerFeed> list({
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
      return ApiMakerFeed.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  Future<ApiMakerDetail> getById(String id) async {
    try {
      final res = await _http.dio.get<Map<String, dynamic>>('$_base/$id');
      return ApiMakerDetail.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Requires auth.
  Future<FollowResult> follow(String id) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>('$_base/$id/follow');
      return FollowResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  Future<FollowResult> unfollow(String id) async {
    try {
      final res = await _http.dio.delete<Map<String, dynamic>>('$_base/$id/follow');
      return FollowResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }
}
