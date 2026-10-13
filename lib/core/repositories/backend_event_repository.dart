import 'package:flutter/foundation.dart';

import '../../backend/services/events_service.dart';
import 'event_feed_page.dart';
import 'event_repository.dart';
import 'mock_repository.dart';

/// Real-backend implementation of [EventRepository].
///
/// [EventsService] already tries API → cache. This class adds one more
/// step: if BOTH fail (e.g. first run offline, no cache yet), we fall back
/// to the hardcoded mock fixture so the app never renders an empty feed.
///
/// This matches the rule in `lib/backend/README.md`:
/// "Hatri is a magazine you flip through. It should never show 'Error 500'."
class BackendEventRepository implements EventRepository {
  final EventsService _events;
  final MockEventRepository _fallback;

  BackendEventRepository({
    required EventsService events,
    MockEventRepository? fallback,
  })  : _events = events,
        _fallback = fallback ?? MockEventRepository();

  @override
  Future<EventFeedPage> getEvents({String? cursor}) async {
    try {
      final page = await _events.getFeedPage(citySlug: 'raipur', cursor: cursor);
      if (cursor == null && page.events.isEmpty) {
        // First page empty: server has literally nothing. Fall back to the
        // mock so the user never sees an empty feed. For load-more pages
        // we respect the empty result (reached the real end).
        debugPrint('BackendEventRepository: empty first page, using mock');
        return await _fallback.getEvents();
      }
      return page;
    } catch (e) {
      debugPrint('BackendEventRepository: fallback to mock ($e)');
      // Only fall back on the FIRST page. For load-more, surface the error
      // so the UI can show a retry affordance instead of silently stuffing
      // mock events into the middle of real ones.
      if (cursor == null) return _fallback.getEvents();
      rethrow;
    }
  }
}
