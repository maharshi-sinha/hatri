import 'package:flutter/material.dart';

import 'utility_screen.dart';

/// Full-screen offline state. Shown by [ConnectionGate] when the device has no
/// internet. Retry re-checks connectivity via the gate above.
class OfflineScreen extends StatelessWidget {
  final Future<void> Function() onRetry;
  const OfflineScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/offline.png',
      eyebrow: 'NO SIGNAL',
      headlineTop: 'OFFLINE',
      headlineBottom: 'ERA.',
      subtitle:
          "the wifi ghosted. we'll bring the city back the sec you're back on.",
      ctaLabel: 'TRY AGAIN',
      onCta: onRetry,
    );
  }
}
