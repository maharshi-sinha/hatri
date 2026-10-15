import 'package:equatable/equatable.dart';

/// Sentinel for use cases that take no input. Use instead of null so the
/// generic signature `UseCase<Return, Params>` stays non-nullable.
///
/// Usage:
/// ```dart
/// class LoadMe extends UseCase<User, NoParams> { ... }
/// loadMe(const NoParams());
/// ```
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => const [];
}
