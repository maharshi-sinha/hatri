import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';

import '../../flavors.dart';
import 'api_exception.dart';

/// The single Dio instance the whole app talks to the backend through.
///
/// - Base URL comes from the current flavor.
/// - AuthInterceptor attaches the Bearer token when one is present.
/// - RetryInterceptor auto-retries transient network failures (max 2 tries).
/// - Dev-only logger prints request/response summaries.
class HttpClient {
  final Dio dio;

  /// Called on every request. Returns the current access token, or null if
  /// the user isn't signed in yet. Injected from AuthService.
  String? Function()? _tokenProvider;

  /// Called when the server returns 401 so AuthService can wipe tokens and
  /// nudge the app back to the sign-in screen.
  Future<void> Function()? _onUnauthorized;

  HttpClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: F.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
            responseType: ResponseType.json,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            // A 4xx response should throw so we translate it into a typed
            // ApiException, not let it silently return non-json.
            validateStatus: (code) => code != null && code >= 200 && code < 300,
          ),
        ) {
    dio.interceptors.add(_AuthInterceptor(this));
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: 2,
        retryDelays: const [
          Duration(milliseconds: 300),
          Duration(seconds: 1),
        ],
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(_DevLogInterceptor());
    }
  }

  /// AuthService calls this once during DI setup.
  void wireAuth({
    required String? Function() tokenProvider,
    required Future<void> Function() onUnauthorized,
  }) {
    _tokenProvider = tokenProvider;
    _onUnauthorized = onUnauthorized;
  }

  /// Translate a DioException into one of our sealed ApiException types so
  /// the service layer never has to know about Dio.
  ApiException translate(DioException e) {
    final res = e.response;
    if (res != null) {
      final code = res.statusCode ?? 0;
      final msg = _extractMessage(res.data) ?? 'Request failed';
      final errCode = _extractCode(res.data);
      if (code == 401) return UnauthorizedException(msg);
      if (code == 404) return NotFoundException(msg);
      if (code >= 400 && code < 500) {
        return ClientException(code, msg, code: errCode);
      }
      if (code >= 500) return ServerException(code, msg);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkException('Request timed out');
    }
    if (e.error is SocketException) {
      return const NetworkException('No connection to server');
    }
    return NetworkException(e.message ?? 'Network error');
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m is String) return m;
      if (m is List && m.isNotEmpty && m.first is String) return m.first;
    }
    return null;
  }

  String? _extractCode(dynamic data) {
    if (data is Map<String, dynamic>) {
      final c = data['code'];
      if (c is String) return c;
    }
    return null;
  }
}

class _AuthInterceptor extends Interceptor {
  final HttpClient _client;
  _AuthInterceptor(this._client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _client._tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Fire-and-forget — don't block the error handler.
      unawaited(_client._onUnauthorized?.call() ?? Future.value());
    }
    handler.next(err);
  }
}

class _DevLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        '← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
        '✗ ${err.response?.statusCode ?? '-'} ${err.requestOptions.method} ${err.requestOptions.path} — ${err.message}');
    handler.next(err);
  }
}
