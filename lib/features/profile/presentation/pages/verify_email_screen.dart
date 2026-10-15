import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';

/// 6-digit email OTP entry. Mock verification for the prototype: any 6 digits
/// entered → success and pops with `true`. Wired into edit-profile so users
/// can prove they own the email they typed.
class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _c = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _f = List.generate(6, (_) => FocusNode());
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _f[0].requestFocus());
  }

  @override
  void dispose() {
    for (final c in _c) {
      c.dispose();
    }
    for (final f in _f) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _c.map((c) => c.text).join();
  bool get _complete => _code.length == 6;

  void _onChanged(int i, String v) {
    if (v.length > 1) {
      // Paste — spread across the fields
      final digits = v.replaceAll(RegExp(r'\D'), '');
      for (var k = 0; k < 6; k++) {
        _c[k].text = k < digits.length ? digits[k] : '';
      }
      _f[digits.length.clamp(0, 5)].requestFocus();
      setState(() {});
      return;
    }
    if (v.isNotEmpty && i < 5) {
      _f[i + 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    if (!_complete || _busy) return;
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);
    // Mock verification — accept anything.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.r),
                    Text(
                      '02 / EMAIL',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 11.sp,
                        letterSpacing: 1.6.sp,
                        color: AppColors.fuchsia,
                      ),
                    ),
                    SizedBox(height: 14.r),
                    Text(
                      'CHECK YOUR\nINBOX.',
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 44.sp,
                        height: 0.95,
                        letterSpacing: -1.6.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    SizedBox(height: 14.r),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: '6 magic digits sent to '),
                          TextSpan(
                            text: widget.email,
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w800,
                              color: AppColors.paper,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        height: 1.4,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 6.r),
                    Text(
                      "psst, check your spam if it's ghosting 👀",
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 32.r),
                    _buildOtpRow(),
                    SizedBox(height: 16.r),
                    Center(
                      child: Text(
                        'any 6 digits, no cap 🤝',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildVerifyButton(),
          ],
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
        ],
      ),
    );
  }

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final filled = _c[i].text.isNotEmpty;
        return SizedBox(
          width: 46.r,
          height: 56.r,
          child: TextField(
            controller: _c[i],
            focusNode: _f[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            cursorColor: AppColors.fuchsia,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => _onChanged(i, v),
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 22.sp,
              color: AppColors.paper,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: filled ? AppColors.fuchsia : AppColors.border,
                  width: filled ? 1.6 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppColors.fuchsia, width: 2),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Insets.lg,
        12.r,
        Insets.lg,
        MediaQuery.of(context).padding.bottom + 12.r,
      ),
      child: GestureDetector(
        onTap: _complete ? _verify : null,
        child: Container(
          height: 54.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _complete ? AppColors.fuchsia : AppColors.surface,
            border: Border.all(
              color: _complete ? AppColors.fuchsia : AppColors.border,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(Corners.md),
          ),
          child: _busy
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(color: AppColors.paper, strokeWidth: 2.4),
                )
              : Text(
                  'VERIFY',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                    letterSpacing: 1.4.sp,
                    color: _complete ? AppColors.paper : AppColors.muted,
                  ),
                ),
        ),
      ),
    );
  }
}
