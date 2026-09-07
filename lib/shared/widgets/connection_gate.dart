import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'offline_screen.dart';

/// Wraps the app and overlays [OfflineScreen] whenever the device loses
/// internet. Uses [Connectivity] as a *cheap trigger* (fires when interfaces
/// change) and a periodic DNS lookup as the *authoritative check* — because
/// the iOS Simulator (and captive portals in general) can report "wifi
/// connected" while there is no actual internet.
class ConnectionGate extends StatefulWidget {
  final Widget child;
  const ConnectionGate({super.key, required this.child});

  @override
  State<ConnectionGate> createState() => _ConnectionGateState();
}

class _ConnectionGateState extends State<ConnectionGate> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _poll;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _verify();
    _sub = _connectivity.onConnectivityChanged.listen((_) => _verify());
    // Periodic sanity check — catches the simulator + captive portal cases
    // where the OS-level connectivity events don't fire but reachability
    // really has changed.
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _verify());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    final hasNet = await _hasRealInternet();
    if (!mounted || hasNet == _online) return;
    setState(() => _online = hasNet);
  }

  /// Verifies real reachability with a fast DNS lookup. Falls back to false
  /// on any error (SocketException / timeout / lookup failure).
  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('one.one.one.one')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _retry() async {
    await _verify();
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_online)
          Positioned.fill(
            child: OfflineScreen(onRetry: _retry),
          ),
      ],
    );
  }
}
