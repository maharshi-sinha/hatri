import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/analytics/analytics_service.dart';
import 'core/auth/user_sync.dart';
import 'core/deeplinks/deeplink_handler.dart';
import 'core/geo/city_resolver.dart';
import 'core/notifications/notifications_service.dart';
import 'core/di/injection_container.dart' as di;
import 'core/responsive/responsive.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/communities/bloc/communities_bloc.dart';
import 'features/communities/bloc/communities_event.dart';
import 'features/events/bloc/events_bloc.dart';
import 'features/events/bloc/events_event.dart';
import 'firebase_options.dart';
import 'flavors.dart';
import 'shared/widgets/connection_gate.dart';

// Flavor is injected at build time via --dart-define=appFlavor=dev|prod.
// If nothing is passed we default to prod so plain `flutter run` still works.
const String _appFlavorEnv =
    String.fromEnvironment('appFlavor', defaultValue: 'prod');

void main() async {
  // runZonedGuarded catches async errors that FlutterError.onError misses
  // (futures with no .catchError, timers, etc.) and funnels them to
  // Crashlytics. Everything that touches Firebase must live inside the zone.
  await runZonedGuarded<Future<void>>(() async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    // Seed the scale before the first frame so sizing read ahead of the first
    // MediaQuery is already correct.
    AppScale.updateFromView(binding.platformDispatcher.views.first);
    F.appFlavor = Flavor.values.firstWhere(
      (e) => e.name == _appFlavorEnv,
      orElse: () => Flavor.prod,
    );

    // Firebase.initializeApp can hang on a flaky network at cold start AND
    // the Crashlytics native component can be stripped by R8 on a bad
    // release build, both of which previously froze the splash. Every
    // Firebase-touching call below is guarded so a single-step failure
    // can't block runApp.
    bool firebaseUp = false;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 6));
      firebaseUp = true;
    } catch (e) {
      debugPrint('Firebase.initializeApp failed or timed out: $e');
    }

    // Wire crash reporting only if Firebase is actually up. When it isn't,
    // we lose remote crash capture for this session but the app still
    // boots — a far better failure mode than a frozen splash.
    if (firebaseUp) {
      try {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = (details) {
          FirebaseCrashlytics.instance.recordFlutterError(details);
        };
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } catch (e) {
        debugPrint('Crashlytics setup failed: $e');
      }
    }

    di.init();
    // bootAuth touches secure storage AND may fire a /auth/refresh HTTP call
    // if the access token is expired. If the API is slow (Render cold start,
    // flaky network) and there's no timeout, main() can hang here forever
    // and runApp() never fires — the user sees the native launch screen
    // frozen. Cap the wait and move on; init will route to the sign-in
    // flow by default if auth state is still unresolved.
    try {
      await di.bootAuth().timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('bootAuth failed or timed out: $e');
    }
    // Mirror the restored ApiUser into the mock-era `currentUser` global
    // so the profile tab shows real data instead of the AAROHI placeholder.
    installUserSync();
    // Fire-and-forget: analytics init shouldn't delay first paint.
    unawaited(di.sl<AnalyticsService>().init());
    // Catch-up for accounts created before the geo flow existed: silently
    // resolve the nearest active city if we have location permission and
    // the backend hasn't got one on file yet. Never blocks boot.
    unawaited(di.sl<GeoCityResolver>().tryResolveSilently());
    // Register FCM channel + listeners. If a user is already signed in from a
    // previous session, also push a fresh token up to backend.
    unawaited(() async {
      await di.sl<NotificationsService>().init();
      await di.sl<NotificationsService>().syncToken();
    }());

    runApp(const HatriApp());

    // After the first frame so the navigator is mounted. Owns itself for the
    // lifetime of the process — the handler listens to the AppLinks URI stream
    // forever and never needs disposal in a running app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeeplinkHandler(rootNavigatorKey: rootNavigatorKey).start();
    });
  }, (error, stack) {
    // Guard: Firebase may have failed to init (see firebaseUp above). If so,
    // just log and swallow; without this guard the error-handler itself
    // throws and the zoned future never completes.
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (_) {
      debugPrint('Uncaught error (crashlytics unavailable): $error\n$stack');
    }
  });
}

class HatriApp extends StatelessWidget {
  const HatriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventsBloc>(
          create: (context) => di.sl<EventsBloc>()..add(LoadEvents()),
        ),
        BlocProvider<CommunitiesBloc>(
          create: (context) => di.sl<CommunitiesBloc>()..add(LoadCommunities()),
        ),
      ],
      child: MaterialApp.router(
        title: F.title,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // ConnectionGate overlays OfflineScreen whenever the device drops
          // its network connection, and stays out of the way otherwise.
          final shell = ConnectionGate(child: _ResponsiveShell(child: child));
          if (F.appFlavor == Flavor.dev) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Banner(
                location: BannerLocation.topEnd,
                message: 'DEV',
                color: AppColors.fuchsia,
                textStyle: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: AppColors.paper,
                ),
                child: shell,
              ),
            );
          }
          return shell;
        },
      ),
    );
  }
}

/// Applies the three device-adaptation rules to every route:
/// keeps [AppScale] in sync with the current window, bounds the OS text-size
/// setting, and stops the phone layout from stretching across a tablet.
class _ResponsiveShell extends StatelessWidget {
  const _ResponsiveShell({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    AppScale.update(media.size);

    Widget content = child ?? const SizedBox.shrink();

    if (media.size.width > kMaxContentWidth) {
      content = Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: kMaxContentWidth, child: content),
      );
    }

    // The OS font-size slider (Samsung One UI goes well past 1.3x) otherwise
    // inflates every fixed-height row in the app until it overflows.
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.15,
      child: content,
    );
  }
}
