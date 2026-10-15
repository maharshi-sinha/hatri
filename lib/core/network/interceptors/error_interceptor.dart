import 'dart:io';
import 'package:dio/dio.dart';

import '../../error/exceptions.dart';

/// Converts [DioException]s into our typed data-layer exceptions
/// (see `core/error/exceptions.dart`). Services and remote datasources only
/// have to `catch (ServerException ...)` etc., and never need to know about
/// Dio.
///
/// Repositories catch those exceptions and emit a `Failure` to the domain
/// layer. The interceptor itself keeps letting the error propagate so Dio's
/// own `then`/`catchError` contract stays intact. All we do here is replace
/// the error payload with a richer, Dio-free type.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final translated = _translate(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: translated,
        stackTrace: err.stackTrace,
        message: translated.toString(),
      ),
    );
  }

  Exception _translate(DioException e) {
    final res = e.response;

    if (res != null) {
      final code = res.statusCode ?? 0;
      final msg = _extractMessage(res.data) ?? 'Request failed.';

      if (code == 401 || code == 403) return AuthException(msg);
      if (code == 404) return NotFoundException(msg);
      if (code == 400 || code == 422) {
        return ValidationException(
          msg,
          fieldErrors: _extractFieldErrors(res.data),
        );
      }
      if (code >= 500) return ServerException(msg, statusCode: code);
      return ServerException(msg, statusCode: code);
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkException('Request timed out.');
    }
    if (e.error is SocketException) {
      return const NetworkException('No connection to server.');
    }
    return NetworkException(e.message ?? 'Network error.');
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m is String) return m;
      if (m is List && m.isNotEmpty && m.first is String) return m.first as String;
    }
    return null;
  }

  /// NestJS validation pipe returns `message` as a list of strings. We don't
  /// get per-field keys for free, so for now we leave this null and the UI
  /// just shows the first message. Hook this up to a real field map once
  /// the backend returns one.
  Map<String, String>? _extractFieldErrors(dynamic data) => null;
}
