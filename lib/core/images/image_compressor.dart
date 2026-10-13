import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Adaptive image compressor used before uploading any user-generated
/// photo (avatar, event cover). Scales the longest side to `maxDimension`
/// first, then iteratively steps JPEG quality down until the output file
/// fits under `maxBytes`. The caller gets back a path on temp storage.
///
/// We prefer JPEG output: HEIC/HEIF aren't web-safe (Android/Chrome
/// won't render them), PNG blows past the size cap on photos, and WebP
/// support still varies on older Android webviews we may embed later.
class ImageCompressor {
  const ImageCompressor();

  /// Picks a working quality level in a handful of steps rather than a
  /// slow binary search. For 300 KB targets on 512 px avatars this almost
  /// always lands at the first step (quality 85); for 500 KB covers at
  /// 1200 px it can take 2-3 attempts on busy photos.
  static const List<int> _qualityLadder = [85, 75, 65, 55, 45, 35];

  /// Compresses [source] and returns the resulting file on temp storage.
  /// Falls back to the original file untouched if every step fails — the
  /// caller's upload path can still succeed and will be rejected by the
  /// server-side size cap if it's genuinely too large.
  Future<File> compressForUpload(
    File source, {
    required int maxDimension,
    required int maxBytes,
    required String label,
  }) async {
    final tmp = await getTemporaryDirectory();
    for (final quality in _qualityLadder) {
      final target =
          '${tmp.path}/${label}_${DateTime.now().microsecondsSinceEpoch}_q$quality.jpg';
      try {
        final out = await FlutterImageCompress.compressAndGetFile(
          source.absolute.path,
          target,
          quality: quality,
          format: CompressFormat.jpeg,
          minWidth: maxDimension,
          minHeight: maxDimension,
          // keepExif off so we strip location/camera metadata — a nice
          // privacy win alongside the size cap.
          keepExif: false,
        );
        if (out == null) continue;
        final size = await File(out.path).length();
        if (size <= maxBytes) {
          debugPrint(
              '[compress] $label: $size B at q=$quality (<= $maxBytes B)');
          return File(out.path);
        }
        debugPrint('[compress] $label: $size B at q=$quality > $maxBytes B');
      } catch (e) {
        debugPrint('[compress] $label: step q=$quality threw $e');
      }
    }
    debugPrint('[compress] $label: all steps exhausted, falling back');
    return source;
  }
}
