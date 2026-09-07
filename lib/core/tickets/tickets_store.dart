import 'package:flutter/foundation.dart';

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
}
