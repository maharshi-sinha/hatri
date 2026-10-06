import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../backend/services/events_service.dart';
import '../../features/events/event_details_screen.dart';
import '../di/injection_container.dart';

/// Captures incoming URIs delivered to the app and routes them to the right
/// screen. Supports two surfaces:
///
///   * `hatri://event/<slug>`                  — custom scheme (F3b)
///   * `https://hatri.online/e/<slug>`          — Universal / App Links (F3c)
///
/// Resolution path for an event URI: hit the backend's `by-slug` endpoint,
/// resolve to a full [Event], then push the standard [EventDetailsScreen].
/// A broken slug or network failure stays silent — the user just lands
/// wherever they were, no crash, no error toast.
class DeeplinkHandler {
  DeeplinkHandler({
    required GlobalKey<NavigatorState> rootNavigatorKey,
    AppLinks? appLinks,
    EventsService? events,
  })  : _rootNavigatorKey = rootNavigatorKey,
        _appLinks = appLinks ?? AppLinks(),
        _events = events ?? sl<EventsService>();

  final GlobalKey<NavigatorState> _rootNavigatorKey;
  final AppLinks _appLinks;
  final EventsService _events;

  StreamSubscription<Uri>? _sub;

  /// Call once after the first frame — the navigator must be mounted so we
  /// can push onto it.
  Future<void> start() async {
    // The URI the app was COLD-STARTED with (null on a normal launch).
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        unawaited(_handle(initial));
      }
    } catch (e) {
      debugPrint('DeeplinkHandler.getInitialLink failed: $e');
    }

    // All subsequent URIs delivered while the app is already running.
    _sub = _appLinks.uriLinkStream.listen(
      _handle,
      onError: (Object e) => debugPrint('DeeplinkHandler stream error: $e'),
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _handle(Uri uri) async {
    debugPrint('DeeplinkHandler: received $uri');
    final slug = _extractEventSlug(uri);
    if (slug == null) return;

    final nav = _rootNavigatorKey.currentState;
    if (nav == null) {
      // Navigator not mounted yet — this happens exactly once on cold-start.
      // Retry on the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _handle(uri));
      return;
    }

    try {
      final event = await _events.getBySlug(slug);
      await nav.push(
        MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
      );
    } catch (e) {
      debugPrint('DeeplinkHandler: could not resolve $slug: $e');
    }
  }

  /// Pulls the slug out of either URI shape:
  ///   hatri://event/<slug>
  ///   https://hatri.online/e/<slug>
  String? _extractEventSlug(Uri uri) {
    // Custom scheme: hatri://event/<slug>
    if (uri.scheme == 'hatri' && uri.host == 'event') {
      final segs = uri.pathSegments;
      if (segs.isNotEmpty) return segs.first;
      return null;
    }
    // Universal link: https://hatri.online/e/<slug>
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        (uri.host == 'hatri.online' || uri.host == 'www.hatri.online') &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'e') {
      return uri.pathSegments[1];
    }
    return null;
  }
}
