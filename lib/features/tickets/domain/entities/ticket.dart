/// Tickets domain entity barrel. ApiTicket is the DTO Nest returns and
/// stands in as the entity for now. A later PR introduces a plain
/// `Ticket` entity and ApiTicket becomes a data-layer DTO with a
/// mapper.
library;

export '../../../../backend/models/ticket_models.dart';
