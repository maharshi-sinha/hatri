import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../backend/services/auth_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/design/hatri_snack.dart';

/// Crisp chat support — a lightweight webview wrapper around our embedded
/// Crisp chatbox. The admin side is the Crisp mobile app (free tier gives
/// us 2 agents + unlimited history), so support messages route straight to
/// a dedicated inbox we can reply to from anywhere.
///
/// We inject the signed-in user's nickname, phone and user id into the
/// Crisp session on page load so threads come in pre-identified. Nobody
/// types their name again.
///
/// Email fallback is shown underneath if the chat fails to load (bad
/// network, firewall, etc.) — tapping it opens the user's mail app
/// pre-addressed to hello@hatri.online.
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  // Crisp Website ID for the Hatri workspace. Lifted into a constant so
  // swapping to a new workspace is a one-line change.
  static const _crispWebsiteId = '90121a1f-7998-4c90-a735-80522f38c749';
  static const _supportEmail = 'hello@hatri.online';

  late final WebViewController _web;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.ground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
            _identifyUser();
          },
          onWebResourceError: (err) {
            // Only fail the whole screen on top-frame errors; sub-resource
            // 404s (fonts, images etc.) can be noisy and harmless.
            if (err.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _loading = false;
                  _failed = true;
                });
              }
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://go.crisp.chat/chat/embed/?website_id=$_crispWebsiteId',
        ),
      );
  }

  /// Pushes the signed-in user's details into the Crisp session so the
  /// admin side sees "+91xxx (Maharshi, id abc123)" instead of an
  /// anonymous visitor. All three keys are optional — we only set what
  /// we actually have.
  Future<void> _identifyUser() async {
    final user = sl<AuthService>().user;
    if (user == null) return;
    final name = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : 'main character';
    // Crisp exposes `$crisp` as a global. We queue the identity updates;
    // they're idempotent so running them on every page-finished is safe.
    final js = """
      try {
        \$crisp.push(["set", "user:nickname", ["${_escape(name)}"]]);
        \$crisp.push(["set", "user:phone", ["${_escape(user.phone)}"]]);
        \$crisp.push(["set", "session:data", [[
          ["user_id", "${_escape(user.id)}"]
        ]]]);
      } catch (e) {}
    """;
    try {
      await _web.runJavaScript(js);
    } catch (_) {
      // Chat still works without identity; just move on.
    }
  }

  String _escape(String raw) =>
      raw.replaceAll('\\', r'\\').replaceAll('"', r'\"');

  Future<void> _openMailFallback() async {
    HapticFeedback.selectionClick();
    final uri = Uri.parse(
      'mailto:$_supportEmail?subject=${Uri.encodeComponent('[hatri] help')}',
    );
    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      HatriSnack.show(
        context,
        'no mail app set up. email us at $_supportEmail',
        vibe: SnackVibe.info,
        emoji: '📬',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
            _buildEmailFallback(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(Corners.md),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  width: 20.r,
                  height: 20.r,
                  colorFilter: const ColorFilter.mode(
                    AppColors.paper,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.r),
          Text(
            'SUPPORT',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 28.sp,
              height: 0.95,
              letterSpacing: -0.8.sp,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_failed) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.r),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: AppColors.muted,
                size: 48.r,
              ),
              SizedBox(height: 16.r),
              Text(
                "chat couldn't load.",
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.w800,
                  fontSize: 22.sp,
                  color: AppColors.paper,
                ),
              ),
              SizedBox(height: 8.r),
              Text(
                "check your connection, or email us using the link below.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        WebViewWidget(controller: _web),
        if (_loading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.fuchsia),
          ),
      ],
    );
  }

  Widget _buildEmailFallback() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, 10.r, Insets.lg, 14.r),
      child: GestureDetector(
        onTap: _openMailFallback,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline_rounded,
                size: 16.r, color: AppColors.muted),
            SizedBox(width: 6.r),
            Text(
              'prefer email? write to $_supportEmail',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: AppColors.muted,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
