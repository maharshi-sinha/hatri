import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// App-wide image widget. Thin wrapper around CachedNetworkImage with:
/// - Persistent disk cache (survives app restarts, cleared after 30 days
///   by CachedNetworkImage's default manager)
/// - A quiet surface-coloured placeholder while loading
/// - A broken-link fallback that matches our dark theme
/// - Optional borderRadius so callers don't need to wrap in ClipRRect
///
/// Signature intentionally mirrors Image.network so swapping existing
/// `Image.network(url, fit: ..., width: ...)` calls is near-mechanical.
class HatriImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const HatriImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final child = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, _) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: AppColors.surface,
          ),
      errorWidget: (_, _, _) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: AppColors.surface,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.muted,
              size: 24,
            ),
          ),
    );
    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}
