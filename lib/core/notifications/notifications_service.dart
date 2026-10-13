import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../backend/api/http_client.dart';
import '../../backend/services/auth_service.dart';
import '../../backend/services/events_service.dart';
import '../../features/events/event_details_screen.dart';
import '../analytics/analytics_service.dart';
import '../di/injection_container.dart';
import '../routing/app_router.dart';
import 'notifications_store.dart';

/// Push notifications wrapper.
///
/// Keeps three things in sync:
///   1. FCM token on backend (via POST /devices after sign-in, DELETE on sign-out)
///   2. Android notification channel with the custom hatri_notif sound
///   3. Foreground + taps: foreground shows a local notification with our
///      sound, taps resolve `event_id` in the payload to EventDetailsScreen
///      on the root navigator.
///
/// iOS APNs is deferred until Apple Developer Program enrollment.
class NotificationsService {
  NotificationsService();

  static const _channelId = 'hatri_default';
  static const _channelName = 'Hatri';
  static const _channelDescription =
      'Event confirmations, reminders, and makers you follow.';

  final _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  String? _lastTokenSynced;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Permission is asked by NotificationPermissionScreen in onboarding via
      // permission_handler. We deliberately do NOT prompt here so the OS
      // dialog doesn't fire on cold start before the user sees context.

