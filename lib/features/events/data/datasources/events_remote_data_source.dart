import 'dart:io';

import '../../../../backend/services/events_service.dart';
import '../../../../core/models/models.dart';
import '../../../../core/repositories/event_feed_page.dart';

/// Thin seam between the domain layer and whichever concrete transport is
/// talking to the backend. Mirrors the old [EventsService] surface
/// one-to-one so the first swap is behavior-neutral.
///
/// Impl throws typed exceptions from `core/error/exceptions.dart` on
/// failure. The repository catches them and emits `Failure`s.
abstract class EventsRemoteDataSource {
  Future<EventFeedPage> getFeedPage({
    String? citySlug,
    String? category,
    String? cursor,
    int limit,
  });

  Future<List<Event>> search({
    required String query,
    String? citySlug,
    int limit,
  });

  Future<Event> getById(String id);
  Future<Event> getBySlug(String slug);

  Future<int> save(String id);
  Future<int> unsave(String id);
  Future<bool> react(String id, String reaction);
  Future<int> share(String id);

  Future<String> uploadCover(File file);
  Future<Event> createEvent(Map<String, dynamic> body);
}

/// Concrete datasource that delegates to the existing [EventsService]. In
/// PR #2 this is intentionally a passthrough so no behavior changes. A
/// later PR will inline the service logic here and retire the old service.
class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final EventsService _service;
  const EventsRemoteDataSourceImpl(this._service);

  @override
  Future<EventFeedPage> getFeedPage({
    String? citySlug,
    String? category,
    String? cursor,
    int limit = 20,
  }) =>
      _service.getFeedPage(
        citySlug: citySlug,
        category: category,
        cursor: cursor,
        limit: limit,
      );

  @override
  Future<List<Event>> search({
    required String query,
    String? citySlug,
    int limit = 30,
  }) =>
      _service.search(query: query, citySlug: citySlug, limit: limit);

  @override
  Future<Event> getById(String id) => _service.getById(id);

  @override
  Future<Event> getBySlug(String slug) => _service.getBySlug(slug);

  @override
  Future<int> save(String id) => _service.save(id);

  @override
  Future<int> unsave(String id) => _service.unsave(id);

  @override
  Future<bool> react(String id, String reaction) => _service.react(id, reaction);

  @override
  Future<int> share(String id) => _service.share(id);

  @override
  Future<String> uploadCover(File file) => _service.uploadCover(file);

  @override
  Future<Event> createEvent(Map<String, dynamic> body) =>
      _service.createEvent(body);
}
