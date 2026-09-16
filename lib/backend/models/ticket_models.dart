enum TicketStatus { confirmed, pendingPayment, cancelled }

TicketStatus _parseStatus(String raw) {
  switch (raw) {
    case 'CONFIRMED':
      return TicketStatus.confirmed;
    case 'PENDING_PAYMENT':
      return TicketStatus.pendingPayment;
    case 'CANCELLED':
      return TicketStatus.cancelled;
    default:
      return TicketStatus.cancelled;
  }
}

class ApiTicket {
  final String id;
  final String eventId;
  final String eventTitle;
  final DateTime eventStartAt;
  final TicketStatus status;
  final String qrCode;
  final DateTime claimedAt;
  final DateTime? cancelledAt;

  const ApiTicket({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventStartAt,
    required this.status,
    required this.qrCode,
    required this.claimedAt,
    required this.cancelledAt,
  });

  factory ApiTicket.fromJson(Map<String, dynamic> json) => ApiTicket(
        id: json['id'] as String,
        eventId: json['eventId'] as String,
        eventTitle: json['eventTitle'] as String,
        eventStartAt: DateTime.parse(json['eventStartAt'] as String),
        status: _parseStatus(json['status'] as String),
        qrCode: json['qrCode'] as String,
        claimedAt: DateTime.parse(json['claimedAt'] as String),
        cancelledAt: json['cancelledAt'] == null
            ? null
            : DateTime.parse(json['cancelledAt'] as String),
      );
}
