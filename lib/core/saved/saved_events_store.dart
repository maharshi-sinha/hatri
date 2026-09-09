import 'package:flutter/foundation.dart';

/// In-memory list of event IDs the user has bookmarked / saved. Same pattern
/// as [TicketsStore] and [NotificationsStore] — swap for real backend later.
class SavedEventsStore extends ChangeNotifier {
  SavedEventsStore._();
  static final SavedEventsStore instance = SavedEventsStore._();

  final Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);
  int get count => _ids.length;
  bool isSaved(String eventId) => _ids.contains(eventId);

  void toggle(String eventId) {
    if (_ids.contains(eventId)) {
      _ids.remove(eventId);
    } else {
      _ids.add(eventId);
    }
    notifyListeners();
  }

  void save(String eventId) {
    if (_ids.add(eventId)) notifyListeners();
  }

  void unsave(String eventId) {
    if (_ids.remove(eventId)) notifyListeners();
  }

  void clear() {
    if (_ids.isEmpty) return;
    _ids.clear();
    notifyListeners();
  }
}
