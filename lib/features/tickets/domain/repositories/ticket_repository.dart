import '../../../../backend/models/ticket_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';

/// Clean-arch contract for the Tickets feature. All methods return
/// `Either<Failure, T>` so the UI deals with typed outcomes rather
/// than ApiException throws.
abstract class TicketRepository {
  /// Claim a ticket for the given event.
  Future<Either<Failure, ApiTicket>> rsvp(String eventId);

  /// Cancel the current user's ticket for the given event.
  Future<Either<Failure, void>> cancel(String eventId);

  /// The current user's ticket for the given event, if any.
  Future<Either<Failure, ApiTicket?>> myTicketFor(String eventId);

  /// Every ticket the current user holds, newest first.
  Future<Either<Failure, List<ApiTicket>>> myTickets();
}
