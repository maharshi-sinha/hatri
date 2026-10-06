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
  /// Dev: backend + Docker Redis run on the Mac Mini. Simulator reaches
  /// it via LAN IP on the same Wi-Fi. If Mac Mini's IP changes, update here.
  /// Prod: Render-hosted backend behind `api.hatri.online` (CNAME + Let's
  /// Encrypt cert managed by Render).
  static String get apiBaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return 'http://192.168.29.112:3001';
      case Flavor.prod:
        return 'https://api.hatri.online';
    }
  }
}
