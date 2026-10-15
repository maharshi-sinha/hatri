import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../backend/api/api_exception.dart';
import '../../../../backend/services/msg91_widget_service.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/design/hatri_snack.dart';

/// Phone number entry — India-only (+91) for the prototype.
class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  bool _sending = false;

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

  bool get _canContinue => _phoneController.text.length == 10 && !_sending;

  Future<void> _sendOtp() async {
    if (_sending) return;
    HapticFeedback.mediumImpact();
    setState(() => _sending = true);
    // E.164 for both analytics and the MSG91 widget (which internally strips
    // the '+').
    final phone = '+91${_phoneController.text}';
    try {
      unawaited(sl<AnalyticsService>().signInStarted());
      unawaited(sl<AnalyticsService>().otpRequested());
      // MSG91 widget path: client-side OTP send, no DLT template required.
      await sl<Msg91WidgetService>().sendOtp(phone);
      if (!mounted) return;
      context.push('/otp', extra: phone);
    } on Msg91WidgetException catch (e) {
      if (!mounted) return;
      HatriSnack.show(context, _friendlyWidgetError(e), vibe: SnackVibe.info, emoji: '📵');
    } on ApiException catch (e) {
      if (!mounted) return;
      HatriSnack.show(context, _friendlyError(e), vibe: SnackVibe.info, emoji: '📵');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _friendlyError(ApiException e) {
    if (e is NetworkException) return 'no network. try again in a bit.';
    if (e is ClientException && e.statusCode == 429) {
      return 'chill, too many OTPs. try in a minute.';
    }
    return e.message;
  }

  String _friendlyWidgetError(Msg91WidgetException e) {
    final m = e.message.toLowerCase();
    if (m.contains('network') || m.contains('failed to load')) {
      return 'no network. try again in a bit.';
    }
    if (m.contains('rate') || m.contains('limit')) {
      return 'chill, too many OTPs. try in a minute.';
    }
    return 'could not send OTP. try again.';
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
                  child: _sending
                      ? SizedBox(
                          height: 20.r,
                          width: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.paper),
                          ),
                        )
                      : Text(
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
