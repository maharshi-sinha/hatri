import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// Which platform to render.
enum SocialBrand { instagram, x }

/// Rounded square brand badge for Instagram / X. Renders the platform's
/// signature background (Instagram: 4-stop gradient, X: dark tile) + inline
/// SVG mark. Shared across the Edit Profile socials section and the compact
/// two-badge strip on the public profile.
class SocialBrandBadge extends StatelessWidget {
  final SocialBrand brand;
  final double size;
  const SocialBrandBadge({super.key, required this.brand, required this.size});

  static const String _igSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="3" width="18" height="18" rx="5" ry="5"/>
  <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/>
  <circle cx="17.5" cy="6.5" r="0.9" fill="white"/>
</svg>
''';

  static const String _xSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white">
  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
</svg>
''';

  /// Raw SVG string for the brand mark — usable when you want the icon alone
  /// (e.g., inside a chip) without the tile background.
  static String markSvg(SocialBrand brand) =>
      brand == SocialBrand.instagram ? _igSvg : _xSvg;

  @override
  Widget build(BuildContext context) {
    if (brand == SocialBrand.instagram) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF515BD4), // deep indigo
              Color(0xFF8134AF), // purple
              Color(0xFFDD2A7B), // pink
              Color(0xFFFEDA77), // gold
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SvgPicture.string(
          _igSvg,
          width: size * 0.55,
          height: size * 0.55,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.onNeon,
        border: Border.all(color: AppColors.paper.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: SvgPicture.string(
        _xSvg,
        width: size * 0.48,
        height: size * 0.48,
      ),
    );
  }
}

/// Strip the leading `@` off a stored handle for building profile URLs.
String stripHandle(String s) {
  final t = s.trim();
  if (t.isEmpty) return '';
  return t.startsWith('@') ? t.substring(1) : t;
}

String instagramUrl(String handle) => 'https://instagram.com/${stripHandle(handle)}';
String xUrl(String handle) => 'https://x.com/${stripHandle(handle)}';
