import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/models.dart';
import '../../core/repositories/event_feed_page.dart';
import '../api/event_mapper.dart';
import '../api/events_api.dart';
import '../models/event_models.dart';

/// Tiered fallback wrapper around EventsApi.
///
/// - Success: return the fresh feed + cache the raw response to disk.
/// - Network failure: return the last cached response.
/// - No cache: caller falls through to the mock repository.
///
/// Matches the rule in [lib/backend/README.md]: the magazine should never
/// show "Error 500"; it always renders SOMETHING.
class EventsService {
  final EventsApi _api;

  static const _feedCacheKey = 'hatri.events.feed.v1';

  EventsService({required EventsApi api}) : _api = api;

  /// Flat getter kept for legacy callers (home + this-week screens) that
  /// don't paginate. Just unwraps the first page.
  Future<List<Event>> getFeed({
    String? citySlug,
    String? category,
    int limit = 40,
  }) async {
    final page = await getFeedPage(
      citySlug: citySlug,
      category: category,
      limit: limit,
    );
    return page.events;
  }

  /// Paginated feed. Pass the previous page's `nextCursor` as `cursor` to
  /// load the next page. First call: cursor=null.
  ///
  /// Caching: we only snapshot the FIRST page (cursor==null) so a cold
  /// offline open still has something to render. Deeper pages aren't
  /// cached since they're only visible after scrolling and aren't worth
  /// the storage churn.
  Future<EventFeedPage> getFeedPage({
    String? citySlug,
    String? category,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final feed = await _api.list(
        citySlug: citySlug,
        category: category,
        limit: limit,
        cursor: cursor,
      );
      if (cursor == null) {
        unawaited(_saveCache(feed));
      }
      return EventFeedPage(
        events: feed.items.map(EventMapper.fromCard).toList(),
        nextCursor: feed.nextCursor,
      );
    } catch (e) {
      debugPrint('EventsService.getFeedPage API failed: $e');
      // Only fall back to cache on the first page. For load-more, let the
      // caller surface a retry affordance; we don't want to splice cached
      // first-page items into a load-more response.
      if (cursor == null) {
        final cached = await _loadCache();
        if (cached != null && cached.items.isNotEmpty) {
          return EventFeedPage(
            events: cached.items.map(EventMapper.fromCard).toList(),
            nextCursor: cached.nextCursor,
          );
        }
      }
      rethrow;
    }
  }

  /// Server-side search over the events discovery feed. Case-insensitive
  /// match against title / venue / address. Returns an empty list on empty
  /// query. No caching: search is live and specific per-keystroke.
  Future<List<Event>> search({
    required String query,
    String? citySlug,
    int limit = 30,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    try {
      final feed = await _api.list(
        citySlug: citySlug,
        q: q,
        limit: limit,
      );
      return feed.items.map(EventMapper.fromCard).toList();
    } catch (e) {
      debugPrint('EventsService.search failed: $e');
      return const [];
    }
  }

  /// Fetch full event detail. No cache — detail views are rare and always
  /// want the freshest counts.
  Future<Event> getById(String id) async {
    final detail = await _api.getById(id);
    return EventMapper.fromDetail(detail);
  }

  /// Slug-keyed fetch. Used by the deeplink handler when the app opens via
  /// `hatri://event/<slug>` or a Universal Link.
  Future<Event> getBySlug(String slug) async {
    final detail = await _api.getBySlug(slug);
    return EventMapper.fromDetail(detail);
  }

  Future<int> save(String id) async {
    final res = await _api.save(id);
    return res.saves;
  }

  Future<int> unsave(String id) async {
    final res = await _api.unsave(id);
    return res.saves;
  }

  Future<bool> react(String id, String reaction) async {
    final res = await _api.react(id, reaction);
    return res.reacted;
  }

  Future<int> share(String id) async {
    final res = await _api.share(id);
    return res.shares;
  }

  /// Uploads a cover image to backend storage and returns the public URL
  /// to pass as `coverUrl` on [createEvent].
  Future<String> uploadCover(File file) => _api.uploadCover(file);

  /// Creates an event owned by the current signed-in user and returns the
  /// UI-ready model. Caller is responsible for navigating to the new event's
  /// detail screen.
  Future<Event> createEvent(Map<String, dynamic> body) async {
    final detail = await _api.create(body);
    return EventMapper.fromDetail(detail);
  }

  // ─── Cache ───

  Future<void> _saveCache(ApiEventFeed feed) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final json = jsonEncode({
        'items': feed.items.map((e) => e.toJson()).toList(),
      });
      await sp.setString(_feedCacheKey, json);
    } catch (e) {
      // Best-effort; never let cache failures break the feed.
      debugPrint('EventsService cache save failed: $e');
    }
  }

  Future<ApiEventFeed?> _loadCache() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_feedCacheKey);
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return ApiEventFeed(
        items: (decoded['items'] as List<dynamic>)
            .map((e) => ApiEventCard.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextCursor: null,
      );
    } catch (e) {
      debugPrint('EventsService cache load failed: $e');
      return null;
    }
  }
}
