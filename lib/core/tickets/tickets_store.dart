import 'package:flutter/foundation.dart';

import '../../backend/models/ticket_models.dart';
import '../models/models.dart';

/// A single saved ticket record. Holds the reference number, the event it's
/// tied to, and (for paid events) the tier + quantity that was purchased.
@immutable
class SavedTicket {
  final String id;
  final String ref;
  final Event event;
  final TicketTier? tier;
  final int quantity;
  final DateTime purchasedAt;

  const SavedTicket({
    required this.id,
    required this.ref,
    required this.event,
    this.tier,
    this.quantity = 1,
    required this.purchasedAt,
  });

  bool get isUpcoming => event.date.isAfter(DateTime.now().subtract(const Duration(hours: 6)));
  bool get isPast => !isUpcoming;
  bool get isFree => tier == null;
  int get total => (tier?.priceRupees ?? 0) * quantity;
}

/// In-memory ticket wallet. Same pattern as [NotificationsStore] — persists
/// across navigation, not across app kill (real product wires a backend).
class TicketsStore extends ChangeNotifier {
  TicketsStore._();
  static final TicketsStore instance = TicketsStore._();

  final List<SavedTicket> _items = [];

  List<SavedTicket> get items {
    final sorted = [..._items];
    sorted.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return List.unmodifiable(sorted);
  }

  List<SavedTicket> get upcoming =>
      items.where((t) => t.isUpcoming).toList();

  List<SavedTicket> get past => items.where((t) => t.isPast).toList();

  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;

  void push(SavedTicket ticket) {
    _items.insert(0, ticket);
    notifyListeners();
  }

  void remove(String id) {
    final before = _items.length;
    _items.removeWhere((t) => t.id == id);
    if (_items.length != before) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  /// Replace the store contents with the list of tickets the backend
  /// returned. Converts each [ApiTicket] into a [SavedTicket] using a
  /// minimal [Event] stub built from the API fields that are present
  /// (id, title, startAt). The My Tickets screen only renders a card
  /// per ticket, so the sparse Event is enough for display; tapping a
  /// ticket's reveal screen reads from this same shape.
  ///
  /// Any existing SavedTicket whose id matches an incoming ApiTicket is
  /// replaced. This is called after sign-in (from main.dart) and from
  /// MyTicketsScreen's initState so the wallet reflects server truth
  /// even across app kills.
  void hydrateFromApi(List<ApiTicket> apiTickets) {
    _items
      ..clear()
      ..addAll(apiTickets
          .where((t) => t.status != TicketStatus.cancelled)
          .map(_savedFromApi));
    notifyListeners();
  }

  SavedTicket _savedFromApi(ApiTicket t) {
    final start = t.eventStartAt;
    final time = _formatTime(start);
    return SavedTicket(
      id: t.id,
      ref: t.qrCode,
      event: Event(
        id: t.eventId,
        slug: t.eventSlug,
        title: t.eventTitle,
        description: '',
        coverUrl: '',
        organizer: '',
        date: start,
        time: time,
        venue: '',
        category: EventCategory.other,
        rsvpCount: 0,
      ),
      purchasedAt: t.claimedAt,
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }
}
