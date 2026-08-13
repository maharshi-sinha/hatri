import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/responsive/responsive.dart';
import 'core/routing/app_router.dart';
import 'features/events/bloc/events_bloc.dart';
import 'features/events/bloc/events_event.dart';
import 'features/communities/bloc/communities_bloc.dart';
import 'features/communities/bloc/communities_event.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Seed the scale before the first frame so sizing read ahead of the first
  // MediaQuery is already correct.
  AppScale.updateFromView(binding.platformDispatcher.views.first);
  di.init();
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
        title: 'Hatri',
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,

        
        debugShowCheckedModeBanner: false,
        builder: (context, child) => _ResponsiveShell(child: child),
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


