import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/event_repository.dart';

class GetEventBySlug extends UseCase<Event, String> {
  final EventRepository repo;
  const GetEventBySlug(this.repo);

  @override
  Future<Either<Failure, Event>> call(String slug) => repo.getBySlug(slug);
}
