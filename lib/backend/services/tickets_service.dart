import '../api/tickets_api.dart';
import '../models/ticket_models.dart';

/// Thin wrapper around [TicketsApi]. Tickets are user-scoped + always want
/// the freshest state — no caching layer.
class TicketsService {
  final TicketsApi _api;
  TicketsService({required TicketsApi api}) : _api = api;

  Future<ApiTicket> rsvp(String eventId) => _api.rsvp(eventId);
  Future<void> cancel(String eventId) => _api.cancel(eventId);
  Future<ApiTicket?> myTicketFor(String eventId) => _api.myTicketForEvent(eventId);
  Future<List<ApiTicket>> myTickets() => _api.listMine();
}
