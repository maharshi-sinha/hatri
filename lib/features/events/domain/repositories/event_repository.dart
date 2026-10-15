import 'dart:io';

import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/repositories/event_feed_page.dart';
import '../../../../core/utils/either_x.dart';

/// Clean-architecture contract for the Events feature. Every method returns
/// `Either<Failure, T>` so the presentation layer deals in typed outcomes
/// instead of raw exceptions.
///
/// Note on entity location: `Event` and `EventFeedPage` still physically
/// live under `core/models/` and `core/repositories/` for backward
/// compatibility with the old call sites. A later PR will move them under
/// `features/events/domain/entities/`. Everything here already refers to
/// them as domain entities; only the import path moves.
abstract class EventRepository {
  /// Paginated discovery feed. Pass the previous page's `nextCursor` back
  /// to fetch the next page. Null cursor fetches the first page.
  Future<Either<Failure, EventFeedPage>> getEvents({
    String? cursor,
    String? citySlug,
    String? category,
    int limit = 20,
  });

  /// Case-insensitive search across title/venue/address. Empty query
  /// resolves to an empty list.
  Future<Either<Failure, List<Event>>> search({
    required String query,
    String? citySlug,
    int limit = 30,
  });

  /// Fetch full event detail by id. Never cached: detail views want fresh
  /// RSVP + capacity counts.
  Future<Either<Failure, Event>> getById(String id);

  /// Slug-keyed fetch. Used by the deeplink handler.
  Future<Either<Failure, Event>> getBySlug(String slug);

  /// Toggle "saved" state. Returns the new total saves count on success.
  Future<Either<Failure, int>> save(String id);
  Future<Either<Failure, int>> unsave(String id);

  /// Toggle a reaction. Returns the new `reacted` state on success.
  Future<Either<Failure, bool>> react(String id, String reaction);

  /// Record a share. Returns the new total shares count.
  Future<Either<Failure, int>> share(String id);

  /// Upload an event cover image. Returns the CDN URL.
  Future<Either<Failure, String>> uploadCover(File file);

  /// Create a new event owned by the current signed-in user. Returns the
  /// full detail model so the caller can route to it.
  Future<Either<Failure, Event>> createEvent(Map<String, dynamic> body);
}
