import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../backend/services/auth_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';

/// Splash — plays an intro video with sound, no controls, then routes
/// to home if the user is signed in or /welcome otherwise. Auth state is
/// already resolved by the time this screen runs because main.dart awaits
/// bootAuth before runApp.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;
  bool _ready = false;
  Timer? _safety;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/splash.mp4')
      ..setVolume(1.0)
      ..setLooping(false);

    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _controller.play();
      _controller.addListener(_onTick);
    }).catchError((_) {
      // If the video fails to load, don't get stuck — go straight to welcome.
      _goNext();
    });

    // Safety net: navigate no later than 4s regardless of video state so a
    // frozen or slow-decoding video never traps the user on the splash.
    _safety = Timer(const Duration(seconds: 4), _goNext);
  }

  void _onTick() {
    final v = _controller.value;
    if (!v.isInitialized) return;
    // When the clip finishes, or as it hits the last frame, move on.
    if (v.position >= v.duration && v.duration > Duration.zero) {
      _goNext();
    }
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _safety?.cancel();
    // If DI happens to be in a weird state (release flakiness has bit us
    // before), fall through as signed-out rather than throwing inside
    // the splash — a throw here would leave the user stuck on the video
    // forever since context.go would never run.
    bool signedIn = false;
    try {
      signedIn = sl<AuthService>().isSignedIn;
    } catch (e) {
      debugPrint('splash: AuthService.isSignedIn threw: $e');
    }
    try {
      context.go(signedIn ? '/' : '/welcome');
    } catch (e) {
      debugPrint('splash: context.go threw: $e');
    }
  }

  @override
  void dispose() {
    _safety?.cancel();
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: _ready
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
