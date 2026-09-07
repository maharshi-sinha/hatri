import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'utility_screen.dart';

/// Ready-to-push utility screens. Each factory returns a [UtilityScreen]
/// pre-wired with mascot, copy + CTA — pushable straight from any route.
class UtilityScreens {
  UtilityScreens._();

  /// Generic "something went wrong" catcher. Wrap around unexpected
  /// exceptions from repositories / services.
  static Widget error({
    Future<void> Function()? onRetry,
    String subtitle = "couldn't load that. our bad. hit retry?",
  }) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/error.png',
      eyebrow: 'OUR BAD',
      headlineTop: 'WE',
      headlineBottom: 'FUMBLED.',
      subtitle: subtitle,
      ctaLabel: onRetry != null ? 'TRY AGAIN' : null,
      onCta: onRetry,
    );
  }

  /// Force-update. Shown when backend flags min-supported version breach.
  static Widget updateRequired({required Future<void> Function() onOpenStore}) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/update_required.png',
      eyebrow: 'NEW DROP',
      headlineTop: 'YOU\'RE ON',
      headlineBottom: 'LEGACY.',
      subtitle: "the fresh hatri's got the tea. update before you miss it.",
      ctaLabel: 'PULL UP',
      onCta: onOpenStore,
    );
  }

  /// Backend is down for maintenance.
  static Widget maintenance({String? eta}) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/maintenance.png',
      eyebrow: 'BRB',
      headlineTop: 'COOKING',
      headlineBottom: 'SOMETHING.',
      subtitle: eta != null
          ? "servers are getting a lil glow up. back in $eta."
          : "servers are getting a lil glow up. back before you refresh again.",
    );
  }

  /// Session expired — pushes back to phone entry.
  static Widget sessionExpired({required Future<void> Function() onSignIn}) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/session_expired.png',
      eyebrow: 'HEY STRANGER',
      headlineTop: 'WELCOME',
      headlineBottom: 'BACK.',
      subtitle: "been a minute. quick verify and you're right back in.",
      ctaLabel: 'LET ME IN',
      onCta: onSignIn,
    );
  }

  /// Deep-linked event / scene doesn't exist.
  static Widget notFound({required Future<void> Function() onHome}) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/not_found.png',
      eyebrow: '404',
      headlineTop: 'WENT',
      headlineBottom: 'GHOST.',
      subtitle:
          "this link's giving broken. maybe it moved, maybe it wrapped. peep tonight?",
      ctaLabel: 'TAKE ME HOME',
      onCta: onHome,
    );
  }

  /// Every tier of an event is sold out.
  static Widget soldOut({Future<void> Function()? onWaitlist}) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/sold_out.png',
      eyebrow: 'PACKED',
      headlineTop: 'EVERYONE',
      headlineBottom: 'KNEW.',
      subtitle:
          "every tier's gone. hop the waitlist. spots open sometimes.",
      ctaLabel: onWaitlist != null ? 'PUT ME ON' : null,
      onCta: onWaitlist,
    );
  }

  /// Payment gateway returned a failure.
  static Widget paymentFailed({required Future<void> Function() onRetry}) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/payment_failed.png',
      eyebrow: 'NOT TODAY',
      headlineTop: 'CARD',
      headlineBottom: 'SAID NO.',
      subtitle:
          "payment didn't land. money's still yours. give it another go?",
      ctaLabel: 'RUN IT BACK',
      onCta: onRetry,
    );
  }

  /// Generic post-action celebration.
  static Widget celebration({
    required String headlineTop,
    required String headlineBottom,
    required String subtitle,
    String ctaLabel = 'BET',
    required Future<void> Function() onCta,
  }) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/celebration.png',
      eyebrow: '★ LOCKED IN',
      headlineTop: headlineTop,
      headlineBottom: headlineBottom,
      subtitle: subtitle,
      ctaLabel: ctaLabel,
      onCta: onCta,
    );
  }

  /// Generic "nothing here yet" empty state. Pass in surface-specific copy.
  static Widget empty({
    required String headlineTop,
    required String headlineBottom,
    required String subtitle,
    String? ctaLabel,
    Future<void> Function()? onCta,
  }) {
    return UtilityScreen(
      assetPath: 'assets/images/utility/empty.png',
      eyebrow: 'CRICKETS',
      headlineTop: headlineTop,
      headlineBottom: headlineBottom,
      subtitle: subtitle,
      ctaLabel: ctaLabel,
      onCta: onCta,
      eyebrowColor: AppColors.muted,
    );
  }
}
