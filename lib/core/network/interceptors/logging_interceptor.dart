import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Minimal debug-only request/response logger. Only installed when
/// [kDebugMode] is true, so release builds carry no overhead.
///
/// Intentionally compact. For richer dumps use `pretty_dio_logger` ad-hoc.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('-> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '<- ${response.statusCode} '
      '${response.requestOptions.method} '
      '${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      'x ${err.response?.statusCode ?? '-'} '
      '${err.requestOptions.method} '
      '${err.requestOptions.path} '
      '${err.message}',
    );
    handler.next(err);
  }
}
