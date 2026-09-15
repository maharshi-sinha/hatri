/// Typed exceptions the API layer throws. Services translate these into
/// user-friendly messages or silent fallbacks.
sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

/// Network unreachable, DNS failure, connection refused, timeout.
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

/// Server returned 4xx. Includes the parsed error body if any.
class ClientException extends ApiException {
  final int statusCode;
  final String? code;
  const ClientException(this.statusCode, super.message, {this.code});
}

/// Server returned 5xx.
class ServerException extends ApiException {
  final int statusCode;
  const ServerException(this.statusCode, super.message);
}

/// 401. Token invalid or expired.
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

/// 404.
class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}
