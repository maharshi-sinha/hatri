import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Factory for the single Dio instance used by the clean-arch data layer.
///
/// Not wired yet. The existing `lib/backend/api/http_client.dart` continues
/// to serve every feature until each one migrates in its own PR. When a
/// feature moves into `features/<name>/data/`, its datasource will take a
/// Dio built by [DioClient.create] instead.
///
/// Composition order matters:
///   1. AuthInterceptor runs first on request (attach bearer) and last on
///      error (401 side-effect).
///   2. RetryInterceptor sits in the middle so retried requests still get
///      a fresh bearer and still get their errors translated.
///   3. ErrorInterceptor translates DioException into our typed exceptions.
///   4. LoggingInterceptor only runs in debug.
class DioClient {
  const DioClient._();

  static Dio create({
    required String baseUrl,
    required String? Function() tokenProvider,
    required Future<void> Function() onUnauthorized,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 15),
    Duration sendTimeout = const Duration(seconds: 10),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        responseType: ResponseType.json,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // 4xx and 5xx both throw so ErrorInterceptor can convert them.
        validateStatus: (code) => code != null && code >= 200 && code < 300,
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: tokenProvider,
        onUnauthorized: onUnauthorized,
      ),
    );
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
    dio.interceptors.add(ErrorInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }
    return dio;
  }
}
