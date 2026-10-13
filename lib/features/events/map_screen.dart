import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../core/di/injection_container.dart';
import '../../core/geo/city_resolver.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import 'bloc/events_bloc.dart';
import 'bloc/events_event.dart';
import 'bloc/events_state.dart';
import 'event_details_screen.dart';
import '../../core/responsive/responsive.dart';

/// Full-screen event map, styled to Hatri. Reuses EventsBloc filters so list
/// view and map view share one mental model.
// ─── Tile source configuration ──────────────────────────────────────────────
// For production we render **Stadia Alidade Smooth Dark** — a dark, OSM-based
// basemap. Free tier is 200k tile requests/month. Grab an API key at
// https://client.stadiamaps.com and paste it below. When the key is empty
// (demo/dev), we fall back to standard OSM tiles wrapped in a client-side
// dark color filter so the app still works without any account.
const String _stadiaApiKey = ''; // TODO: paste Stadia API key for production.
const bool _useStadia = _stadiaApiKey != '';

/// Color matrix that turns light-themed OSM tiles into a dark map (dev
/// fallback only). Inverts luminance and hue-shifts so water still reads as
/// water, not a jarring orange.
const ColorFilter _osmDarkFilter = ColorFilter.matrix(<double>[
  -0.2, -0.7, -0.1, 0, 255,
  -0.2, -0.7, -0.1, 0, 255,
  -0.2, -0.7, -0.1, 0, 255,
   0,   0,   0,   1, 0,
]);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _map = MapController();
  String? _selectedEventId;
  // Resolved from GeoCityResolver on first build. India-wide fallback until
  // we hear back, so the map always has something sane to center on even
  // when the network is down.
  MapViewHint _view = const MapViewHint(
    slug: null,
    center: LatLng(20.5937, 78.9629),
    zoom: 5.0,
  );
  bool _viewResolved = false;

  @override
  void initState() {
    super.initState();
    _resolveView();
  }

  Future<void> _resolveView() async {
    final hint = await sl<GeoCityResolver>().resolveMapView();
    if (!mounted) return;
    setState(() {
      _view = hint;
      _viewResolved = true;
    });
    _map.move(hint.center, hint.zoom);
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  /// Formats the title eyebrow: slug uppercased, or "NEAR YOU" once we've
  /// resolved and are on the India fallback, or empty while resolving.
  String _headerLabel() {
    if (_view.slug != null) {
      return _view.slug!.toUpperCase().replaceAll('-', ' ');
    }
    return _viewResolved ? 'NEAR YOU' : '';
  }

  void _onPinTap(Event e) {
    HapticFeedback.lightImpact();
    setState(() => _selectedEventId = e.id);
    if (e.lat != null && e.lng != null) {
      _map.move(LatLng(e.lat!, e.lng!), 14);
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EventSheet(event: e),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedEventId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(label: _headerLabel()),
            const _DiscoveryFilterBar(),
            SizedBox(height: 8.r),
            const _CategoryChipsBar(),
            SizedBox(height: 14.r),
            Expanded(
              child: BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) {
                  final loaded = state is EventsLoaded ? state : null;
                  final events = loaded?.filtered
                          .where((e) => e.lat != null && e.lng != null)
                          .toList() ??
                      const <Event>[];
                  return Stack(
                    children: [
                      FlutterMap(
                        mapController: _map,
                        options: MapOptions(
                          initialCenter: _view.center,
                          initialZoom: _view.zoom,
                          minZoom: _view.slug == null ? 4 : 10,
                          maxZoom: 18,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          // Production: Stadia Alidade Smooth Dark (native
                          // dark theme, OSM-derived, 200k free req/month).
                          // Fallback: standard OSM tiles + color filter when
                          // the Stadia key hasn't been added yet.
                          if (_useStadia)
                            TileLayer(
                              urlTemplate:
                                  'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=$_stadiaApiKey',
                              userAgentPackageName: 'app.hatri',
                              retinaMode: RetinaMode.isHighDensity(context),
                              maxNativeZoom: 20,
                            )
                          else
                            ColorFiltered(
                              colorFilter: _osmDarkFilter,
                              child: TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'app.hatri',
                                retinaMode: RetinaMode.isHighDensity(context),
                                maxNativeZoom: 19,
                              ),
                            ),
                          MarkerLayer(
                            markers: events.map((e) {
                              final selected = _selectedEventId == e.id;
                              return Marker(
                                point: LatLng(e.lat!, e.lng!),
                                width: selected ? 68 : 56,
                                height: selected ? 68 : 56,
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _onPinTap(e),
                                  child: _StarburstPin(
                                    color: AppColors.fromHex(e.colorHex),
                                    selected: selected,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      // Empty overlay if there's genuinely nothing to show.
                      if (loaded != null && events.isEmpty)
                        Positioned(
                          bottom: 40.r,
                          left: 0,
                          right: 0,
                          child: Center(child: _EmptyOverlay()),
                        ),
                      // Attribution — small, respectful.
                      Positioned(
                        left: 8.r,
                        bottom: 8.r,
                        child: _Attribution(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Header + filter/category bars (shared visual with EventsScreen) ----------------

class _Header extends StatelessWidget {
  final String label;
  const _Header({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _iconButton(context, Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    letterSpacing: 1.6.sp,
                    color: AppColors.lime,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'MAP',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 36.sp,
                    height: 0.95,
                    letterSpacing: -1.2.sp,
                    color: AppColors.paper,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: icon == Icons.arrow_back_rounded
            ? Center(
                child: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  width: 20.r,
                  height: 20.r,
                  colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                ),
              )
            : Icon(icon, color: AppColors.paper, size: 20.r),
      ),
    );
  }
}

class _DiscoveryFilterBar extends StatelessWidget {
  const _DiscoveryFilterBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        final active = state is EventsLoaded ? state.filter : DiscoveryFilter.all;
        return SizedBox(
          height: 40.r,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            children: DiscoveryFilter.values.map((f) {
              return Padding(
                padding: EdgeInsets.only(right: 8.r),
                child: FilterChipX(
                  label: f.label,
                  selected: active == f,
                  onTap: () => context.read<EventsBloc>().add(SetDiscoveryFilter(f)),
                  activeColor: AppColors.lime,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _CategoryChipsBar extends StatelessWidget {
  const _CategoryChipsBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        final active = state is EventsLoaded ? state.category : null;
        return SizedBox(
          height: 40.r,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            children: [
              _catChip(context, null, 'All', active == null),
              for (final c in EventCategory.values.where((c) => c != EventCategory.other))
                _catChip(context, c, c.label, active == c),
            ],
          ),
        );
      },
    );
  }

  Widget _catChip(BuildContext context, EventCategory? cat, String label, bool selected) {
    return Padding(
      padding: EdgeInsets.only(right: 8.r),
      child: FilterChipX(
        label: label,
        selected: selected,
        onTap: () => context.read<EventsBloc>().add(SetCategoryFilter(selected ? null : cat)),
        activeColor: cat == null ? AppColors.fuchsia : AppColors.fromHex(cat.colorHex),
      ),
    );
  }
}

// ---------------- Custom pin (starburst inside a hard-outlined disc) ----------------

class _StarburstPin extends StatelessWidget {
  final Color color;
  final bool selected;
  const _StarburstPin({required this.color, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Motion.fast,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.graphite,
        border: Border.all(color: AppColors.onNeon, width: 1.6),
        boxShadow: selected
            ? [BoxShadow(color: AppColors.lime.withValues(alpha: 0.55), blurRadius: 14.r, spreadRadius: 2.r)]
            : [BoxShadow(color: Color(0xAA000000), blurRadius: 6.r, offset: Offset(0, 2.r))],
      ),
      padding: EdgeInsets.all(selected ? 10 : 8),
      child: CustomPaint(painter: _PinStarburst(color: color)),
    );
  }
}

class _PinStarburst extends CustomPainter {
  final Color color;
  _PinStarburst({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const points = 8;
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final innerR = outerR * 0.42;
    final path = ui.Path();
    final step = math.pi / points;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final a = i * step - math.pi / 2;
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinStarburst old) => old.color != color;
}

// ---------------- Bottom-sheet card for a tapped pin ----------------

class _EventSheet extends StatelessWidget {
  final Event event;
  const _EventSheet({required this.event});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromHex(event.colorHex);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.graphite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Corners.xl),
          topRight: Radius.circular(Corners.xl),
        ),
        border: Border(
          top: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + Insets.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.r),
          Container(
            width: 42.r,
            height: 4.r,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 12.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.md),
                  child: Stack(
                    children: [
                      Image.network(
                        event.coverUrl,
                        width: 92.r,
                        height: 92.r,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(width: 92.r, height: 92.r, color: accent),
                      ),
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.18,
                          child: HalftoneBackground(
                            dotColor: AppColors.onNeon,
                            spacing: 6.r,
                            dotSize: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CategoryTag(label: event.category.label, color: accent),
                          SizedBox(width: 6.r),
                          StickerLabel(
                            text: event.isFree ? 'FREE' : 'PAID',
                            background: event.isFree ? AppColors.lime : AppColors.fuchsia,
                            foreground: event.isFree ? AppColors.onNeon : AppColors.paper,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.r),
                      Text(
                        event.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                          height: 1.02,
                          letterSpacing: -0.3.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        '${DateFormat('EEE, MMM d').format(event.date).toUpperCase()} · ${event.time}',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                          letterSpacing: 0.6.sp,
                          color: AppColors.muted,
                        ),
                      ),
                      Text(
                        event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: PrimaryButton(
              label: 'View event',
              expand: true,
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOverlay extends StatelessWidget {
  const _EmptyOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.r),
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        borderRadius: BorderRadius.circular(Corners.md),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Nothing on the map for this filter.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.paper),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: AppColors.ground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        _useStadia
            ? '© Stadia Maps · © OpenStreetMap contributors'
            : '© OpenStreetMap contributors',
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 9.sp,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
