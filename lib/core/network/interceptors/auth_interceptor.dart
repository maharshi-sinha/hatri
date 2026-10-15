import 'dart:async';
import 'package:dio/dio.dart';

/// Attaches a bearer token to outgoing requests and fires a callback when
/// the server returns 401 so the auth layer can clear tokens and route the
/// user back to sign-in.
///
/// Decoupled from the auth implementation: callers inject a `tokenProvider`
/// (sync, so interceptors stay non-blocking) and an `onUnauthorized`
/// callback. Keeps the clean-arch core free of any dependency on
/// `AuthService`.
class AuthInterceptor extends Interceptor {
  final String? Function() tokenProvider;
  final Future<void> Function() onUnauthorized;

  AuthInterceptor({
    required this.tokenProvider,
    required this.onUnauthorized,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Fire-and-forget: the error must keep propagating so the repository
      // can map it to an AuthFailure.
      unawaited(onUnauthorized());
    }
    handler.next(err);
  }
}
