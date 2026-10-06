import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/models.dart';
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

  /// Fetch the discovery feed. Returns UI-ready [Event]s.
  /// Throws only when both API and cache are empty — caller handles fallback.
  Future<List<Event>> getFeed({
    String? citySlug,
    String? category,
    int limit = 40,
  }) async {
    try {
      final feed = await _api.list(
        citySlug: citySlug,
        category: category,
        limit: limit,
      );
      // Cache the raw API response so we can rebuild the exact same list
      // even if the domain-model shape changes between releases.
      unawaited(_saveCache(feed));
      return feed.items.map(EventMapper.fromCard).toList();
    } catch (e) {
      debugPrint('EventsService.getFeed API failed: $e — trying cache');
      final cached = await _loadCache();
      if (cached != null && cached.items.isNotEmpty) {
        return cached.items.map(EventMapper.fromCard).toList();
      }
      rethrow;
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
