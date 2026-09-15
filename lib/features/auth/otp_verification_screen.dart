import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../backend/api/api_exception.dart';
import '../../backend/services/auth_service.dart';
import '../../core/di/injection_container.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/hatri_snack.dart';

/// OTP verification — responsive 6-box grid, keyboard-safe pinned CTA,
/// tap-outside-to-dismiss.
///
/// The [phoneMasked] parameter carries the raw E.164 phone (e.g. `+919999999999`)
/// used to talk to the backend, and is formatted for display in [_displayPhone].
class OtpVerificationScreen extends StatefulWidget {
  final String phoneMasked;
  const OtpVerificationScreen({super.key, required this.phoneMasked});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _len = 6;
  final _controllers = List.generate(_len, (_) => TextEditingController());
  final _focus = List.generate(_len, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = 30;
  bool _verifying = false;
  bool _resending = false;

  /// Backend format: +919999999999 (no space).
  String get _rawPhone {
    // The screen accepts either a raw E.164 or a formatted "+91 XXXXXXXXXX".
    // We normalize by stripping non-digits then re-prefixing '+'.
    final digits = widget.phoneMasked.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? widget.phoneMasked : '+$digits';
  }

  /// Display format: +91 XXXXXXXXXX.
  String get _displayPhone {
    final raw = _rawPhone;
    if (raw.startsWith('+91') && raw.length > 3) {
      return '+91 ${raw.substring(3)}';
    }
    return raw;
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
    for (final f in _focus) {
      f.addListener(() => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focus.first.requestFocus(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focus) f.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        if (mounted) setState(() {});
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _code => _controllers.map((c) => c.text).join();
  bool get _canVerify => _code.length == _len;

  void _onCharChanged(int i, String v) {
    if (v.length > 1) {
      // paste — distribute
      final digits = v.replaceAll(RegExp(r'\D'), '');
      for (int j = 0; j < _len; j++) {
        _controllers[j].text = j < digits.length ? digits[j] : '';
      }
      final targetIdx = digits.length >= _len ? _len - 1 : digits.length;
      FocusScope.of(context).requestFocus(_focus[targetIdx.clamp(0, _len - 1)]);
      setState(() {});
      if (_canVerify) _verify();
      return;
    }
    setState(() {});
    if (v.isNotEmpty && i < _len - 1) {
      FocusScope.of(context).requestFocus(_focus[i + 1]);
    }
    if (_canVerify) _verify();
  }

  void _onBackspace(int i) {
    if (_controllers[i].text.isEmpty && i > 0) {
      FocusScope.of(context).requestFocus(_focus[i - 1]);
      _controllers[i - 1].clear();
      setState(() {});
    }
  }

  Future<void> _verify() async {
    if (_verifying) return;
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    setState(() => _verifying = true);
    try {
      await sl<AuthService>().verifyOtp(_rawPhone, _code);
      if (!mounted) return;
      context.go('/name');
    } on ApiException catch (e) {
      if (!mounted) return;
      HatriSnack.show(
        context,
        _friendlyError(e),
        vibe: SnackVibe.info,
        emoji: '❌',
      );
      // Clear inputs on failure so user can retype.
      for (final c in _controllers) {
        c.clear();
      }
      FocusScope.of(context).requestFocus(_focus.first);
      setState(() {});
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resending) return;
    HapticFeedback.selectionClick();
    setState(() => _resending = true);
    try {
      await sl<AuthService>().requestOtp(_rawPhone);
      _startCountdown();
      if (!mounted) return;
      HatriSnack.show(
        context,
        'new code, on the way',
        vibe: SnackVibe.info,
        emoji: '📩',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      HatriSnack.show(
        context,
        _friendlyError(e),
        vibe: SnackVibe.info,
        emoji: '📵',
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String _friendlyError(ApiException e) {
    if (e is NetworkException) return 'no network. try again.';
    if (e is ClientException && e.statusCode == 401) {
      return 'wrong code. try again.';
    }
    if (e is UnauthorizedException) return 'wrong code. try again.';
    if (e is ClientException && e.statusCode == 429) {
      return 'chill, too many tries. wait a bit.';
    }
    return e.message;
  }

  @override
  Widget build(BuildContext context) {
    final timerDone = _secondsLeft <= 0;

    return Scaffold(
      backgroundColor: AppColors.ground,
      // resizeToAvoidBottomInset: true (default) — layout shrinks when
      // keyboard opens; the pinned Verify sits above it naturally.
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12.r, 12.r, 12.r, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44.r,
                      height: 44.r,
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
                          colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Middle — scrollable so it degrades gracefully on short screens
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.r, 24.r, 24.r, 16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '02 / VERIFY',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 12.sp,
                          letterSpacing: 1.8.sp,
                          color: AppColors.fuchsia,
                        ),
                      ),
                      SizedBox(height: 12.r),
                      Text(
                        'WE PINGED\nYOU',
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w800,
                          fontSize: 52.sp,
                          height: 0.92,
                          letterSpacing: -0.6.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SizedBox(height: 12.r),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            color: AppColors.muted,
                          ),
                          children: [
                            const TextSpan(
                                text: '6 magic digits sent to '),
                            TextSpan(
                              text: _displayPhone,
                              style: const TextStyle(
                                color: AppColors.paper,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.r),
                      Text(
                        'psst, check your spam if it\'s ghosting 👀',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: AppColors.muted.withValues(alpha: 0.75),
                        ),
                      ),
                      SizedBox(height: 32.r),
                      // Responsive code boxes — Row of 6 Expanded cells
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (int i = 0; i < _len; i++) ...[
                            Expanded(child: _codeBox(i)),
                            if (i < _len - 1) SizedBox(width: 8.r),
                          ],
                        ],
                      ),
                      SizedBox(height: 24.r),
                      // Resend row — timer OR button
                      Center(
                        child: timerDone
                            ? GestureDetector(
                                onTap: _resend,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.r, vertical: 8.r),
                                  child: Text(
                                    'RESEND CODE',
                                    style: TextStyle(
                                      fontFamily: 'GeneralSans',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.sp,
                                      letterSpacing: 1.2.sp,
                                      color: AppColors.fuchsia,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.fuchsia,
                                      decorationThickness: 2,
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No code yet? ',
                                    style: TextStyle(
                                      fontFamily: 'GeneralSans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13.sp,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  Text(
                                    'Resend in ${_secondsLeft}s',
                                    style: TextStyle(
                                      fontFamily: 'GeneralSans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.sp,
                                      color: AppColors.paper,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              // Pinned Verify — naturally rides above the keyboard
              Padding(
                padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 20.r),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_canVerify && !_verifying) ? _verify : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fuchsia,
                      foregroundColor: AppColors.paper,
                      disabledBackgroundColor: AppColors.surfaceRaised,
                      disabledForegroundColor: AppColors.muted,
                      padding: EdgeInsets.symmetric(vertical: 18.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Corners.md),
                      ),
                      elevation: 0,
                    ),
                    child: _verifying
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            'VERIFY',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w800,
                              fontSize: 15.sp,
                              letterSpacing: 1.0.sp,
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

  Widget _codeBox(int i) {
    final filled = _controllers[i].text.isNotEmpty;
    final focused = _focus[i].hasFocus;
    final active = filled || focused;

    return AspectRatio(
      aspectRatio: 1 / 1.1,
      child: RawKeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            _onBackspace(i);
          }
        },
        child: AnimatedScale(
          scale: filled ? 1.0 : 0.97,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            // The AspectRatio gives this box a tight height, and `isCollapsed`
            // makes the field shrink-wrap to its line height — without an
            // alignment the digit lands at the top of the box instead of the
            // middle. `textAlignVertical` can't help: it only distributes space
            // the decorator actually owns, and a collapsed one owns none.
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // Border-only focus feedback — no fill tint.
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(Corners.md),
              border: Border.all(
                color: active ? AppColors.fuchsia : AppColors.border,
                width: active ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _controllers[i],
              focusNode: _focus[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: AppColors.fuchsia,
              cursorWidth: 2,
              cursorHeight: 26.sp,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) => _onCharChanged(i, v),
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 24.sp,
                height: 1.0,
                color: AppColors.paper,
              ),
              decoration: const InputDecoration(
                counterText: '',
                filled: false,
                fillColor: Colors.transparent,
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
