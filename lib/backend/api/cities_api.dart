import 'package:dio/dio.dart';

import '../models/city_models.dart';
import 'http_client.dart';

class CitiesApi {
  final HttpClient _http;
  CitiesApi(this._http);

  /// GET /api/v1/cities?active=true — only cities Hatri is live in.
  Future<List<ApiCity>> listActive() async {
    try {
      final res = await _http.dio.get<List<dynamic>>(
        '/api/v1/cities',
        queryParameters: {'active': 'true'},
      );
      return (res.data ?? const [])
          .map((e) => ApiCity.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }
}
