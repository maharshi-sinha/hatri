import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/hatri_snack.dart';
import '../../shared/design/motifs.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(Insets.lg, 8.r, Insets.lg, 40.r),
                children: [
                  _SectionLabel(label: 'ACCOUNT', accent: AppColors.fuchsia),
                  _SettingsRow(
                    svg: 'assets/icons/Profile.svg',
                    tint: AppColors.fuchsia,
                    title: 'Personal info',
                    subtitle: 'name, bio, photo',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.payment_rounded,
                    tint: AppColors.lime,
                    title: 'Payment methods',
                    subtitle: 'cards, upi, wallets',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.tag_rounded,
                    tint: AppColors.indigo,
                    title: 'Interests',
                    subtitle: 'what shows up on your feed',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    svg: 'assets/icons/Notification.svg',
                    tint: AppColors.fuchsia,
                    title: 'Notifications',
                    subtitle: 'push, email, in-app',
                    onTap: () {},
                  ),
                  _SectionLabel(label: 'PRIVACY & DATA', accent: AppColors.lime),
                  _SettingsRow(
                    svg: 'assets/icons/Shield.svg',
                    tint: AppColors.lime,
                    title: 'Blocked users',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.download_rounded,
                    tint: AppColors.paper,
                    title: 'Download my data',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    tint: AppColors.paper,
                    title: 'Privacy policy',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.description_outlined,
                    tint: AppColors.paper,
                    title: 'Terms of service',
                    onTap: () {},
                  ),
                  _SectionLabel(label: 'SUPPORT', accent: AppColors.indigo),
                  _SettingsRow(
                    icon: Icons.help_outline_rounded,
                    tint: AppColors.indigo,
                    title: 'Help center',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.flag_outlined,
                    tint: AppColors.indigo,
                    title: 'Report a problem',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    tint: AppColors.paper,
                    title: 'About Hatri',
                    subtitle: 'v1.0 · made with ❤ in India',
                    onTap: () {},
                  ),
                  _SectionLabel(label: 'DANGER ZONE', accent: AppColors.fuchsia),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    tint: AppColors.fuchsia,
                    title: 'Log out',
                    destructive: true,
                    onTap: () => _confirmLogout(context),
                  ),
                  SizedBox(height: 12.r),
                  _DeleteAccountCard(
                    onTap: () => _openDeleteFlow(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.graphite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Corners.lg)),
        title: Text(
          'Log out?',
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontWeight: FontWeight.w700,
            color: AppColors.paper,
            fontSize: 22.sp,
          ),
        ),
        content: Text(
          "You'll need to sign in with your phone again.",
          style: TextStyle(
            fontFamily: 'GeneralSans',
            color: AppColors.muted,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel', style: TextStyle(color: AppColors.muted, fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              HapticFeedback.mediumImpact();
              context.go('/splash');
            },
            child: Text(
              'LOG OUT',
              style: TextStyle(
                color: AppColors.fuchsia,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2.sp,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDeleteFlow(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _DeleteAccountScreen()),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                          colorFilter: ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                        ),
                      ),
            ),
          ),
          SizedBox(width: 14.r),
          Text(
            'SETTINGS',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 36.sp,
              height: 0.95,
              letterSpacing: -1.2.sp,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color accent;
  const _SectionLabel({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24.r, bottom: 10.r, left: 4.r),
      child: Row(
        children: [
          Container(width: 14.r, height: 3, color: accent),
          SizedBox(width: 8.r),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 11.sp,
              letterSpacing: 1.8.sp,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Row card ──────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final String? svg;
  final IconData? icon;
  final Color tint;
  final String title;
  final String? subtitle;
  final bool destructive;
  final VoidCallback onTap;

  const _SettingsRow({
    this.svg,
    this.icon,
    required this.tint,
    required this.title,
    this.subtitle,
    this.destructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = destructive ? AppColors.fuchsia : AppColors.paper;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.r),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.graphite,
            border: Border.all(
              color: destructive
                  ? AppColors.fuchsia.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(Corners.md),
          ),
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  border: Border.all(color: tint.withValues(alpha: 0.35)),
                  borderRadius: BorderRadius.circular(Corners.sm),
                ),
                child: Center(
                  child: svg != null
                      ? SvgPicture.asset(
                          svg!,
                          width: 20.r,
                          height: 20.r,
                          colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
                        )
                      : Icon(icon, color: tint, size: 20.r),
                ),
              ),
              SizedBox(width: 14.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.r),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/arrow-right.svg',
                width: 22.r,
                height: 22.r,
                colorFilter: ColorFilter.mode(
                  destructive ? AppColors.fuchsia : AppColors.muted,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Delete Account card ───────────────────────────────────────────────────

class _DeleteAccountCard extends StatelessWidget {
  final VoidCallback onTap;
  const _DeleteAccountCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFFF3B3B);
    return StickerShadow(
      color: danger,
      offset: Offset(4.r, 4.r),
      radius: Corners.md,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.graphite,
            border: Border.all(color: danger, width: 1.5),
            borderRadius: BorderRadius.circular(Corners.md),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: danger.withValues(alpha: 0.15),
                  border: Border.all(color: danger.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(Corners.sm),
                ),
                child: Icon(Icons.delete_forever_rounded, color: danger, size: 22.r),
              ),
              SizedBox(width: 14.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELETE ACCOUNT',
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        letterSpacing: 0.4.sp,
                        color: danger,
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      "permanent. can't be undone.",
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
              SvgPicture.asset(
                        'assets/icons/arrow-right.svg',
                        width: 22.r,
                        height: 22.r,
                        colorFilter: ColorFilter.mode(danger, BlendMode.srcIn),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Delete Account confirmation screen ────────────────────────────────────

class _DeleteAccountScreen extends StatefulWidget {
  const _DeleteAccountScreen();

  @override
  State<_DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<_DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  static const _danger = Color(0xFFFF3B3B);

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canDelete => _confirmController.text.trim().toUpperCase() == 'DELETE';

  void _doDelete() {
    HapticFeedback.heavyImpact();
    HatriSnack.show(
      context,
      'account gone. take care.',
      vibe: SnackVibe.muted,
      emoji: '👋',
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      context.go('/splash');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, 0),
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
                          colorFilter: ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                        ),
                      ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(Insets.lg, 24.r, Insets.lg, 20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELETE',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 12.sp,
                          letterSpacing: 1.8.sp,
                          color: _danger,
                        ),
                      ),
                      SizedBox(height: 14.r),
                      Text(
                        "THIS CAN'T\nBE UNDONE.",
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w800,
                          fontSize: 48.sp,
                          height: 0.92,
                          letterSpacing: -1.4.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SizedBox(height: 20.r),
                      Text(
                        "Delete your Hatri account and everything tied to it. This wipes:",
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          height: 1.5,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 16.r),
                      const _WipeItem(text: 'your profile, name and photo'),
                      const _WipeItem(text: 'RSVPs, saved events, past attendance'),
                      const _WipeItem(text: 'communities you joined or host'),
                      const _WipeItem(text: 'plans with friends'),
                      const _WipeItem(text: 'chats and dms'),
                      SizedBox(height: 32.r),
                      Text(
                        "type DELETE to confirm",
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          letterSpacing: 0.4.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SizedBox(height: 10.r),
                      TextField(
                        controller: _confirmController,
                        textCapitalization: TextCapitalization.characters,
                        cursorColor: _danger,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 20.sp,
                          letterSpacing: 2,
                          color: AppColors.paper,
                        ),
                        decoration: InputDecoration(
                          hintText: 'DELETE',
                          hintStyle: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                            letterSpacing: 2,
                            color: AppColors.muted,
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.r),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: _danger, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(Insets.lg, 8.r, Insets.lg, 20.r),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canDelete ? _doDelete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _danger,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.surfaceRaised,
                      disabledForegroundColor: AppColors.muted,
                      padding: EdgeInsets.symmetric(vertical: 18.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Corners.md),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'DELETE FOREVER',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        letterSpacing: 1.2.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WipeItem extends StatelessWidget {
  final String text;
  const _WipeItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 7.r, right: 10.r),
            child: Container(
              width: 6.r,
              height: 6.r,
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B3B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                height: 1.4,
                color: AppColors.paper,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
