// Exceptions thrown inside the data layer. They never leave a repository
// implementation. The repo catches these and emits a Failure instead, so the
// domain + presentation layers only ever see typed failures.

/// Thrown when the server returns a non-2xx response the API treats as fatal.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when the request cannot leave the device, or the socket is torn
/// down mid-flight.
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network unavailable.']);

  @override
  String toString() => 'NetworkException: $message';
}

/// 404 from the backend, or a resource lookup that returned no row.
class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Resource not found.']);

  @override
  String toString() => 'NotFoundException: $message';
}

/// 401 / 403 and token-expiry cases that the auth interceptor could not
/// recover from.
class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Not authenticated.']);

  @override
  String toString() => 'AuthException: $message';
}

/// 400 / 422 and client-side validation that reached the data layer.
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;
  const ValidationException(this.message, {this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

/// Local persistence (secure storage, shared prefs, Hive) failed.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error.']);

  @override
  String toString() => 'CacheException: $message';
}
