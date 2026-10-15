import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/event_repository.dart';

class SearchEvents extends UseCase<List<Event>, SearchEventsParams> {
  final EventRepository repo;
  const SearchEvents(this.repo);

  @override
  Future<Either<Failure, List<Event>>> call(SearchEventsParams p) =>
      repo.search(query: p.query, citySlug: p.citySlug, limit: p.limit);
}

class SearchEventsParams extends Equatable {
  final String query;
  final String? citySlug;
  final int limit;

  const SearchEventsParams({
    required this.query,
    this.citySlug,
    this.limit = 30,
  });

  @override
  List<Object?> get props => [query, citySlug, limit];
}
