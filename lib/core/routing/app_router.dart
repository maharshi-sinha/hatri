import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/main_scaffold.dart';
import '../../features/home/home_screen.dart';
import '../../features/events/events_screen.dart';
import '../../features/communities/communities_screen.dart';
import '../../features/city/city_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/interest_selection_screen.dart';
import '../../features/auth/user_details_screen.dart';
import '../../features/auth/vibes_screen.dart';
import '../../features/auth/welcome_carousel_screen.dart';
import '../../features/auth/phone_entry_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/auth/name_entry_screen.dart';
import '../../features/auth/notification_permission_screen.dart';
import '../../features/auth/location_permission_screen.dart';
import '../../features/auth/celebration_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
// Backwards-compat alias — don't use in new code.
final GlobalKey<NavigatorState> _rootNavigatorKey = rootNavigatorKey;
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  // Deeplinks like `hatri://event/<slug>` and `https://hatri.online/e/<slug>`
  // are handled by DeeplinkHandler, which pushes screens on the root
  // navigator imperatively. go_router would otherwise see them as unknown
  // paths and show its "Page Not Found" screen for a frame before our
  // handler takes over. Silently redirect those to home so there's no flash.
  redirect: (context, state) {
    final uri = state.uri;
    // Only intervene for URIs we KNOW the DeeplinkHandler owns.
    final ownedByDeeplink =
        uri.scheme == 'hatri' ||
        (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'e');
    return ownedByDeeplink ? '/' : null;
  },
  errorBuilder: (context, state) {
    // Any residual unknown route — stay silent instead of showing a 404 flash.
    return const SizedBox.shrink();
  },
  routes: [
    // Onboarding flow:
    // splash → welcome → phone → otp → name → interests → user-details (bio)
    //        → notification-permission → location-permission → celebration → /
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeCarouselScreen(),
    ),
    GoRoute(
      path: '/phone',
      builder: (context, state) => const PhoneEntryScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => OtpVerificationScreen(
        phoneMasked: state.extra as String? ?? '+91 •••••• ••••',
      ),
    ),
    GoRoute(
      path: '/name',
      builder: (context, state) => const NameEntryScreen(),
    ),
    GoRoute(
      path: '/interests',
      builder: (context, state) => const InterestSelectionScreen(),
    ),
    GoRoute(
      path: '/user-details',
      builder: (context, state) => const UserDetailsScreen(),
    ),
    GoRoute(
      path: '/vibes',
      builder: (context, state) => const VibesScreen(),
    ),
    GoRoute(
      path: '/notification-permission',
      builder: (context, state) => const NotificationPermissionScreen(),
    ),
    GoRoute(
      path: '/location-permission',
      builder: (context, state) => const LocationPermissionScreen(),
    ),
    GoRoute(
      path: '/celebration',
      builder: (context, state) => const CelebrationScreen(),
    ),

    // Legacy screens kept for now (auth-screen currently references sign-in).
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),

    // Main app shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: '/communities',
          builder: (context, state) => const CommunitiesScreen(),
        ),
        GoRoute(
          path: '/city',
          builder: (context, state) => const CityScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
