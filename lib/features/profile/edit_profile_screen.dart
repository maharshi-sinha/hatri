import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../backend/api/api_exception.dart';
import '../../backend/services/avatar_upload_service.dart';
import '../../backend/services/user_service.dart';
import '../../core/di/injection_container.dart';
import '../../core/models/models.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/hatri_snack.dart';
import '../../shared/widgets/social_brand_badge.dart';
import 'verify_email_screen.dart';

/// Edit the user's name, bio + avatar. Writes back to the [currentUser]
/// global and pops with `true` when a save happens so the profile refreshes.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _email;
  late final TextEditingController _instagram;
  late final TextEditingController _x;
  late final TextEditingController _website;
  late String _avatarUrl;
  late String _committedEmail; // whatever was verified last
  late bool _emailVerified;
  File? _pickedAvatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: currentUser.name);
    _bio = TextEditingController(text: currentUser.bio);
    _email = TextEditingController(text: currentUser.email);
    _instagram = TextEditingController(text: currentUser.instagram);
    _x = TextEditingController(text: currentUser.x);
    _website = TextEditingController(text: currentUser.website);
    _avatarUrl = currentUser.profileImage;
    _committedEmail = currentUser.email;
    _emailVerified = currentUser.emailVerified;
    _name.addListener(_ping);
    _bio.addListener(_ping);
    _email.addListener(_onEmailChanged);
    _instagram.addListener(_ping);
    _x.addListener(_ping);
    _website.addListener(_ping);
  }

  void _onEmailChanged() {
    // Changing the email breaks the previous verification.
    final newV = _email.text.trim() == _committedEmail && _committedEmail.isNotEmpty
        ? _emailVerified
        : false;
    if (newV != _emailVerified) {
      setState(() => _emailVerified = newV);
    } else {
      setState(() {});
    }
  }

  void _ping() => setState(() {});

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _email.dispose();
    _instagram.dispose();
    _x.dispose();
    _website.dispose();
    super.dispose();
  }

  String _normalizeHandle(String v) {
    var t = v.trim();
    if (t.isEmpty) return '';
    if (t.startsWith('@')) t = t.substring(1);
    return t.isEmpty ? '' : '@$t';
  }

  bool get _dirty {
    if (_name.text.trim() != currentUser.name) return true;
    if (_bio.text.trim() != currentUser.bio) return true;
    if (_email.text.trim() != currentUser.email) return true;
    if (_emailVerified != currentUser.emailVerified) return true;
    if (_normalizeHandle(_instagram.text) != currentUser.instagram) return true;
    if (_normalizeHandle(_x.text) != currentUser.x) return true;
    if (_website.text.trim() != currentUser.website) return true;
    if (_pickedAvatar != null) return true;
    return false;
  }

  bool get _canSave => _dirty && _name.text.trim().isNotEmpty && !_emailNeedsVerify;

  bool get _isValidEmail {
    final t = _email.text.trim();
    if (t.isEmpty) return false;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(t);
  }

  bool get _emailNeedsVerify => _isValidEmail && !_emailVerified;

  Future<void> _verifyEmail() async {
    if (!_isValidEmail) return;
    HapticFeedback.selectionClick();
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: _email.text.trim())),
    );
    if (ok == true && mounted) {
      setState(() {
        _emailVerified = true;
        _committedEmail = _email.text.trim();
      });
    }
  }

  Future<void> _pickAvatar() async {
    HapticFeedback.selectionClick();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => _pickedAvatar = File(picked.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "couldn't open your gallery. try again?",
            style: TextStyle(fontFamily: 'GeneralSans', fontWeight: FontWeight.w600, fontSize: 13.sp),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    final newName = _name.text.trim();
    final newBio = _bio.text.trim();
    String? uploadedAvatarUrl;

    try {
      // 1. Upload new avatar first — if this fails the whole save fails,
      // so the user isn't left with a half-updated profile.
      if (_pickedAvatar != null) {
        final user = await sl<AvatarUploadService>().uploadAvatar(_pickedAvatar!);
        uploadedAvatarUrl = user.avatarUrl;
      }
      // 2. Text fields — only send what changed.
      // email/instagram/x/website stay local until backend supports them.
      await sl<UserService>().updateProfile(
        displayName: newName == currentUser.name ? null : newName,
        bio: newBio == currentUser.bio ? null : newBio,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      HatriSnack.show(context, _friendlyError(e), vibe: SnackVibe.info, emoji: '⚠️');
      return;
    }

    // Update the local mirror so the profile screen renders immediately.
    currentUser.name = newName;
    currentUser.bio = newBio;
    currentUser.email = _email.text.trim();
    currentUser.emailVerified = _emailVerified;
    currentUser.instagram = _normalizeHandle(_instagram.text);
    currentUser.x = _normalizeHandle(_x.text);
    currentUser.website = _website.text.trim();
    if (uploadedAvatarUrl != null) {
      currentUser.profileImage = uploadedAvatarUrl;
    } else if (_avatarUrl.isNotEmpty) {
      currentUser.profileImage = _avatarUrl;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String _friendlyError(ApiException e) {
    if (e is NetworkException) return 'no network. try again.';
    if (e is UnauthorizedException) return 'session expired. sign in again.';
    return e.message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(Insets.lg, 8.r, Insets.lg, 40.r),
                  children: [
                    SizedBox(height: 12.r),
                    _buildAvatarPicker(),
                    SizedBox(height: 36.r),
                    _label('YOUR NAME'),
                    SizedBox(height: 6.r),
                    _nameField(),
                    SizedBox(height: 28.r),
                    _label('A SHORT BIO'),
                    SizedBox(height: 6.r),
                    _bioField(),
                    SizedBox(height: 6.r),
                    _bioCharCounter(),
                    SizedBox(height: 28.r),
                    Row(
                      children: [
                        _label('EMAIL'),
                        const Spacer(),
                        if (_email.text.trim().isNotEmpty) _emailStatusPill(),
                      ],
                    ),
                    SizedBox(height: 6.r),
                    _emailField(),
                    if (_emailNeedsVerify) ...[
                      SizedBox(height: 10.r),
                      _verifyEmailButton(),
                    ],
                    SizedBox(height: 40.r),
                    _sectionDivider(),
                    SizedBox(height: 22.r),
                    _label('YOUR SOCIALS'),
                    SizedBox(height: 4.r),
                    Text(
                      'Optional. Helps the scene find you.',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 18.r),
                    _socialField(
                      brand: SocialBrand.instagram,
                      accent: AppColors.fuchsia,
                      controller: _instagram,
                      label: 'INSTAGRAM',
                      hint: 'your.handle',
                      prefix: '@',
                    ),
                    SizedBox(height: 14.r),
                    _socialField(
                      brand: SocialBrand.x,
                      accent: AppColors.paper,
                      controller: _x,
                      label: 'X / TWITTER',
                      hint: 'your.handle',
                      prefix: '@',
                    ),
                  ],
                ),
              ),
              _buildSaveBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 8.r),
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
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(Corners.md),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  width: 20.r,
                  height: 20.r,
                  colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.r),
          Text(
            'EDIT PROFILE',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 26.sp,
              height: 1.0,
              letterSpacing: -0.6.sp,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    ImageProvider? bg;
    if (_pickedAvatar != null) {
      bg = FileImage(_pickedAvatar!);
    } else if (_avatarUrl.startsWith('http')) {
      bg = NetworkImage(_avatarUrl);
    } else if (_avatarUrl.isNotEmpty) {
      bg = FileImage(File(_avatarUrl));
    }
    return Center(
      child: GestureDetector(
        onTap: _pickAvatar,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 130.r,
              height: 130.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.fuchsia, width: 2),
                image: bg != null ? DecorationImage(image: bg, fit: BoxFit.cover) : null,
              ),
              child: bg == null
                  ? Icon(Icons.person_rounded, size: 46.r, color: AppColors.muted)
                  : null,
            ),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.fuchsia,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ground, width: 2),
              ),
              child: Icon(Icons.camera_alt_rounded, size: 16.r, color: AppColors.paper),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w800,
          fontSize: 10.sp,
          letterSpacing: 1.6.sp,
          color: AppColors.muted,
        ),
      );

  Widget _nameField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _name,
        cursorColor: AppColors.fuchsia,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ſ\s\-']")),
          LengthLimitingTextInputFormatter(30),
        ],
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
          color: AppColors.paper,
        ),
        decoration: InputDecoration(
          hintText: 'Your name…',
          hintStyle: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: AppColors.muted,
          ),
          filled: false,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12.r),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _bioField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _bio,
        cursorColor: AppColors.fuchsia,
        maxLines: 4,
        minLines: 3,
        maxLength: 140,
        buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          height: 1.4,
          color: AppColors.paper,
        ),
        decoration: InputDecoration(
          hintText: 'a short bio…',
          hintStyle: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
            color: AppColors.muted,
          ),
          filled: false,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12.r),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _emailField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _email,
        cursorColor: AppColors.fuchsia,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
          color: AppColors.paper,
        ),
        decoration: InputDecoration(
          hintText: 'you@somewhere.com',
          hintStyle: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: AppColors.muted,
          ),
          filled: false,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12.r),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _emailStatusPill() {
    if (_emailVerified) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
        decoration: BoxDecoration(
          color: AppColors.lime,
          borderRadius: BorderRadius.circular(Corners.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: 12.r, color: AppColors.onNeon),
            SizedBox(width: 3.r),
            Text(
              'VERIFIED',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 9.sp,
                letterSpacing: 1.2.sp,
                color: AppColors.onNeon,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: AppColors.fuchsia.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.fuchsia.withValues(alpha: 0.6), width: 1),
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Text(
        'UNVERIFIED',
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w800,
          fontSize: 9.sp,
          letterSpacing: 1.2.sp,
          color: AppColors.fuchsia,
        ),
      ),
    );
  }

  Widget _verifyEmailButton() {
    return GestureDetector(
      onTap: _verifyEmail,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
        decoration: BoxDecoration(
          color: AppColors.fuchsia,
          borderRadius: BorderRadius.circular(Corners.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline_rounded, size: 15.r, color: AppColors.paper),
            SizedBox(width: 8.r),
            Text(
              'VERIFY EMAIL',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
                letterSpacing: 1.4.sp,
                color: AppColors.paper,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionDivider() {
    return Row(
      children: [
        Container(width: 20.r, height: 3.r, color: AppColors.fuchsia),
        SizedBox(width: 10.r),
        Expanded(
          child: Container(height: 1, color: AppColors.paper.withValues(alpha: 0.08)),
        ),
      ],
    );
  }

  Widget _socialField({
    required SocialBrand brand,
    required Color accent,
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? prefix,
  }) {
    final filled = controller.text.trim().isNotEmpty;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: filled ? accent.withValues(alpha: 0.55) : AppColors.border,
          width: filled ? 1.4 : 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SocialBrandBadge(brand: brand, size: 38.r),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 9.sp,
                    letterSpacing: 1.4.sp,
                    color: AppColors.muted,
                  ),
                ),
                Row(
                  children: [
                    if (prefix != null)
                      Text(
                        prefix,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: filled ? AppColors.paper : AppColors.muted,
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        cursorColor: AppColors.fuchsia,
                        autocorrect: false,
                        keyboardType: prefix == null ? TextInputType.url : TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          // Strip any @ the user types — the "@" prefix is
                          // already shown by the field, and we normalise on
                          // save. Prevents "@@handle" from ever appearing.
                          FilteringTextInputFormatter.deny(RegExp(r'@')),
                          LengthLimitingTextInputFormatter(60),
                        ],
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: AppColors.paper,
                        ),
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w500,
                            fontSize: 15.sp,
                            color: AppColors.muted,
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.r),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (filled)
            Icon(Icons.check_circle_rounded, size: 20.r, color: accent),
        ],
      ),
    );
  }

  Widget _bioCharCounter() {
    final left = 140 - _bio.text.length;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$left left',
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
          color: left < 20 ? AppColors.fuchsia : AppColors.muted,
        ),
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Insets.lg,
        12.r,
        Insets.lg,
        MediaQuery.of(context).padding.bottom + 12.r,
      ),
      decoration: BoxDecoration(
        color: AppColors.ground,
        border: Border(top: BorderSide(color: AppColors.paper.withValues(alpha: 0.08))),
      ),
      child: GestureDetector(
        onTap: _canSave ? _save : null,
        child: Container(
          height: 54.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _canSave ? AppColors.fuchsia : AppColors.surface,
            border: Border.all(
              color: _canSave ? AppColors.fuchsia : AppColors.border,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(Corners.md),
          ),
          child: _saving
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(
                    color: AppColors.paper,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  _dirty ? 'SAVE CHANGES' : 'NO CHANGES YET',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                    letterSpacing: 1.4.sp,
                    color: _canSave ? AppColors.paper : AppColors.muted,
                  ),
                ),
        ),
      ),
    );
  }
}

