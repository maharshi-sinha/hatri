import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/event_repository.dart';

/// Params are kept as a loose JSON map for now. The host-event flow builds
/// this map directly from form state. A later PR replaces it with a typed
/// `CreateEventRequest` freezed class.
class CreateEvent extends UseCase<Event, Map<String, dynamic>> {
  final EventRepository repo;
  const CreateEvent(this.repo);

  @override
  Future<Either<Failure, Event>> call(Map<String, dynamic> body) =>
      repo.createEvent(body);
}
