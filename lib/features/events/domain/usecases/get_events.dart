import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/repositories/event_feed_page.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/event_repository.dart';

/// Fetch one page of the discovery feed. See [EventRepository.getEvents].
class GetEvents extends UseCase<EventFeedPage, GetEventsParams> {
  final EventRepository repo;
  const GetEvents(this.repo);

  @override
  Future<Either<Failure, EventFeedPage>> call(GetEventsParams p) =>
      repo.getEvents(
        cursor: p.cursor,
        citySlug: p.citySlug,
        category: p.category,
        limit: p.limit,
      );
}

class GetEventsParams extends Equatable {
  final String? cursor;
  final String? citySlug;
  final String? category;
  final int limit;

  const GetEventsParams({
    this.cursor,
    this.citySlug,
    this.category,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [cursor, citySlug, category, limit];
}
