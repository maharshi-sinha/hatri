import 'package:get_it/get_it.dart';

import '../../backend/services/tickets_service.dart';
import 'data/datasources/tickets_remote_data_source.dart';
import 'data/repositories/ticket_repository_impl.dart';
import 'domain/repositories/ticket_repository.dart';
import 'domain/usecases/get_my_tickets.dart';
import 'domain/usecases/rsvp_event.dart';

void registerTicketsFeature(GetIt sl) {
  sl.registerLazySingleton<TicketsRemoteDataSource>(
    () => TicketsRemoteDataSourceImpl(sl<TicketsService>()),
  );
  sl.registerLazySingleton<TicketRepository>(
    () => TicketRepositoryImpl(sl<TicketsRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => RsvpEvent(sl<TicketRepository>()));
  sl.registerLazySingleton(() => CancelRsvp(sl<TicketRepository>()));
  sl.registerLazySingleton(() => GetMyTickets(sl<TicketRepository>()));
  sl.registerLazySingleton(() => GetMyTicketFor(sl<TicketRepository>()));
}
