import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/responsive/responsive.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/communities/bloc/communities_bloc.dart';
import 'features/communities/bloc/communities_event.dart';
import 'features/events/bloc/events_bloc.dart';
import 'features/events/bloc/events_event.dart';
import 'flavors.dart';
import 'shared/widgets/connection_gate.dart';

// Flavor is injected at build time via --dart-define=appFlavor=dev|prod.
// If nothing is passed we default to prod so plain `flutter run` still works.
const String _appFlavorEnv =
    String.fromEnvironment('appFlavor', defaultValue: 'prod');

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Seed the scale before the first frame so sizing read ahead of the first
  // MediaQuery is already correct.
  AppScale.updateFromView(binding.platformDispatcher.views.first);
  F.appFlavor = Flavor.values.firstWhere(
    (e) => e.name == _appFlavorEnv,
    orElse: () => Flavor.prod,
  );
  di.init();
  await di.bootAuth();
  runApp(const HatriApp());
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
