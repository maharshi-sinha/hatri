import '../../../../backend/models/ticket_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/ticket_repository.dart';

class RsvpEvent extends UseCase<ApiTicket, String> {
  final TicketRepository repo;
  const RsvpEvent(this.repo);

  @override
  Future<Either<Failure, ApiTicket>> call(String eventId) =>
      repo.rsvp(eventId);
}

class CancelRsvp extends UseCase<void, String> {
  final TicketRepository repo;
  const CancelRsvp(this.repo);

  @override
  Future<Either<Failure, void>> call(String eventId) =>
      repo.cancel(eventId);
}
