import 'package:equatable/equatable.dart';

/// Typed, UI-safe failure that flows out of every repository and use case.
///
/// Data-layer code throws exceptions (see [exceptions.dart]); the repository
/// implementation catches them and maps to one of these subclasses. Blocs then
/// pattern-match on the concrete type to pick appropriate copy and surface a
/// retry affordance where it makes sense.
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// No usable network. Caller can prompt a retry once connectivity returns.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Server returned 5xx or a malformed body. Likely transient.
class ServerFailure extends Failure {
  /// HTTP status when available. Null for parse errors or non-HTTP shaped
  /// failures.
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Request succeeded but the resource does not exist (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

/// Auth missing or rejected (401/403). The UI should route to sign-in or
/// surface a re-auth prompt.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Please sign in to continue.']);
}

/// Caller sent malformed input (400 / 422), or the backend rejected a field.
class ValidationFailure extends Failure {
  /// Optional per-field errors, keyed by the field name the server returned.
  final Map<String, String>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Local cache read/write failed. Rare but we surface it so the caller can
/// decide whether to fall back to the network.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error.']);
}

/// Anything that doesn't fit the categories above. Keep this rare; most
/// failures should map to a specific type so the UI can respond intelligently.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}
