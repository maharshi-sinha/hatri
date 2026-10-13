import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../backend/api/cities_api.dart';
import '../../backend/models/city_models.dart';
import '../../backend/services/auth_service.dart';
import '../../backend/services/user_service.dart';
import '../di/injection_container.dart';

/// A map-view hint: where to center the FlutterMap and what label to show.
/// `slug` is null only when every resolution path failed and we're painting
/// an India-wide zoom so the UI never shows a lie.
class MapViewHint {
  final String? slug;
  final LatLng center;
  final double zoom;
  const MapViewHint({required this.slug, required this.center, required this.zoom});
}

/// Resolves the user's nearest Hatri-live city from their device GPS and
/// persists it on the backend profile.
///
/// Called in two places:
///   1. After the location permission is granted during onboarding — the
///      resolved slug lands in `currentUser` and is PATCHed by the
///      celebration screen alongside the rest of the profile.
///   2. On every signed-in boot (through `tryResolveSilently`) when the
///      user still has no `currentCitySlug` set — a one-shot catch-up for
///      accounts created before this feature existed. Fails silently if
///      location permission is missing or GPS is unavailable so the app
///      never blocks on it.
class GeoCityResolver {
  final CitiesApi _api;

  GeoCityResolver(this._api);

  /// Reads GPS, picks nearest active city, returns its slug.
  /// Returns null when permission is missing, GPS fails, or no active city
  /// has coordinates on file.
  Future<String?> resolveNearest() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) return null;

      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) return null;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final cities = await _api.listActive();
      final candidates =
          cities.where((c) => c.latitude != null && c.longitude != null).toList();
      if (candidates.isEmpty) return null;

      ApiCity nearest = candidates.first;
      double nearestDist = _haversineKm(
        pos.latitude,
        pos.longitude,
        nearest.latitude!,
        nearest.longitude!,
      );
      for (final c in candidates.skip(1)) {
        final d = _haversineKm(
          pos.latitude,
          pos.longitude,
          c.latitude!,
          c.longitude!,
        );
        if (d < nearestDist) {
          nearest = c;
          nearestDist = d;
        }
      }
      return nearest.slug;
    } catch (e, s) {
      debugPrint('GeoCityResolver failed: $e\n$s');
      return null;
    }
  }

  /// Picks what the map should initially center on and what to render as
  /// its title. Resolution order:
  ///   1. User's resolved city (currentUser.currentCitySlug) — look up its
  ///      coords from the active-cities list.
  ///   2. Live GPS resolve for users whose city hasn't been set yet.
  ///   3. First active city with coords from the API.
  ///   4. India geographic center at a country-wide zoom — only when every
  ///      network and GPS path has failed. We render a plain "MAP" title so
  ///      the UI never names a city it hasn't confirmed.
  Future<MapViewHint> resolveMapView() async {
    const indiaCenter = LatLng(20.5937, 78.9629);
    const cityZoom = 12.0;
    const indiaZoom = 5.0;

    List<ApiCity>? cities;
    try {
      cities = await _api.listActive();
    } catch (_) {
      cities = null;
    }

    MapViewHint? pick(String slug) {
      final match = cities?.firstWhere(
        (c) => c.slug == slug && c.latitude != null && c.longitude != null,
        orElse: () => const ApiCity(
          slug: '',
          name: '',
          state: '',
          active: false,
          timezone: '',
          latitude: null,
          longitude: null,
        ),
      );
      if (match == null || match.slug.isEmpty) return null;
      return MapViewHint(
        slug: match.slug,
        center: LatLng(match.latitude!, match.longitude!),
        zoom: cityZoom,
      );
    }

    // 1 — user's saved city
    final userSlug = sl<AuthService>().user?.currentCitySlug;
    if (userSlug != null && userSlug.isNotEmpty) {
      final hit = pick(userSlug);
      if (hit != null) return hit;
    }

    // 2 — live resolve from GPS
    final liveSlug = await resolveNearest();
    if (liveSlug != null) {
      final hit = pick(liveSlug);
      if (hit != null) return hit;
    }

    // 3 — first active city with coords
    final firstWithCoords = cities?.firstWhere(
      (c) => c.latitude != null && c.longitude != null,
      orElse: () => const ApiCity(
        slug: '',
        name: '',
        state: '',
        active: false,
        timezone: '',
        latitude: null,
        longitude: null,
      ),
    );
    if (firstWithCoords != null && firstWithCoords.slug.isNotEmpty) {
      return MapViewHint(
        slug: firstWithCoords.slug,
        center: LatLng(firstWithCoords.latitude!, firstWithCoords.longitude!),
        zoom: cityZoom,
      );
    }

    // 4 — honest India-wide fallback
    return const MapViewHint(slug: null, center: indiaCenter, zoom: indiaZoom);
  }

  /// Boot-time catch-up for users whose currentCitySlug is null. Runs
  /// quietly in the background and PATCHes the backend on success.
  Future<void> tryResolveSilently() async {
    final auth = sl<AuthService>();
    if (!auth.isSignedIn) return;
    if (auth.user?.currentCitySlug != null) return;
    final slug = await resolveNearest();
    if (slug == null) return;
    try {
      await sl<UserService>()
          .updateProfile(currentCitySlug: slug, homeCitySlug: slug);
    } catch (e) {
      debugPrint('GeoCityResolver patch failed: $e');
    }
  }

  /// Earth-sphere great-circle distance in km. Accurate enough for picking
  /// the nearest Indian city from a candidate list of ~10 options.
  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);
}