      // Android: register the channel with our custom sound. iOS reads sound
      // per-notification from the payload instead of channels, so this
      // branch is Android-only in effect.
      await _local.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (response) =>
            _handleTap(response.payload),
      );

      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.high,
              sound: RawResourceAndroidNotificationSound('hatri_notif'),
              playSound: true,
            ),
          );

      // Foreground messages — FCM doesn't render these automatically on
      // Android, so we hand them to flutter_local_notifications with our
      // channel so the sound plays and the deep-link payload is preserved.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Taps from background / terminated.
      FirebaseMessaging.onMessageOpenedApp.listen(_onTapFromFcm);
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _onTapFromFcm(initial);

      // Token refresh — rotate silently.
      FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        _lastTokenSynced = null;
        unawaited(syncToken());
      });
    } catch (e, s) {
      debugPrint('NotificationsService init failed: $e\n$s');
    }
  }

  /// Push the current FCM token to backend. Call after sign-in and on refresh.
  /// No-op if the user isn't signed in or the token hasn't changed.
  Future<void> syncToken() async {
    if (!sl<AuthService>().isSignedIn) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;
    if (token == _lastTokenSynced) return;
    try {
      await sl<HttpClient>().dio.post<Map<String, dynamic>>(
            '/api/v1/devices',
            data: {
              'fcmToken': token,
              'platform': Platform.isIOS ? 'IOS' : 'ANDROID',
            },
          );
      _lastTokenSynced = token;
      debugPrint('fcm token synced to backend');
    } on DioException catch (e) {
      debugPrint('fcm token sync failed: ${e.message}');
    }
  }

  /// Call on sign-out so this device stops receiving pushes for the previous
  /// user. Best-effort — a failure here shouldn't block sign-out.
  Future<void> deleteToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await sl<HttpClient>().dio.delete<Map<String, dynamic>>(
              '/api/v1/devices',
              data: {'fcmToken': token},
            );
      }
      await FirebaseMessaging.instance.deleteToken();
      _lastTokenSynced = null;
    } catch (e) {
      debugPrint('fcm token delete failed: $e');
    }
  }

  // ─── Foreground + taps ───────────────────────────────────────────────

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    unawaited(
      sl<AnalyticsService>()
          ._trackPush('received', message.data),
    );

    // Mirror into the in-app inbox so the bell + Notifications screen stay in
    // sync with what the OS tray shows. Done for every FCM arrival, not just
    // the ones that produce a system notification, so data-only pushes still
    // show up in the inbox.
    _mirrorToStore(message);

    final notif = message.notification;
    if (notif == null) return;
    // Mint a stable id so Android dedupes if the same push arrives twice.
    final id = message.messageId.hashCode;
    await _local.show(
      id,
      notif.title ?? 'Hatri',
      notif.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('hatri_notif'),
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          sound: 'hatri_notif.caf',
        ),
      ),
      payload: _encodePayload(message.data),
    );
  }

  void _onTapFromFcm(RemoteMessage message) {
    unawaited(
      sl<AnalyticsService>()._trackPush('opened', message.data),
    );
    _handleTap(_encodePayload(message.data));
  }

  /// Payload format we encode is "k1=v1&k2=v2". Keeps it simple and avoids a
  /// JSON parse on cold start.
  String? _encodePayload(Map<String, dynamic> data) {
    if (data.isEmpty) return null;
    return data.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }

  Map<String, String> _decodePayload(String payload) {
    final out = <String, String>{};
    for (final pair in payload.split('&')) {
      final i = pair.indexOf('=');
      if (i <= 0) continue;
      out[pair.substring(0, i)] = Uri.decodeComponent(pair.substring(i + 1));
    }
    return out;
  }

  Future<void> _handleTap(String? payload) async {
    if (payload == null) return;
    final data = _decodePayload(payload);
    final eventId = data['eventId'];
    if (eventId == null || eventId.isEmpty) return;
    await openEventById(eventId);
  }

  /// Resolve an event id and push its details screen on the root navigator.
  /// Shared between FCM system-tray taps and in-app notifications-list taps.
  Future<void> openEventById(String eventId) async {
    final nav = rootNavigatorKey.currentState;
    if (nav == null) {
      // Navigator not mounted yet — try again on next frame.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => openEventById(eventId));
      return;
    }
    try {
      final event = await sl<EventsService>().getById(eventId);
      await nav.push(
        MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
      );
    } catch (e) {
      debugPrint('push tap resolve failed for event $eventId: $e');
    }
  }

  /// Converts an incoming FCM message into a [HatriNotification] and pushes
  /// it onto [NotificationsStore]. The `type` field in the FCM data payload
  /// picks the icon/accent on the inbox card.
  void _mirrorToStore(RemoteMessage message) {
    final data = message.data;
    final notif = message.notification;
    final title =
        notif?.title ?? data['title']?.toString() ?? 'Hatri';
    final body = notif?.body ?? data['body']?.toString() ?? '';
    final id = message.messageId ??
        'push-${DateTime.now().microsecondsSinceEpoch}';
    final eventId = data['eventId']?.toString();
    final type = data['type']?.toString();
    NotificationsStore.instance.push(
      HatriNotification(
        id: id,
        kind: _kindForType(type),
        title: title,
        subtitle: body,
        timestamp: DateTime.now(),
        deepLinkEventId: (eventId != null && eventId.isNotEmpty) ? eventId : null,
      ),
    );
  }

  HatriNotificationKind _kindForType(String? type) {
    switch (type) {
      case 'ticket_confirmed':
        return HatriNotificationKind.ticketSuccess;
      case 'ticket_failed':
        return HatriNotificationKind.ticketFailed;
      case 'event_reminder':
        return HatriNotificationKind.eventReminder;
      case 'scene_update':
        return HatriNotificationKind.sceneUpdate;
      default:
        return HatriNotificationKind.systemInfo;
    }
  }
}

/// Private extension to keep push events out of AnalyticsService's public
/// surface. We just want `push_received` / `push_opened` to show up in
/// Mixpanel alongside the rest without widening the typed API.
extension on AnalyticsService {
  Future<void> _trackPush(String action, Map<String, dynamic> data) async {
    try {
      final props = <String, Object>{'action': action};
      final eventId = data['eventId'];
      if (eventId is String && eventId.isNotEmpty) {
        props['event_id'] = eventId;
      }
      final type = data['type'];
      if (type is String && type.isNotEmpty) {
        props['push_type'] = type;
      }
      // Reuse the typed deeplinkReceived channel's shape — a lightweight
      // generic hop isn't worth adding to AnalyticsService for one caller.
      await deeplinkReceived(uri: 'push:$action');
      debugPrint('[analytics] push_$action $props');
    } catch (_) {}
  }
}
