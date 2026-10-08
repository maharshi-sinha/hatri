import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../../flavors.dart';

/// Single surface for product analytics (Mixpanel) and crash context
/// (Crashlytics custom keys / user id). Typed events only — never let a raw
/// `track("foo", {...})` escape into feature code. If an event isn't on this
/// class yet, add it here first so the Lexicon stays discoverable.
///
/// Init order: construct → [init] (fire-and-forget from main) → [identify]
/// after the user signs in. Events fired before init are queued by Mixpanel
/// internally, so we don't block on it; worst case the first few events ship
/// in a batch once init completes.
class AnalyticsService {
  // Mixpanel project token for the "Hatri" project. This is a client-side
  // identifier, not a secret — it ships in every mobile app build.
  static const String _mixpanelToken = '06f5f11272a1cd706920b3d15a247369';

  Mixpanel? _mp;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _mp = await Mixpanel.init(
        _mixpanelToken,
        trackAutomaticEvents: false,
        optOutTrackingDefault: false,
      );
      _mp?.setLoggingEnabled(F.appFlavor == Flavor.dev);
      // Super props land on every event. Keep this list short — anything
      // that could change per-event belongs in the event payload instead.
      _mp?.registerSuperProperties({
        'app_flavor': F.appFlavor.name,
      });
      _initialized = true;
    } catch (e, s) {
      // Never let analytics init crash the app. Just report and move on.
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'AnalyticsService.init failed',
        fatal: false,
      );
    }
  }

  /// Call after sign-in with the backend user id. Mixpanel then attributes
  /// prior anonymous events to this user via alias, and Crashlytics attaches
  /// the id to every subsequent crash report.
  Future<void> identify({required String userId, String? phone}) async {
    try {
      _mp?.identify(userId);
      if (phone != null) {
        _mp?.getPeople().set(r'$phone', phone);
      }
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e, s, reason: 'identify failed', fatal: false,
      );
    }
  }

  /// Call on sign-out so a shared device doesn't bleed one user's events into
  /// the next account.
  Future<void> reset() async {
    try {
      _mp?.reset();
      await FirebaseCrashlytics.instance.setUserIdentifier('');
    } catch (_) {/* non-fatal */}
  }

  // ─── Typed events ────────────────────────────────────────────────────
  // Event names: snake_case, past tense verbs. Properties: snake_case keys,
  // primitive values only (strings, numbers, booleans). Keeps the Lexicon
  // tidy and queries predictable.

  Future<void> screenViewed(String name) =>
      _track('screen_viewed', {'screen': name});

  Future<void> signInStarted() => _track('sign_in_started');
  Future<void> otpRequested() => _track('otp_requested');
  Future<void> otpSubmitted({required bool success}) =>
      _track('otp_submitted', {'success': success});
  Future<void> signInCompleted() => _track('sign_in_completed');
  Future<void> signedOut() => _track('signed_out');

  Future<void> eventOpened({
    required String eventId,
    String? source,
  }) =>
      _track('event_opened', {'event_id': eventId, if (source != null) 'source': source});

  Future<void> eventSaved({required String eventId, required bool saved}) =>
      _track('event_saved', {'event_id': eventId, 'saved': saved});

  Future<void> eventRsvpd({required String eventId}) =>
      _track('event_rsvpd', {'event_id': eventId});

  Future<void> shareOpened({required String eventId}) =>
      _track('share_opened', {'event_id': eventId});

  Future<void> deeplinkReceived({required String uri}) =>
      _track('deeplink_received', {'uri': uri});

  Future<void> loginNudgeShown({required String reason}) =>
      _track('login_nudge_shown', {'reason': reason});

  Future<void> loginNudgeDismissed({required String reason, required bool wentToSignIn}) =>
      _track('login_nudge_dismissed', {
        'reason': reason,
        'went_to_sign_in': wentToSignIn,
      });

  Future<void> makerInquireTapped({required String makerId}) =>
      _track('maker_inquire_tapped', {'maker_id': makerId});

  // ─── Internals ───────────────────────────────────────────────────────

  Future<void> _track(String name, [Map<String, Object>? props]) async {
    try {
      _mp?.track(name, properties: props);
      if (kDebugMode) {
        debugPrint('[analytics] $name ${props ?? ''}');
      }
    } catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e, s, reason: 'track($name) failed', fatal: false,
      );
    }
  }
}
