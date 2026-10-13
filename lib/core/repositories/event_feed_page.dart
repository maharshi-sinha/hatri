import '../models/models.dart';

/// One page of events from the discovery feed. `nextCursor` is null when
/// the server has nothing more to return; UI pagination stops there.
class EventFeedPage {
  final List<Event> events;
  final String? nextCursor;

  const EventFeedPage({required this.events, required this.nextCursor});

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
