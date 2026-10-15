import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// Base class for every use case. A use case is a single verb, one method
/// (`call`), returning `Either<Failure, Return>`.
///
/// Example:
/// ```dart
/// class GetEvents extends UseCase<EventFeedPage, GetEventsParams> {
///   final EventRepository repo;
///   GetEvents(this.repo);
///   @override
///   Future<Either<Failure, EventFeedPage>> call(GetEventsParams p) =>
///       repo.getEvents(cursor: p.cursor);
/// }
/// ```
abstract class UseCase<Return, Params> {
  Future<Either<Failure, Return>> call(Params params);
}

/// Synchronous flavor. Rare, but useful for pure transforms exposed as a
/// use case (e.g. phone-number formatting) so the bloc layer still routes
/// through the domain.
abstract class SyncUseCase<Return, Params> {
  Either<Failure, Return> call(Params params);
}
