import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around `connectivity_plus` so repositories can ask
/// "is the device online?" without importing the plugin directly. Lets us
/// swap for a fake in tests.
abstract class NetworkInfo {
  /// True when the device reports any non-`none` connection. Note that this
  /// is a hint, not a guarantee: the actual request may still fail. Treat it
  /// as "fail fast before we even try" rather than "the request will succeed".
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  const NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
