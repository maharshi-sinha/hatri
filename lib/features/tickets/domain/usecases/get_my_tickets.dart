import '../../../../backend/models/ticket_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/ticket_repository.dart';

class GetMyTickets extends UseCase<List<ApiTicket>, NoParams> {
  final TicketRepository repo;
  const GetMyTickets(this.repo);

  @override
  Future<Either<Failure, List<ApiTicket>>> call(NoParams _) =>
      repo.myTickets();
}

class GetMyTicketFor extends UseCase<ApiTicket?, String> {
  final TicketRepository repo;
  const GetMyTicketFor(this.repo);

  @override
  Future<Either<Failure, ApiTicket?>> call(String eventId) =>
      repo.myTicketFor(eventId);
}
