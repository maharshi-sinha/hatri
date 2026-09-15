enum Flavor {
  dev,
  prod,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Hatri Dev';
      case Flavor.prod:
        return 'Hatri';
    }
  }

  /// Backend base URL for this flavor.
  ///
  /// Dev points at the rishabhsingh Mac's LAN IP. If that IP changes (new Wi-Fi
  /// network, laptop moved), swap it below.
  /// Prod is a placeholder until we ship the real backend.
  static String get apiBaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return 'http://192.168.29.207:3001';
      case Flavor.prod:
        return 'https://api.hatri.online';
    }
  }
}
