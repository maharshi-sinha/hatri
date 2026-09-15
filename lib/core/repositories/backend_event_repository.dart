import 'package:flutter/foundation.dart';

import '../../backend/services/events_service.dart';
import '../models/models.dart';
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
  Future<List<Event>> getEvents() async {
    try {
      final list = await _events.getFeed(citySlug: 'raipur');
      if (list.isEmpty) {
        // Server returned nothing (or all events already passed). Still
        // give the user something to browse.
        debugPrint('BackendEventRepository: empty feed, using mock');
        return await _fallback.getEvents();
      }
      return list;
    } catch (e) {
      debugPrint('BackendEventRepository: fallback to mock ($e)');
      return _fallback.getEvents();
    }
  }
}
