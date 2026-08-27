import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:motor/motor.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Nav tab spec
// ─────────────────────────────────────────────────────────────────────────────

class _NavTab {
  final String icon;
  final String label;
  const _NavTab(this.icon, this.label);
}

const List<_NavTab> _navTabs = [
  _NavTab('assets/icons/Home.svg', 'Home'),
  _NavTab('assets/icons/events.svg', 'Events'),
  _NavTab('assets/icons/communities.svg', 'Scenes'),
  _NavTab('assets/icons/city.svg', 'City'),
  _NavTab('assets/icons/Profile.svg', 'Profile'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Scaffold — platform split. iOS gets Liquid Glass, Android gets glassmorphic.
// ─────────────────────────────────────────────────────────────────────────────

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final selected = _calculateSelectedIndex(context);
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    // ─── iOS: floating Liquid Glass nav ─────────────────────────────────
    if (isIOS) {
      return Scaffold(
        extendBody: true,
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: MediaQuery.of(context).padding.copyWith(
              bottom: MediaQuery.of(context).padding.bottom + 84.r,
            ),
          ),
          child: child,
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.r),
            child: _IOSLiquidNav(
              selectedIndex: selected,
              onTap: (i) => _onTap(i, context),
            ),
          ),
        ),
      );
    }

    // ─── Android: standard Material BottomNavigationBar ─────────────────
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selected,
        onTap: (i) => _onTap(i, context),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.graphite,
        selectedItemColor: AppColors.fuchsia,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w500,
          fontSize: 11.sp,
        ),
        items: [
          for (final tab in _navTabs)
            BottomNavigationBarItem(
              icon: _materialTabIcon(tab.icon, AppColors.muted),
              activeIcon: _materialTabIcon(tab.icon, AppColors.fuchsia),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  Widget _materialTabIcon(String asset, Color tint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: SvgPicture.asset(
        asset,
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/communities')) return 2;
    if (location.startsWith('/city')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/events');
        break;
      case 2:
        context.go('/communities');
        break;
      case 3:
        context.go('/city');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS — Liquid Glass nav with drag-to-switch indicator
// ─────────────────────────────────────────────────────────────────────────────

class _IOSLiquidNav extends StatelessWidget {
  const _IOSLiquidNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  LiquidGlassSettings get _barSettings => LiquidGlassSettings(
        refractiveIndex: 1.21,
        thickness: 30,
        blur: 8,
        saturation: 1.5,
        lightIntensity: 1.0,
        ambientStrength: 0.5,
        lightAngle: math.pi / 4,
        glassColor: const Color(0x99F5F5F5),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.r),
      child: LiquidGlassLayer(
        settings: _barSettings,
        child: LiquidGlassBlendGroup(
          blend: 10,
          child: _IOSTabIndicator(
            tabIndex: selectedIndex,
            tabCount: _navTabs.length,
            onTabChanged: (i) {
              HapticFeedback.selectionClick();
              onTap(i);
            },
            child: LiquidGlass.grouped(
              clipBehavior: Clip.none,
              shape: LiquidRoundedSuperellipse(borderRadius: 32.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.r),
                height: 64.r,
                child: Row(
                  children: [
                    for (int i = 0; i < _navTabs.length; i++)
                      _iosTab(
                        _navTabs[i],
                        selected: i == selectedIndex,
                        onTap: () => onTap(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iosTab(
    _NavTab tab, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected ? AppColors.fuchsia : Colors.black87;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              tab.icon,
              width: 22.r,
              height: 22.r,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(height: 3.r),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 10.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Draggable glass indicator pill (from reference, adapted)
// ─────────────────────────────────────────────────────────────────────────────

Matrix4 _buildJellyTransform({
  required Offset velocity,
  double maxDistortion = 0.7,
  double velocityScale = 1000.0,
}) {
  final speed = velocity.distance;
  final direction = speed > 0 ? velocity / speed : Offset.zero;
  final factor = (speed / velocityScale).clamp(0.0, 1.0) * maxDistortion;
  if (factor == 0) return Matrix4.identity();
  final sx = (1.0 - direction.dx.abs() * factor * 0.5) *
      (1.0 + direction.dy.abs() * factor * 0.3);
  final sy = (1.0 - direction.dy.abs() * factor * 0.5) *
      (1.0 + direction.dx.abs() * factor * 0.3);
  final m = Matrix4.identity();
  m.storage[0] = sx;
  m.storage[5] = sy;
  return m;
}

class _IOSTabIndicator extends StatefulWidget {
  const _IOSTabIndicator({
    required this.child,
    required this.tabIndex,
    required this.tabCount,
    required this.onTabChanged,
  });

  final int tabIndex;
  final int tabCount;
  final Widget child;
  final ValueChanged<int> onTabChanged;

  @override
  State<_IOSTabIndicator> createState() => _IOSTabIndicatorState();
}

class _IOSTabIndicatorState extends State<_IOSTabIndicator> {
  bool _isDown = false;
  bool _isDragging = false;
  late double _xAlign = _alignForTab(widget.tabIndex);

  double _alignForTab(int index) {
    final t = (index / (widget.tabCount - 1)).clamp(0.0, 1.0);
    return t * 2 - 1;
  }

  @override
  void didUpdateWidget(covariant _IOSTabIndicator old) {
    super.didUpdateWidget(old);
    if (old.tabIndex != widget.tabIndex || old.tabCount != widget.tabCount) {
      setState(() => _xAlign = _alignForTab(widget.tabIndex));
    }
  }

  double _alignFromGlobal(Offset global) {
    final box = context.findRenderObject()! as RenderBox;
    final local = box.globalToLocal(global);
    final indicatorW = 1.0 / widget.tabCount;
    final range = 1.0 - indicatorW;
    final pad = indicatorW / 2;
    final raw = (local.dx / box.size.width).clamp(0.0, 1.0);
    final norm = (raw - pad) / range;
    return _rubberBand(norm) * 2 - 1;
  }

  static double _rubberBand(double v) {
    const r = 0.4;
    const max = 0.3;
    if (v < 0) return -((-v) * r).clamp(0.0, max);
    if (v > 1) return 1 + ((v - 1) * r).clamp(0.0, max);
    return v;
  }

  void _onDragDown(DragDownDetails d) => setState(() {
        _isDown = true;
        _xAlign = _alignFromGlobal(d.globalPosition);
      });

  void _onDragUpdate(DragUpdateDetails d) => setState(() {
        _isDragging = true;
        _xAlign = _alignFromGlobal(d.globalPosition);
      });

  void _onDragEnd(DragEndDetails d) {
    setState(() {
      _isDragging = false;
      _isDown = false;
    });
    final box = context.findRenderObject()! as RenderBox;
    final rel = (_xAlign + 1) / 2;
    final tabW = 1.0 / widget.tabCount;
    final indW = 1.0 / widget.tabCount;
    final range = 1.0 - indW;
    final vx = (d.velocity.pixelsPerSecond.dx / box.size.width) / range;

    int target;
    if (rel < 0) {
      target = 0;
    } else if (rel > 1) {
      target = widget.tabCount - 1;
    } else {
      const vThresh = 0.5;
      if (vx.abs() > vThresh) {
        final proj = (rel + vx * 0.3).clamp(0.0, 1.0);
        target = (proj / tabW).round().clamp(0, widget.tabCount - 1);
        final cur = (rel / tabW).round().clamp(0, widget.tabCount - 1);
        if (vx > vThresh && target <= cur && cur < widget.tabCount - 1) {
          target = cur + 1;
        } else if (vx < -vThresh && target >= cur && cur > 0) {
          target = cur - 1;
        }
      } else {
        target = (rel / tabW).round().clamp(0, widget.tabCount - 1);
      }
    }

    _xAlign = _alignForTab(target);
    if (target != widget.tabIndex) {
      HapticFeedback.lightImpact();
      widget.onTabChanged(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetAlign = _alignForTab(widget.tabIndex);

    return GestureDetector(
      onHorizontalDragDown: _onDragDown,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onHorizontalDragCancel: () => setState(() {
        _isDragging = false;
        _isDown = false;
      }),
      child: VelocityMotionBuilder(
        converter: SingleMotionConverter(),
        value: _xAlign,
        motion: _isDragging
            ? CupertinoMotion.interactive()
            : CupertinoMotion.bouncy(),
        builder: (context, value, velocity, child) {
          final alignment = Alignment(value, 0);
          return SingleMotionBuilder(
            motion: CupertinoMotion.snappy(),
            value: _isDown || (alignment.x - targetAlign).abs() > 0.30 ? 1.0 : 0.0,
            builder: (context, thickness, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  if (thickness < 1)
                    _IndicatorPill(
                      velocity: velocity,
                      tabCount: widget.tabCount,
                      alignment: alignment,
                      thickness: thickness,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 120),
                        opacity: thickness <= .2 ? 1 : 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(64.r),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  child!,
                  if (thickness > 0)
                    _IndicatorPill(
                      velocity: velocity,
                      tabCount: widget.tabCount,
                      alignment: alignment,
                      thickness: thickness,
                      child: LiquidGlass.withOwnLayer(
                        settings: LiquidGlassSettings(
                          visibility: thickness,
                          glassColor: const Color.fromRGBO(255, 255, 255, 0.1),
                          saturation: 1.5,
                          refractiveIndex: 1.15,
                          thickness: 20,
                          lightIntensity: 2,
                          chromaticAberration: .5,
                          blur: 0,
                        ),
                        shape: LiquidRoundedSuperellipse(borderRadius: 64.r),
                        child: const GlassGlow(child: SizedBox.expand()),
                      ),
                    ),
                ],
              );
            },
            child: widget.child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _IndicatorPill extends StatelessWidget {
  const _IndicatorPill({
    required this.velocity,
    required this.tabCount,
    required this.alignment,
    required this.thickness,
    required this.child,
  });

  final double velocity;
  final int tabCount;
  final Alignment alignment;
  final double thickness;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      left: 4,
      right: 4,
      top: 4,
      bottom: 4,
      child: FractionallySizedBox(
        widthFactor: 1 / tabCount,
        alignment: alignment,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fromRelativeRect(
              rect: RelativeRect.lerp(
                RelativeRect.fill,
                const RelativeRect.fromLTRB(-14, -14, -14, -14),
                thickness,
              )!,
              child: SingleMotionBuilder(
                motion: CupertinoMotion.bouncy(),
                value: velocity,
                builder: (context, v, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: _buildJellyTransform(
                      velocity: Offset(v, 0),
                      maxDistortion: .8,
                      velocityScale: 10,
                    ),
                    child: child,
                  );
                },
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
