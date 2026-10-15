import 'package:dio/dio.dart';

import '../models/marquee_models.dart';
import 'http_client.dart';

/// Raw HTTP for /api/v1/marquee. Public read only; admin writes live
/// in the super admin portal.
class MarqueeApi {
  final HttpClient _http;
  MarqueeApi(this._http);

  static const _base = '/api/v1/marquee';

  Future<List<ApiMarqueeItem>> list({String? city}) async {
    try {
      final res = await _http.dio.get<List<dynamic>>(
        _base,
        queryParameters: {
          if (city != null && city.isNotEmpty) 'city': city,
        },
      );
      final items = res.data ?? const [];
      return items
          .map((e) => ApiMarqueeItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }
}
