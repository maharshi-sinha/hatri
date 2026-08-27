import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// Phone number entry — India-only (+91) for the prototype.
class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canContinue => _phoneController.text.length == 10;

  void _sendOtp() {
    HapticFeedback.mediumImpact();
    context.push('/otp', extra: '+91 ${_phoneController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.r, 24.r, 24.r, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '01 / SIGN IN',
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
                      'WHAT\'S YOUR\nNUMBER?',
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontSize: 48.sp,
                        height: 0.92,
                        letterSpacing: -1.4.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    SizedBox(height: 12.r),
                    Text(
                      '6-digit code, incoming',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 48.r),
                    // Phone input row: [+91] [10-digit input]
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.r, vertical: 12.r),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(Corners.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🇮🇳', style: TextStyle(fontSize: 20.sp)),
                              SizedBox(width: 8.r),
                              Text(
                                '+91',
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18.sp,
                                  color: AppColors.paper,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.r),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            autofocus: true,
                            cursorColor: AppColors.fuchsia,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 24.sp,
                              letterSpacing: 2,
                              color: AppColors.paper,
                            ),
                            decoration: InputDecoration(
                              hintText: '98••• •••••',
                              hintStyle: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w600,
                                fontSize: 22.sp,
                                letterSpacing: 2,
                                color: AppColors.muted,
                              ),
                              filled: false,
                              fillColor: Colors.transparent,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12.r),
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.fuchsia, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.r),
                    Text(
                      'Standard SMS rates may apply.',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // CTA
            Padding(
              padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 20.r),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue ? _sendOtp : null,
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
                  child: Text(
                    'SEND OTP',
                    style: TextStyle(
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
    );
  }
}
