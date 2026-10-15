import '../../../../backend/models/ticket_models.dart';
import '../../../../backend/services/tickets_service.dart';

abstract class TicketsRemoteDataSource {
  Future<ApiTicket> rsvp(String eventId);
  Future<void> cancel(String eventId);
  Future<ApiTicket?> myTicketFor(String eventId);
  Future<List<ApiTicket>> myTickets();
}

class TicketsRemoteDataSourceImpl implements TicketsRemoteDataSource {
  final TicketsService _service;
  const TicketsRemoteDataSourceImpl(this._service);

  @override
  Future<ApiTicket> rsvp(String eventId) => _service.rsvp(eventId);

  @override
  Future<void> cancel(String eventId) => _service.cancel(eventId);

  @override
  Future<ApiTicket?> myTicketFor(String eventId) =>
      _service.myTicketFor(eventId);

  @override
  Future<List<ApiTicket>> myTickets() => _service.myTickets();
}
