import 'event_feed_page.dart';

abstract class EventRepository {
  /// Returns one page of events. Pass the last page's `nextCursor` back as
  /// `cursor` to fetch the following page. Cursor is null on the first call.
  Future<EventFeedPage> getEvents({String? cursor});
}
