import 'package:flutter/foundation.dart';

/// The kinds of notifications Hatri surfaces to a user through the bell.
enum HatriNotificationKind {
  ticketSuccess,
  ticketFailed,
  eventReminder,
  sceneUpdate,
  systemInfo,
}

/// One entry in the notifications inbox.
@immutable
class HatriNotification {
  final String id;
  final HatriNotificationKind kind;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool unread;
  final String? deepLinkEventId;

  const HatriNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.unread = true,
    this.deepLinkEventId,
  });

  HatriNotification copyWith({bool? unread}) => HatriNotification(
        id: id,
        kind: kind,
        title: title,
        subtitle: subtitle,
        timestamp: timestamp,
        unread: unread ?? this.unread,
        deepLinkEventId: deepLinkEventId,
      );
}

/// In-memory singleton store. Real backend not needed for the prototype.
/// Extends ChangeNotifier so the bell + notifications screen react to updates.
class NotificationsStore extends ChangeNotifier {
  NotificationsStore._();
  static final NotificationsStore instance = NotificationsStore._();

  final List<HatriNotification> _items = [];

  List<HatriNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => n.unread).length;
  bool get hasUnread => unreadCount > 0;

  void push(HatriNotification n) {
    _items.insert(0, n);
    notifyListeners();
  }

  void markAllRead() {
    if (_items.every((n) => !n.unread)) return;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].unread) _items[i] = _items[i].copyWith(unread: false);
    }
    notifyListeners();
  }

  void markRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i == -1 || !_items[i].unread) return;
    _items[i] = _items[i].copyWith(unread: false);
    notifyListeners();
  }

  void remove(String id) {
    final before = _items.length;
    _items.removeWhere((n) => n.id == id);
    if (_items.length != before) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
